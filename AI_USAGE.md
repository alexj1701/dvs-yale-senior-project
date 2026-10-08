# AI use in this project

This note describes how an AI assistant (Claude, through the Claude Code desktop app) was used for the pixel bias-optimization work. It is a draft written from the conversation record. Items in [brackets] are things only the project author can fill in or confirm.

## Summary

The AI was used as a tool for building and running simulation test harnesses, writing plotting and analysis scripts, and reading large simulation output files. The circuit design, the choice of what to test, the interpretation of results and the decisions about bias values were made by the project author. Partway through, the author asked the AI to act as an advisor who asks guiding questions instead of supplying answers, unless asked directly.

## Ground rules set by the author

- The bias optimization was restarted from an earlier chat. The author asked the AI not to reuse the values found there and said they wanted to do the analysis and thinking themselves.
- The AI's job was to build test harnesses and, when asked, write Python scripts to analyze the data.
- Later (2026-10-08) the author asked the AI to take an advisor role: ask guiding questions more often than giving the reason or the solution, unless explicitly asked. Analyzing large CSV files for the author was still welcome.

## What the AI did

| Area | AI contribution |
|---|---|
| Test harnesses | Wrote the Xyce netlists: a shared `common.inc`; DC sweeps of `Vipr`, `Vg_fb` and `Vcasc`; photocurrent DC sweeps; a `Vipr` x `Vg_fb` collapse-point grid; a full-pixel transient harness with a `.step` bias sweep, a start-up and delayed-event reset, and a log-scale photocurrent source; and two fast-step tests (`tb_all_fast`, `tb_all_fast_small`). |
| Plotting | Wrote the gnuplot scripts for each test and `plot_sweep.py` (one PNG per sweep step). |
| Running tests | Ran the netlists in the Docker container to check that they worked, and viewed the plots. |
| Data analysis | Read large CSV outputs and reported numbers, for example the `Vipr` that gives 30, 100 and 240 nA of pull-up current, `Vpr` log slopes, collapse points, oscillation period versus photocurrent, and ringing after fast edges. |
| Diagnosis support | Offered hypotheses and ran scratch experiments to test them (for example, that the oscillation lives in the photoreceptor and not the champ; the effect of extra capacitance on `Vpr`; the effect of `Mgfb` width). Pointed out discrepancies in the netlist (a 20 pF versus 200 fF champ capacitor, `prs2net` run without `-d`, a stale `pixel.spice`). |
| Repository work | Organized the tests into `Tests/` and `Tests/tb_photoreceptor/`, updated include paths, wrote the commit, and drafted the pull request text. |

## What the author did

- Designed the circuit (the ACT cells and their sizing) and made the circuit edits: the champ capacitor fix, `Mgfb` sizing, and the photodiode capacitance.
- Regenerated `pixel.spice` with `prs2net` and ran the simulations in the container.
- Decided what to test and what to ignore, including holding the event path off while tuning the photoreceptor and keeping the 1 us edge time for the fast-step test.
- Chose the bias values and judged stability (for example, finding that `Vg_fb` below 1.0 V is unstable) and what dynamic range is acceptable.
- Reviewed results, accepted or rejected the AI's suggestions, and set the direction for each next step.
- [Add anything else, such as lab or advisor input, hand calculations, or layout work.]

## How AI output was checked

- Test netlists were run in Xyce in the container, and plots were viewed before being reported.
- Hypotheses were presented as hypotheses and tested with scratch simulations where possible; some were not tested (for example, that the oscillation is a relaxation oscillator on the `Vpd` node).
- [Describe your own checks, such as hand calculations or comparison with expected photoreceptor behavior.]

## Mistakes and limitations noticed

These are errors from the AI that were caught and fixed during the work, listed so the record is honest:

- A first attempt to probe the pull-up transistor current named a subcircuit instance, not the underlying MOSFET, and failed. The correct hierarchical name was found by reading the PDK model files.
- An analysis script used the wrong CSV column in one pass; the numbers were rechecked and corrected before being reported.
- An edit to a gnuplot script corrupted the file and had to be rewritten.
- Test runs were first made as the container's root user, which left output files the author's account could not overwrite ("failed to open iph.csv"). Permissions were fixed and later runs used the author's user.
- Several DC conclusions apply only to the dark-current starting point (10 fA), where Xyce lands on a different solution than just above it, and DC results do not show dynamic instability. Transient tests were needed to find the oscillation.
- The AI could not run `gh`, so it did not open the pull request itself.

## Reproducibility

- Tools: Claude Code desktop app, Claude [model name and version for each session], Xyce 7.10 and gnuplot inside the Docker container, Python with matplotlib and numpy on the host.
- AI-written files: `common.inc`, everything under `Tests/` (`*.sp`, `*.gp`, `plot_sweep.py`), and this note. The commit is tagged with a `Co-Authored-By` trailer for the assistant.
- Not AI-written: the ACT cell sources and the circuit decisions described above. [Confirm.]
- [Dates and number of sessions, plus the earlier chat the work was restarted from, if the course or advisor wants them.]
