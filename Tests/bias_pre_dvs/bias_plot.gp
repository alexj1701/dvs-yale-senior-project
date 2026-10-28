# Reads bias.plot written by BiasHarness.sp. Column 2 = time, then in .print order:
#  3 Vcasc  4 Vg_fb  5 Vipr  6 Vidiff  7 VIon  8 VIoff  9 Vreset  10 Vpd
# 11 Vpr  12 Vdiff  13 VON  14 VnOFF  15 i(Bph) photocurrent  16 VnRstChAmp
set terminal pngcairo size 1200,1800
set output "bias_plot.png"

set style data lines
# time window to show (ms); set tmax = 200 for the whole run
tmax = 200
set xrange [0:tmax]
set xtics autofreq
set grid
set key outside right nobox spacing 1.3

# Fixed left/right edges (screen fractions) so every panel has the same plot width,
# regardless of legend width or y-axis label width.
set lmargin at screen 0.09
set rmargin at screen 0.80

set multiplot title "Pixel behavior with full circuit attached"

# ---- top: pixel signals ----
set tmargin at screen 0.93
set bmargin at screen 0.71
set title "Pixel signals"
set ylabel "Voltage (V)"
set format x ""
unset xlabel
plot 'bias.plot' using ($2*1e3):13 title 'VON'   lw 2 lc rgb "#AE40DE", \
    'bias.plot' using ($2*1e3):14 title 'VnOFF' lw 2

# ---- Vdiff: its own panel, between the pixel signals and the reset panel ----
set tmargin at screen 0.675
set bmargin at screen 0.56
set title "Vdiff"
set ylabel "Voltage (V)"
set format x ""
unset xlabel
plot 'bias.plot' using ($2*1e3):12 title 'Vdiff' lw 2 lc rgb "#2ca02c"

# ---- reset signals: a short panel (about 0.4 of the top one's height) under Vdiff ----
set tmargin at screen 0.525
set bmargin at screen 0.43
set title "Reset: Vreset and VnRstChAmp"
set ylabel "Voltage (V)"
set yrange [0:1.9]
set ytics 0,0.6,1.8
plot 'bias.plot' using ($2*1e3):9  title 'Vreset' \
    lw 2 lc rgb "red", \
    'bias.plot' using ($2*1e3):16 title 'VnRstChAmp' lw 2 lc rgb "#8c564b"
set autoscale y
set ytics autofreq

# ---- middle: bias voltages and Vpd node ----
set tmargin at screen 0.395
set bmargin at screen 0.215
set autoscale y
set title "Bias voltages and Vpr, Vpd nodes"
plot 'bias.plot' using ($2*1e3):3  title 'Vcasc'      lw 2, \
     'bias.plot' using ($2*1e3):4  title 'Vg\_fb'     lw 2, \
     'bias.plot' using ($2*1e3):5  title 'Vipr'       lw 2, \
     'bias.plot' using ($2*1e3):6  title 'Vidiff'     lw 2, \
     'bias.plot' using ($2*1e3):7  title 'VIon'       lw 2, \
     'bias.plot' using ($2*1e3):8  title 'VIoff'      lw 2, \
     'bias.plot' using ($2*1e3):10 title 'Vpd (node voltage)' lw 2 dt 2 lc rgb "black", \
     'bias.plot' using ($2*1e3):11 title 'Vpr'   lw 2

# ---- bottom: photocurrent (log scale), carries the x-axis label ----
set tmargin at screen 0.18
set bmargin at screen 0.075
set title "Photocurrent"
set ylabel "Photocurrent (A)"
set xlabel "Time (ms)"
set format x "%g"
set logscale y
set format y "10^{%L}"
plot 'bias.plot' using ($2*1e3):(abs($15)) title 'I_{ph}' lw 2 lc rgb "#8c564b"

unset multiplot
set output
