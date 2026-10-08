"""Plot each .step of a stepped BiasHarness.sp run as its own PNG.

Reads bias.csv (all steps concatenated; time restarts at 0 for each step) and writes
sweep_plots/<swept bias>/step_<n>_<bias>=<value>.png using the same three-panel layout as bias_plot.gp:
pixel signals, bias voltages + Vpd, photocurrent. Y limits are shared across steps so the
images can be compared directly.

    python plot_sweep.py                 # first 5 ms of each step
    python plot_sweep.py --tmax 200      # whole run
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

SIGNALS = [  # (column, label, kwargs)
    ("V(XPIXEL:VPR)", "Vpr", {}),
    ("V(XPIXEL:VDIFF)", "Vdiff", {}),
    ("V(VON)", "VON", {}),
    ("V(VNOFF)", "VnOFF", {}),
    ("V(XPIXEL:VNRSTCHAMP)", "VnRstChAmp", {}),
    ("V(VRESET)", "Vreset", {"color": "red", "lw": 3}),
]
BIASES = [
    ("V(VCASC)", "Vcasc"),
    ("V(VG_FB)", "Vg_fb"),
    ("V(VIPR)", "Vipr"),
    ("V(VIDIFF)", "Vidiff"),
    ("V(VION)", "VIon"),
    ("V(VIOFF)", "VIoff"),
]


def load(path):
    with open(path, newline="") as f:
        rows = list(csv.reader(f))
    header = [c.strip().upper() for c in rows[0]]
    data = np.array([[float(x) for x in r] for r in rows[1:] if r])
    cols = {name: data[:, i] for i, name in enumerate(header)}
    t = cols["TIME"]
    # a new step starts wherever time goes backwards
    starts = [0] + [i for i in range(1, len(t)) if t[i] < t[i - 1]] + [len(t)]
    steps = [{k: v[a:b] for k, v in cols.items()} for a, b in zip(starts, starts[1:])]
    return steps


def swept_biases(steps):
    """Bias columns whose value differs between steps, with each step's value."""
    swept = []
    for col, label in BIASES:
        vals = [s[col][len(s[col]) // 2] for s in steps]
        if max(vals) - min(vals) > 1e-9:
            swept.append((col, label, vals))
    return swept


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", default="bias.csv")
    ap.add_argument("--out", default="sweep_plots")
    ap.add_argument("--tmax", type=float, default=200.0, help="x-axis limit in ms")
    args = ap.parse_args()

    steps = load(args.csv)
    swept = swept_biases(steps)
    # one folder per swept bias (e.g. sweep_plots/Vipr), so sweeps of different biases stay apart
    out = Path(args.out) / ("_".join(label for _, label, _ in swept) or "run")
    out.mkdir(parents=True, exist_ok=True)

    # shared y limits over the visible window of every step
    def window(s):
        return s["TIME"] * 1e3 <= args.tmax

    def limits(cols, transform=lambda a: a):
        vals = np.concatenate([transform(s[c][window(s)]) for s in steps for c in cols])
        vals = vals[np.isfinite(vals)]
        return vals.min(), vals.max()

    sig_lim = limits([c for c, _, _ in SIGNALS])
    bias_lim = limits([c for c, _ in BIASES] + ["V(VPD)"])
    cur_lim = limits(["I(BPH)"], lambda a: np.abs(a[a != 0]))
    pad = lambda lo, hi: (lo - 0.05 * (hi - lo), hi + 0.05 * (hi - lo))

    for n, s in enumerate(steps, start=1):
        t = s["TIME"] * 1e3
        tag = ", ".join(f"{label} = {vals[n - 1]:g} V" for _, label, vals in swept) or f"step {n}"
        fname = "_".join(f"{label}={vals[n - 1]:g}" for _, label, vals in swept) or "run"

        fig, (a1, a2, a3) = plt.subplots(
            3, 1, figsize=(12, 13), sharex=True, gridspec_kw={"height_ratios": [2, 2, 1]}
        )
        fig.suptitle(f"Step {n}: {tag}")

        for col, label, kw in SIGNALS:
            a1.plot(t, s[col], label=label, **{"lw": 2, **kw})
        a1.set_title("Pixel signals")
        a1.set_ylabel("Voltage (V)")
        a1.set_ylim(*pad(*sig_lim))

        for col, label in BIASES:
            a2.plot(t, s[col], label=label, lw=2)
        a2.plot(t, s["V(VPD)"], label="Vpd (node voltage)", color="black", ls="--", lw=2)
        a2.set_title("Bias voltages and Vpd node")
        a2.set_ylabel("Voltage (V)")
        a2.set_ylim(*pad(*bias_lim))

        a3.semilogy(t, np.abs(s["I(BPH)"]), color="#8c564b", lw=2, label="I_ph")
        a3.set_title("Photocurrent")
        a3.set_ylabel("Photocurrent (A)")
        a3.set_xlabel("Time (ms)")
        a3.set_ylim(cur_lim[0] / 2, cur_lim[1] * 2)

        for ax in (a1, a2, a3):
            ax.grid(True, alpha=0.4)
            ax.set_xlim(0, args.tmax)
            ax.legend(loc="center left", bbox_to_anchor=(1.01, 0.5), frameon=False)

        fig.tight_layout()
        path = out / f"step_{n}_{fname}.png"
        fig.savefig(path, dpi=100)
        plt.close(fig)
        print(path)


if __name__ == "__main__":
    main()
