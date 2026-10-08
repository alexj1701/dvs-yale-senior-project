# Plots tb_all_fast_small.csv from tb_all_fast_small.sp.
# Columns: 1 = time, 2 = v(tri), 3 = i(Bph), 4 = Vpd, 5 = Vpr, 6 = Vdiff, 7 = VON, 8 = VnOFF, 9 = VnRstChAmp, 10 = Vreset
# Panels (shared time axis): light level (decades), Vpr and Vpd, Vdiff, comparator outputs and reset.
#
# Time window to show, in ms. Zoom on one edge to look for ringing, e.g. t0 = 5.9, t1 = 6.4
# (block 1 at 10 pA: edges at 6, 10, 14, 18, 22, 26 ms; block 2 at 1 nA: 40, 44, 48, 52, 56, 60 ms).
t0 = 0
t1 = 66

set terminal pngcairo size 1200,1500
set output "tb_all_fast_small.png"
set datafile separator ","

set style data lines
set grid
set xrange [t0:t1]
set key outside right nobox spacing 1.3
set lmargin at screen 0.09
set rmargin at screen 0.80

set multiplot title "Small-contrast fast steps (1 us edges), full pixel"

# ---- light level: tri, decades above 10 fA ----
set tmargin at screen 0.95
set bmargin at screen 0.77
set title "Light level (tri, decades above 10 fA)"
set ylabel "tri (decades)"
set format x ""
unset xlabel
plot 'tb_all_fast_small.csv' skip 1 using ($1*1e3):2 lw 2 lc rgb "#8c564b" title "tri"

# ---- Vpr (left axis) and Vpd (right axis) ----
set tmargin at screen 0.71
set bmargin at screen 0.50
set title "Vpr (left) and Vpd (right)"
set ylabel "Vpr (V)"
set y2label "Vpd (V)"
unset logscale y
set format y "%g"
set ytics nomirror
set y2tics
plot 'tb_all_fast_small.csv' skip 1 using ($1*1e3):5 axes x1y1 lw 2 lc rgb "#1f77b4" title "Vpr", \
     'tb_all_fast_small.csv' skip 1 using ($1*1e3):4 axes x1y2 lw 2 lc rgb "#ff7f0e" title "Vpd"
unset y2label
unset y2tics
set ytics mirror

# ---- Vdiff ----
set tmargin at screen 0.44
set bmargin at screen 0.27
set title "Vdiff"
set ylabel "Vdiff (V)"
plot 'tb_all_fast_small.csv' skip 1 using ($1*1e3):6 lw 2 lc rgb "#2ca02c" title "Vdiff"

# ---- comparators and reset ----
set tmargin at screen 0.21
set bmargin at screen 0.06
set title "VON, VnOFF, VnRstChAmp, Vreset"
set xlabel "Time (ms)"
set ylabel "Voltage (V)"
set format x "%g"
plot 'tb_all_fast_small.csv' skip 1 using ($1*1e3):7 lw 2 lc rgb "#9467bd" title "VON", \
     'tb_all_fast_small.csv' skip 1 using ($1*1e3):8 lw 2 lc rgb "#17becf" title "VnOFF", \
     'tb_all_fast_small.csv' skip 1 using ($1*1e3):9 lw 2 lc rgb "#8c564b" title "VnRstChAmp", \
     'tb_all_fast_small.csv' skip 1 using ($1*1e3):10 lw 3 lc rgb "red" title "Vreset"

unset multiplot
set output
