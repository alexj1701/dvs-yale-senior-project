"""Analyze a stepped tb_all_one_event.sp run: one PNG per .step, plus a summary of the events.

tb_all_one_event.sp gives the pixel one light step up (expected ON event) and one step down (expected OFF
event). With a `.step` line active, tb_all_one_event.csv holds every step back to back (time restarts at 0 for
each one). This script splits the steps and, for each one,

  * plots the light level, Vpr/Vpd, Vdiff, VON/VnOFF and the reset signals (shared y limits across steps),
  * measures the events: did the ON event fire, how long after the step, did the OFF event fire, were there extra
    (spurious) events, and did the pixel settle afterwards,

then writes summary.csv and summary.png with those measurements against the swept bias.

The swept bias is found automatically, in this order:
  1. from the bias voltages printed in the CSV (v(Vref), v(Vcasc), ... on the .print line);
  2. from the single active `.step` line in the netlist with the same name as the CSV (tb_all_one_event.sp);
  3. from --sweep, in the order of the .step list:

    python plot_sweep.py --sweep Vref=1.2,1.3,1.4,1.5,1.6

Other options:

    python plot_sweep.py --tmax 10          # plot only the first 10 ms of each step
    python plot_sweep.py --tmin 5.9 --tmax 8   # zoom in on the ON event
"""
import argparse
import csv
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

# colour cycle without red, so Vreset (red) stands out
plt.rcParams["axes.prop_cycle"] = plt.cycler(
    color=["#1f77b4", "#ff7f0e", "#2ca02c", "#9467bd", "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf"]
)

# CSV column names are upper-cased when read
TIME, TRI, IPH, VPD = "TIME", "V(TRI)", "I(BPH)", "V(VPD)"
VPR, VDIFF = "V(XPIXEL:VPR)", "V(XPIXEL:VDIFF)"
VON, VNOFF = "V(VON)", "V(VNOFF)"
VNRST, VRESET = "V(XPIXEL:VNRSTCHAMP)", "V(VRESET)"
REQUIRED = [TIME, TRI, VPD, VPR, VDIFF, VON, VNOFF, VNRST, VRESET]

# bias columns that may be printed in the CSV, to detect the swept bias
BIASES = [
    ("V(VCASC)", "Vcasc"),
    ("V(VG_FB)", "Vg_fb"),
    ("V(VIPR)", "Vipr"),
    ("V(VIDIFF)", "Vidiff"),
    ("V(VION)", "VIon"),
    ("V(VIOFF)", "VIoff"),
    ("V(VREF)", "Vref"),
]

START_IGNORE_MS = 1.5  # the start-up reset pulse ends at 1 ms; ignore events before this


def load(path):
    with open(path, newline="") as f:
        rows = list(csv.reader(f))
    header = [c.strip().upper() for c in rows[0]]
    data = np.array([[float(x) for x in r] for r in rows[1:] if len(r) == len(header)])
    cols = {name: data[:, i] for i, name in enumerate(header)}
    missing = [c for c in REQUIRED if c not in cols]
    if missing:
        raise SystemExit(f"{path} is missing columns {missing}; found {header}")
    t = cols[TIME]
    # a new step starts wherever time goes backwards
    starts = [0] + [i for i in range(1, len(t)) if t[i] < t[i - 1]] + [len(t)]
    return [{k: v[a:b] for k, v in cols.items()} for a, b in zip(starts, starts[1:])]


def steps_from_netlist(path, n):
    """Read the active `.step NAME LIST v1 v2 ...` (or `.step NAME start stop step`) line from the netlist.

    Returns (name, values) when exactly one .step line is active and it gives n values, else None.
    """
    p = Path(path)
    if not p.exists():
        return None
    lines = [l.strip() for l in p.read_text().splitlines() if l.strip().lower().startswith(".step")]
    if len(lines) != 1:
        return None
    tok = lines[0].split()
    tok = [t for t in tok[1:] if t.lower() != "param"]
    name = tok[0]
    try:
        if len(tok) > 1 and tok[1].lower() == "list":
            vals = [float(v) for v in tok[2:]]
        elif len(tok) == 4:
            a, b, st = (float(v) for v in tok[1:4])
            vals = [a + k * st for k in range(int(round((b - a) / st)) + 1)]
        else:
            return None
    except ValueError:
        return None
    if len(vals) != n:
        return None
    return (name[:-4] if name.lower().endswith("_val") else name), vals


def sweep_labels(steps, sweep_arg, netlist=None):
    """Return (name, [value per step]) for the swept bias, from CSV bias columns or --sweep."""
    swept = []
    for col, label in BIASES:
        if col in steps[0]:
            vals = [s[col][len(s[col]) // 2] for s in steps]
            if max(vals) - min(vals) > 1e-9:
                swept.append((label, vals))
    if swept:
        return "_".join(n for n, _ in swept), swept[0][1], swept
    if sweep_arg:
        name, vals = sweep_arg.split("=", 1)
        vals = [float(v) for v in vals.split(",")]
        if len(vals) != len(steps):
            raise SystemExit(f"--sweep has {len(vals)} values but the CSV has {len(steps)} steps")
        return name, vals, [(name, vals)]
    found = steps_from_netlist(netlist, len(steps)) if netlist else None
    if found:
        print(f"labelling the steps from the .step line in {netlist}")
        return found[0], found[1], [found]
    print("note: could not tell which bias was swept (no bias columns in the CSV, no usable .step line, no --sweep); "
          "labelling the steps 1, 2, ...")
    return "step", list(range(1, len(steps) + 1)), [("step", list(range(1, len(steps) + 1)))]


def events(t, y, level, hyst):
    """Schmitt-trigger crossings of y through `level`: lists of (rising times, falling times)."""
    hi, lo = level + hyst, level - hyst
    state, rising, falling = 0, [], []
    for ti, yi in zip(t, y):
        if yi > hi:
            if state == -1:
                rising.append(ti)
            state = 1
        elif yi < lo:
            if state == 1:
                falling.append(ti)
            state = -1
    return np.array(rising), np.array(falling)


def landmarks(s):
    """Times (s) of the light step up and step down, from the tri waveform."""
    t, tri = s[TIME], s[TRI]
    up = np.argmax(tri > tri[0] + 0.01)
    top = np.argmax(tri >= tri.max() - 0.01)  # first sample on the high plateau
    down = top + np.argmax(tri[top:] < tri.max() - 0.01)  # first sample of the falling edge
    return t[up], t[down]


def measure(s, vth, hyst):
    t = s[TIME]
    t_up, t_down = landmarks(s)
    ign = START_IGNORE_MS * 1e-3
    on_rise, on_fall = events(t, s[VON], vth, hyst)  # VON events are rising crossings
    off_rise, off_fall = events(t, s[VNOFF], vth, hyst)  # VnOFF events (active low) are falling crossings
    rst_rise, rst_fall = events(t, s[VNRST], vth, hyst)  # the reset firing is VnRstChAmp falling (active low)

    within = lambda x, a, b: x[(x >= a) & (x < b)]
    t_end = t[-1] + 1
    m = {
        "rows": len(t),
        "t_up_ms": t_up * 1e3,
        "t_down_ms": t_down * 1e3,
        "on_events": len(within(on_rise, t_up, t_down)),
        "off_events": len(within(off_fall, t_down, t_end)),
    }
    first_on = within(on_rise, t_up, t_down)
    first_off = within(off_fall, t_down, t_end)
    rst_on, rst_off = within(rst_fall, t_up, t_down), within(rst_fall, t_down, t_end)
    m["rst_on"], m["rst_off"] = len(rst_on), len(rst_off)
    m["rst_on_latency_us"] = (rst_on[0] - t_up) * 1e6 if len(rst_on) else np.nan
    m["rst_off_latency_us"] = (rst_off[0] - t_down) * 1e6 if len(rst_off) else np.nan
    m["on_latency_us"] = (first_on[0] - t_up) * 1e6 if len(first_on) else np.nan
    m["off_latency_us"] = (first_off[0] - t_down) * 1e6 if len(first_off) else np.nan
    # extra events: before the step, and the opposite polarity in each window
    m["spurious"] = (
        len(within(on_rise, ign, t_up)) + len(within(off_fall, ign, t_up))
        + len(within(off_fall, t_up, t_down)) + len(within(on_rise, t_down, t_end))
        + max(0, m["on_events"] - 1) + max(0, m["off_events"] - 1)
    )
    on_win = (t >= t_up) & (t < t_down)
    off_win = t >= t_down
    pre_down = (t >= t_down - 1e-3) & (t < t_down)
    m["on_peak"] = s[VON][on_win].max()  # highest VON after the up step (an event needs it above the threshold)
    m["off_min"] = s[VNOFF][off_win].min()  # lowest VnOFF after the down step (an event needs it below the threshold)
    idle = (t >= t_up - 1e-3) & (t < t_up)
    m["dvdiff_on_mV"] = (s[VDIFF][on_win].min() - s[VDIFF][idle].mean()) * 1e3  # Vdiff drop after the up step
    m["dvdiff_off_mV"] = (s[VDIFF][off_win].max() - s[VDIFF][pre_down].mean()) * 1e3  # Vdiff rise after the down step
    m["vnrst_up"] = s[VNRST][idle].mean()  # VnRstChAmp just before the up step (low = champ still in reset)
    m["vnrst_down"] = s[VNRST][pre_down].mean()
    m["vdiff_idle"] = s[VDIFF][idle].mean()
    m["von_idle"] = s[VON][idle].mean()
    m["vnoff_idle"] = s[VNOFF][idle].mean()
    m["vpr_idle"] = s[VPR][idle].mean()
    last = t >= t[-1] - 2e-3
    m["vdiff_pp_last2ms_mV"] = (s[VDIFF][last].max() - s[VDIFF][last].min()) * 1e3
    m["settled"] = bool(m["vdiff_pp_last2ms_mV"] < 20)
    return m


def plot_step(s, n, label, path, lims, tmin, tmax, marks):
    t = s[TIME] * 1e3
    fig, axes = plt.subplots(5, 1, figsize=(12, 15), sharex=True, gridspec_kw={"height_ratios": [1, 1.5, 1.5, 1.5, 1.5]})
    a_tri, a_vpr, a_vdf, a_cmp, a_rst = axes
    fig.suptitle(f"Step {n}: {label}")

    a_tri.plot(t, s[TRI], color="#8c564b", lw=2)
    a_tri.set_title("Light level (tri, decades above 10 fA)")
    a_tri.set_ylabel("tri")

    a_vpr.plot(t, s[VPR], color="#1f77b4", lw=2, label="Vpr")
    a_vpr.set_ylabel("Vpr (V)")
    a_vpr.set_ylim(*lims[VPR])
    a2 = a_vpr.twinx()
    a2.plot(t, s[VPD], color="#ff7f0e", lw=2, label="Vpd")
    a2.set_ylabel("Vpd (V)")
    a2.set_ylim(*lims[VPD])
    a_vpr.set_title("Vpr (left) and Vpd (right)")
    a_vpr.legend(loc="upper left", frameon=False)
    a2.legend(loc="upper right", frameon=False)

    a_vdf.plot(t, s[VDIFF], color="#2ca02c", lw=2)
    a_vdf.set_title("Vdiff")
    a_vdf.set_ylabel("Vdiff (V)")
    a_vdf.set_ylim(*lims[VDIFF])

    a_cmp.plot(t, s[VON], color="#9467bd", lw=2, label="VON")
    a_cmp.plot(t, s[VNOFF], color="#17becf", lw=2, ls="--", label="VnOFF")
    a_cmp.set_title("VON and VnOFF")
    a_cmp.set_ylabel("Voltage (V)")
    a_cmp.set_ylim(-0.05, 1.9)
    a_cmp.legend(loc="center right", frameon=False)

    a_rst.plot(t, s[VRESET], color="red", lw=3, label="Vreset")
    a_rst.plot(t, s[VNRST], color="#8c564b", lw=2, label="VnRstChAmp")
    a_rst.set_title("Reset: Vreset and VnRstChAmp")
    a_rst.set_ylabel("Voltage (V)")
    a_rst.set_ylim(-0.05, 1.9)
    a_rst.set_xlabel("Time (ms)")
    a_rst.legend(loc="center right", frameon=False)

    for ax in axes:
        ax.grid(True, alpha=0.4)
        ax.set_xlim(tmin, tmax)
        for tm in marks:
            ax.axvline(tm, color="#7f7f7f", ls=":", lw=1)
    fig.tight_layout()
    fig.savefig(path, dpi=100)
    plt.close(fig)


def plot_summary(name, vals, ms, vth, path):
    x = np.array(vals, dtype=float)
    g = lambda k: np.array([m[k] for m in ms], dtype=float)
    fig, ax = plt.subplots(5, 1, figsize=(10, 16), sharex=True)
    ax[0].plot(x, g("on_events"), "o-", label="ON events (VON rising)", color="#9467bd")
    ax[0].plot(x, g("off_events"), "s--", label="OFF events (VnOFF falling)", color="#17becf")
    ax[0].plot(x, g("rst_on"), "o-", label="reset pulses after the up step", color="#8c564b")
    ax[0].plot(x, g("rst_off"), "s--", label="reset pulses after the down step", color="#8c564b", alpha=0.6)
    ax[0].plot(x, g("spurious"), "^:", label="spurious events", color="#d62728")
    ax[0].axhline(1, color="#7f7f7f", lw=0.8, ls=":")
    ax[0].set_ylabel("events per step")
    ax[0].set_title("Event counts (expected: 1 ON, 1 OFF, 0 spurious); reset pulses = VnRstChAmp falling")
    ax[0].legend(frameon=False)
    ax[1].plot(x, g("on_peak"), "o-", color="#9467bd", label="highest VON after the up step")
    ax[1].plot(x, g("off_min"), "s--", color="#17becf", label="lowest VnOFF after the down step")
    ax[1].axhline(vth, color="#7f7f7f", lw=0.8, ls=":")
    ax[1].set_ylabel("voltage (V)")
    ax[1].set_title(f"How far the comparators swing (dotted: {vth:g} V event threshold)")
    ax[1].legend(frameon=False)
    ax[2].plot(x, g("on_latency_us"), "o-", color="#9467bd", label="ON latency")
    ax[2].plot(x, g("off_latency_us"), "s--", color="#17becf", label="OFF latency")
    ax[2].plot(x, g("rst_on_latency_us"), "o-", color="#8c564b", label="reset pulse after the up step")
    ax[2].plot(x, g("rst_off_latency_us"), "s--", color="#8c564b", alpha=0.6, label="reset pulse after the down step")
    ax[2].set_ylabel("latency after step (us)")
    ax[2].set_title("Time from the light step to the event (gaps = no event)")
    ax[2].legend(frameon=False)
    ax[3].plot(x, g("vdiff_idle"), "o-", color="#2ca02c", label="Vdiff idle")
    ax[3].plot(x, g("vnrst_up"), "o-", color="#8c564b", label="VnRstChAmp at the up step")
    ax[3].plot(x, g("vnrst_down"), "s--", color="#8c564b", label="VnRstChAmp at the down step")
    ax[3].set_ylabel("level (V)")
    ax[3].set_title("Idle Vdiff and the reset state when each light step arrives (low VnRstChAmp = champ still in reset)")
    ax[3].legend(frameon=False)
    ax[4].plot(x, g("dvdiff_on_mV"), "o-", color="#9467bd", label="Vdiff change after the up step")
    ax[4].plot(x, g("dvdiff_off_mV"), "s--", color="#17becf", label="Vdiff change after the down step")
    ax[4].set_ylabel("change in Vdiff (mV)")
    ax[4].set_title("Vdiff excursion caused by each step")
    ax[4].legend(frameon=False)
    ax[4].set_xlabel(f"{name} (V)" if name != "step" else "step")
    for a in ax:
        a.grid(True, alpha=0.4)
    fig.tight_layout()
    fig.savefig(path, dpi=100)
    plt.close(fig)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--csv", default="tb_all_one_event.csv")
    ap.add_argument("--out", default="sweep_plots")
    ap.add_argument("--netlist", help="netlist whose active .step line labels the steps (default: the CSV name with .sp)")
    ap.add_argument("--sweep", help="NAME=v1,v2,... labels for the steps when the CSV has no bias columns")
    ap.add_argument("--tmin", type=float, default=0.0, help="plot window start, ms")
    ap.add_argument("--tmax", type=float, default=None, help="plot window end, ms (default: whole run)")
    ap.add_argument("--vth", type=float, default=0.9, help="event threshold on VON / VnOFF, V")
    ap.add_argument("--hyst", type=float, default=0.05, help="hysteresis around the threshold when counting events, V")
    ap.add_argument("--no-plots", action="store_true", help="only write the summary")
    args = ap.parse_args()

    steps = load(args.csv)
    netlist = args.netlist or str(Path(args.csv).with_suffix(".sp"))
    name, vals, swept = sweep_labels(steps, args.sweep, netlist)
    out = Path(args.out) / name
    out.mkdir(parents=True, exist_ok=True)
    tmax = args.tmax if args.tmax is not None else max(s[TIME][-1] for s in steps) * 1e3

    ms = [measure(s, args.vth, args.hyst) for s in steps]

    # summary table
    cols = ["step", name, "rows", "idle_vdiff", "idle_von", "idle_vnoff", "vnrst_at_up", "vnrst_at_down",
            "on_events", "on_peak", "on_latency_us", "dvdiff_on_mV", "off_events", "off_min", "off_latency_us",
            "dvdiff_off_mV", "reset_after_up", "reset_after_up_latency_us", "reset_after_down",
            "reset_after_down_latency_us", "spurious", "vdiff_pp_last2ms_mV", "settled"]
    with open(out / "summary.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(cols)
        for n, (v, m) in enumerate(zip(vals, ms), start=1):
            w.writerow([n, v, m["rows"], f'{m["vdiff_idle"]:.4f}', f'{m["von_idle"]:.4f}', f'{m["vnoff_idle"]:.4f}',
                        f'{m["vnrst_up"]:.3f}', f'{m["vnrst_down"]:.3f}',
                        m["on_events"], f'{m["on_peak"]:.3f}', f'{m["on_latency_us"]:.1f}', f'{m["dvdiff_on_mV"]:.1f}',
                        m["off_events"], f'{m["off_min"]:.3f}', f'{m["off_latency_us"]:.1f}', f'{m["dvdiff_off_mV"]:.1f}',
                        m["rst_on"], f'{m["rst_on_latency_us"]:.1f}', m["rst_off"], f'{m["rst_off_latency_us"]:.1f}',
                        m["spurious"], f'{m["vdiff_pp_last2ms_mV"]:.1f}', m["settled"]])
    print(f"{'step':>4} {name:>8} {'rows':>7} {'Vdiff0':>7} {'VnRst0':>7} {'ON':>3} {'VONpk':>6} {'lat_us':>8} {'dVd_mV':>7} "
          f"{'OFF':>4} {'VnOFFmin':>8} {'lat_us':>8} {'dVd_mV':>7} {'rst@up':>6} {'lat_us':>7} {'rst@dn':>6} {'lat_us':>7} {'extra':>6} {'pp_mV':>7} settled")
    for n, (v, m) in enumerate(zip(vals, ms), start=1):
        print(f"{n:>4} {v:>8g} {m['rows']:>7d} {m['vdiff_idle']:>7.3f} {m['vnrst_up']:>7.3f} {m['on_events']:>3d} "
              f"{m['on_peak']:>6.3f} {m['on_latency_us']:>8.1f} {m['dvdiff_on_mV']:>7.1f} {m['off_events']:>4d} "
              f"{m['off_min']:>8.3f} {m['off_latency_us']:>8.1f} {m['dvdiff_off_mV']:>7.1f} "
              f"{m['rst_on']:>6d} {m['rst_on_latency_us']:>7.1f} {m['rst_off']:>6d} {m['rst_off_latency_us']:>7.1f} {m['spurious']:>6d} "
              f"{m['vdiff_pp_last2ms_mV']:>7.1f} {m['settled']}")
    plot_summary(name, vals, ms, args.vth, out / "summary.png")
    print(out / "summary.png")

    if args.no_plots:
        return
    # shared y limits over the plotted window of every step
    def lim(col):
        v = np.concatenate([s[col][(s[TIME] * 1e3 >= args.tmin) & (s[TIME] * 1e3 <= tmax)] for s in steps])
        pad = 0.05 * (v.max() - v.min() or 1)
        return v.min() - pad, v.max() + pad

    lims = {c: lim(c) for c in (VPR, VPD, VDIFF)}
    for n, (s, m) in enumerate(zip(steps, ms), start=1):
        label = ", ".join(f"{nm} = {vv[n - 1]:g} V" for nm, vv in swept) if name != "step" else f"step {n}"
        fname = "_".join(f"{nm}={vv[n - 1]:g}" for nm, vv in swept) if name != "step" else f"step{n}"
        path = out / f"step_{n}_{fname}.png"
        plot_step(s, n, label, path, lims, args.tmin, tmax, (m["t_up_ms"], m["t_down_ms"]))
        print(path)


if __name__ == "__main__":
    main()
