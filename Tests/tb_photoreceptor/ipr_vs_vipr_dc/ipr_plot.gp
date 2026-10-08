# Plots ipr.csv from tb_ipr_vs_vipr.sp: drain current of the Vipr pull-up pFET (left axis, log)
# and Vpr (right axis) vs Vipr.
# Columns: 1 = V(Vipr), 2 = V(xpixel:vpr), 3 = Id of xpixel:xpr0:xM0_N (abs() so the sign doesn't matter)
set terminal pngcairo size 1100,700
set output "ipr_plot.png"

set datafile separator ","
set title "Pull-up pFET current and Vpr vs Vipr (DC sweep)"
set xlabel "Vipr (V)"
set autoscale xfix
set ylabel "Drain current (A)"
set logscale y
set format y "10^{%L}"
set grid xtics ytics mytics
set mytics 10
set y2label "Vpr (V)"
set y2range [0:1.9]
set y2tics
set key top right nobox

# reference currents to read Vipr off the curve
set arrow 1 from graph 0, first 1e-8 to graph 1, first 1e-8 nohead dt 2 lc rgb "#7f7f7f"
set arrow 2 from graph 0, first 3e-8 to graph 1, first 3e-8 nohead dt 2 lc rgb "#7f7f7f"
set arrow 3 from graph 0, first 1e-7 to graph 1, first 1e-7 nohead dt 2 lc rgb "#7f7f7f"
set arrow 4 from graph 0, first 3e-7 to graph 1, first 3e-7 nohead dt 2 lc rgb "#7f7f7f"
set arrow 5 from graph 0, first 1e-6 to graph 1, first 1e-6 nohead dt 2 lc rgb "#7f7f7f"
set label 1 "10 nA"  at graph 0.01, first 1e-8  offset 0,0.6 tc rgb "#555555"
set label 2 "30 nA"  at graph 0.01, first 3e-8  offset 0,0.6 tc rgb "#555555"
set label 3 "100 nA" at graph 0.01, first 1e-7  offset 0,0.6 tc rgb "#555555"
set label 4 "300 nA" at graph 0.01, first 3e-7  offset 0,0.6 tc rgb "#555555"
set label 5 "1 uA"   at graph 0.01, first 1e-6  offset 0,0.6 tc rgb "#555555"

plot 'ipr.csv' skip 1 using 1:(abs($3)) axes x1y1 with lines lw 2 lc rgb "#1f77b4" title 'Id(M_{pr})', \
     'ipr.csv' skip 1 using 1:2 axes x1y2 with lines lw 2 dt 2 lc rgb "#d62728" title 'Vpr (right axis)'

set output
