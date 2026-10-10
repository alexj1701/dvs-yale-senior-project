# Plots tb_all_one_event.csv from tb_all_one_event.sp: one ON event and one OFF event.
# Columns: 1 = time, 2 = v(tri), 3 = i(Bph), 4 = Vpd, 5 = Vpr, 6 = Vdiff, 7 = VON, 8 = VnOFF,
#          9 = VnRstChAmp, 10 = Vreset, 11 = nev, 12 = ndly
# Panels (shared time axis): light level, Vpr (with Vpd), Vdiff, comparator outputs, reset signals.
#
# Time window to show, in ms. Zoom on an event with e.g. t0 = 5.9, t1 = 9 (ON) or t0 = 19.9, t1 = 23 (OFF).
t0 = 0
t1 = 34

set terminal pngcairo size 1200,1500
set output "tb_all_one_event.png"
set datafile separator ","

set style data lines
set grid
set xrange [t0:t1]
set key outside right nobox spacing 1.3
set lmargin at screen 0.09
set rmargin at screen 0.80

set multiplot title "One ON event and one OFF event, full pixel"

# ---- light level ----
set tmargin at screen 0.95
set bmargin at screen 0.79
set title "Light level (tri, decades above 10 fA)"
set ylabel "tri (decades)"
set format x ""
unset xlabel
plot 'tb_all_one_event.csv' skip 1 using ($1*1e3):2 lw 2 lc rgb "#8c564b" title "tri"

# ---- Vpr (left) and Vpd (right) ----
set tmargin at screen 0.73
set bmargin at screen 0.57
set title "Vpr (left) and Vpd (right)"
set ylabel "Vpr (V)"
set y2label "Vpd (V)"
set ytics nomirror
set y2tics
plot 'tb_all_one_event.csv' skip 1 using ($1*1e3):5 axes x1y1 lw 2 lc rgb "#1f77b4" title "Vpr", \
     'tb_all_one_event.csv' skip 1 using ($1*1e3):4 axes x1y2 lw 2 lc rgb "#ff7f0e" title "Vpd"
unset y2label
unset y2tics
set ytics mirror

# ---- Vdiff ----
set tmargin at screen 0.51
set bmargin at screen 0.35
set title "Vdiff"
set ylabel "Vdiff (V)"
plot 'tb_all_one_event.csv' skip 1 using ($1*1e3):6 lw 2 lc rgb "#2ca02c" title "Vdiff"

# ---- comparator outputs ----
set tmargin at screen 0.29
set bmargin at screen 0.19
set title "VON and VnOFF"
set ylabel "Voltage (V)"
set yrange [0:1.9]
plot 'tb_all_one_event.csv' skip 1 using ($1*1e3):7 lw 2 lc rgb "#9467bd" title "VON", \
     'tb_all_one_event.csv' skip 1 using ($1*1e3):8 lw 2 dt 2 lc rgb "#17becf" title "VnOFF"

# ---- reset signals ----
set tmargin at screen 0.13
set bmargin at screen 0.04
set title "Reset: Vreset and VnRstChAmp"
set xlabel "Time (ms)"
set ylabel "Voltage (V)"
set format x "%g"
plot 'tb_all_one_event.csv' skip 1 using ($1*1e3):10 lw 3 lc rgb "red" title "Vreset", \
     'tb_all_one_event.csv' skip 1 using ($1*1e3):9 lw 2 lc rgb "#8c564b" title "VnRstChAmp"

unset multiplot
set output
