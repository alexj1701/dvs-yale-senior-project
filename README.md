# An Event-Based Imager

A Yale EECS Senior project by Alex Johnson: the design of an event-based image sensor
(a dynamic vision sensor, or "event camera") pixel in the SkyWater SKY130 process.

Unlike a conventional camera, which captures full frames at a fixed rate, each pixel in an
event camera works independently and reports only *changes* in brightness. When the log
intensity at a pixel rises or falls by more than a set contrast threshold, the pixel emits
an ON or OFF event. This gives very high temporal resolution, wide dynamic range, and low
data rates for mostly static scenes.

The pixel design follows the architecture of **SciDVS** (Graça, Zhou, McReynolds and Delbruck,
*"SciDVS: A Scientific Event Camera with 1.7% Temporal Contrast Sensitivity at 0.7 lux"*,
[arXiv:2409.09648](https://arxiv.org/abs/2409.09648)). The plan is to build and verify a basic
DVS pixel first, then add the SciDVS improvements.

**Advisor:** Rajit Manohar

## Pixel signal chain

1. **Logarithmic photoreceptor:** converts photocurrent into a voltage proportional to log intensity.
2. **Change amplifier:** capacitive-gain amplifier that measures the change in log intensity since the last event.
3. **ON/OFF comparators:** fire when the change crosses the ON or OFF threshold.
4. **Reset logic** (`reset.act`): resets the change amplifier after each event, once acknowledged.

Planned SciDVS improvements: an auto-centering preamplifier and a programmable low-pass
buffer between the photoreceptor and the change amplifier.

## Tools

- **[ACT](https://avlsi.csl.yale.edu/act/)**: circuit description; the SPICE netlist is generated from the ACT source
- **[Xyce](https://xyce.sandia.gov/)**: circuit simulation
- **SKY130** process models (`sky130l` configuration)
- **gnuplot**: plotting simulation output
- **Python** (matplotlib, numpy): per-step plots of swept simulations (`Tests/bias/plot_sweep.py`)

ACT, Xyce and gnuplot run in a Docker container based on the `rajitmanohar/act_sky130` image.

## Repository layout

| Path | Purpose |
|---|---|
| `pixel.act` | Top-level pixel: connects the photoreceptor, change amplifier, comparators and reset |
| `cells/` | ACT cells: `photoreceptor.act`, `champ.act`, `comparators.act`, `reset.act`, and `aps.act` (a 4T global-shutter active pixel sensor, not part of the DVS signal chain) |
| `pixel.spice` | Pixel netlist **generated from ACT**; do not edit by hand (see below) |
| `common.inc` | Shared include for every test: simulator options, supplies, SKY130 models and `pixel.spice` |
| `Tests/bias/` | Full-pixel transient tests: `BiasHarness.sp` (biases, log-intensity photocurrent, reset stand-in), `tb_all_fast.sp` and `tb_all_fast_small.sp` (fast photocurrent steps), plus their plot scripts and `plot_sweep.py` |
| `Tests/tb_photoreceptor/` | Photoreceptor DC tests, one folder each (see below) |
| `prs2net.conf`, `commands` | Netlist-generation configuration and the commands used |
| `netlist`, `plotcmds`, `test.plot`, `TestHarness.sp` | Older files from early work, kept for reference |
| `AI_USAGE.md` | Detailed record of how AI was used |

The pixel netlist contains only the circuit. Everything that belongs to an experiment
(light stimulus, bias sources, sweeps, the stand-in for the not-yet-built arbiter) lives in
the harness files, so the same tests can be rerun unchanged on the extracted layout.

## Generating the netlist

`pixel.spice` is produced from the ACT source and must be regenerated after any change to
`pixel.act` or `cells/*.act`:

```bash
prs2net -d -cnf=prs2net.conf -Tsky130l -p pixel pixel.act > pixel.spice
```


## Running the simulations

Each test is self-contained and is run from its own folder, so its output files land next to it:

```bash
cd Tests/bias
Xyce BiasHarness.sp          # transient run; writes bias.plot and bias.csv
gnuplot bias_plot.gp         # writes bias_plot.png
python plot_sweep.py         # used when runnng a sweep; one PNG per .step value, in sweep_plots/

cd ../tb_photoreceptor/ipr_vs_vipr_dc # and other DC tests
Xyce tb_ipr_vs_vipr_dc.sp    # DC sweep of Vipr; writes ipr.csv
gnuplot ipr_plot.gp          # writes ipr_plot.png
```

Bias values and sweeps are set with the `.param` and `.step` lines
near the top of each netlist. Generated CSV, plot and `.res` files are not tracked by git.

## Test approach

The light input is modeled as a photocurrent pulled from the photodiode node, swept as a
triangle in **log** intensity (from dark current up several decades and back). A working
pixel produces evenly spaced ON events on the rising ramp and evenly spaced OFF events on
the falling ramp; the spacing gives the contrast threshold. Each bias is then swept to find
its working range.

Tests available so far:

| Test | Question it answers |
|---|---|
| `tb_photoreceptor/ipr_vs_{vipr,vgfb,vcasc}_dc` | How the pull-up current and `Vpr` vary with `Vipr`, stepped over `Vg_fb` or `Vcasc` |
| `tb_photoreceptor/iph_vs_{vipr,vgfb,vcasc}_dc` | How `Vpr`, `Vpd` and the pull-up current respond to photocurrent (DC), stepped over each bias |
| `tb_photoreceptor/iph_set_point_dc` | The same photocurrent response at one fixed bias set point |
| `tb_photoreceptor/collapse_grid_dc` | Where the response runs out of headroom, over a grid of `Vipr` and `Vg_fb` |
| `bias/BiasHarness.sp` | Transient behavior over a slow log ramp, and bias sweeps with `.step` |
| `bias/tb_all_fast`, `tb_all_fast_small` | Ringing and settling after fast photocurrent steps (1 us edges), large and small contrast |

DC sweeps hold the capacitors open, so they show the static response only; stability and
settling have to be checked in the transient tests.

## Status

- [x] Test harness with log-intensity stimulus and reset stand-in
- [ ] Photoreceptor bias characterization (in progress: stability and supply headroom at 1.8 V; 3.3 V devices under consideration)
- [ ] Change amplifier and comparator bias characterization
- [ ] Layout and post-layout simulation
- [ ] Pixel array and periphery (arbitration and readout)
- [ ] SciDVS improvements

## AI usage disclosure

Claude (Anthropic) was used during this project for writing the test harnesses, plot
scripts and shared include files under `Tests/` (and running them to check they work), for
reading large simulation output files and reporting numbers from them at the author's
direction, and for drafting documentation, including the initial draft of this README. The circuit design (the ACT
cells), the choice of what to simulate (including specifications and parameters), the interpretation of results and the design decisions
are the author's own. Some
commits list Claude as a co-author. See [`AI_USAGE.md`](AI_USAGE.md) for the detailed record.
