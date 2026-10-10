# Plots window.csv from tb_vidiff_vs_von_vnoff_dc.sp: VON, VnOFF and VnRstChAmp against Vdiff,
# with the champ held in reset and VIdiff swept over a narrow window.
# Columns: 1 = VIdiff, 2 = Vdiff, 3 = VnRstChAmp, 4 = VON, 5 = VnOFF
#
# The solid vertical line is Vdiff at the idle VIdiff (vset). The dotted lines are contrast steps away from it:
# a light increase lowers Vdiff (ON side), a light decrease raises it (OFF side). The Vdiff change per step
# comes from the fast-step transient test at the idle level (about 72 mV for 0.05 decade); update these
# numbers if the circuit changes.
vset = 0.40          # VIdiff of the idle point (Vidiff_val in the netlist)
d05  = 0.072         # change in Vdiff for 0.05 decade of contrast, in V
d10  = 0.144         # for 0.1 decade
d20  = 0.287         # for 0.2 decade

# Vdiff at the idle VIdiff: first row of the CSV at or above vset
vd0 = real(system(sprintf("awk -F, 'NR>1 && $1>=%g-1e-9 {print $2; exit}' window.csv", vset)))

set terminal pngcairo size 1100,1000
set output "window_plot.png"
set datafile separator ","

set style data lines
set grid
set key top right nobox
set lmargin at screen 0.10
set rmargin at screen 0.95
set xrange [vd0-0.3:vd0+0.3]

# idle level and contrast-step markers
set arrow 1 from first vd0,        graph 0 to first vd0,        graph 1 nohead lw 1 lc rgb "#444444"
set arrow 2 from first vd0-d05,    graph 0 to first vd0-d05,    graph 1 nohead dt 3 lc rgb "#7f7f7f"
set arrow 3 from first vd0+d05,    graph 0 to first vd0+d05,    graph 1 nohead dt 3 lc rgb "#7f7f7f"
set arrow 4 from first vd0-d10,    graph 0 to first vd0-d10,    graph 1 nohead dt 3 lc rgb "#7f7f7f"
set arrow 5 from first vd0+d10,    graph 0 to first vd0+d10,    graph 1 nohead dt 3 lc rgb "#7f7f7f"
set arrow 6 from first vd0-d20,    graph 0 to first vd0-d20,    graph 1 nohead dt 3 lc rgb "#7f7f7f"
set arrow 7 from first vd0+d20,    graph 0 to first vd0+d20,    graph 1 nohead dt 3 lc rgb "#7f7f7f"
set label 1 "idle"        at first vd0,     graph 1.02 center tc rgb "#444444"
set label 2 "+0.05 dec"   at first vd0-d05, graph 1.02 center tc rgb "#7f7f7f"
set label 3 "-0.05"       at first vd0+d05, graph 1.02 center tc rgb "#7f7f7f"
set label 4 "+0.1"        at first vd0-d10, graph 1.02 center tc rgb "#7f7f7f"
set label 5 "-0.1"        at first vd0+d10, graph 1.02 center tc rgb "#7f7f7f"
set label 6 "+0.2"        at first vd0-d20, graph 1.02 center tc rgb "#7f7f7f"
set label 7 "-0.2"        at first vd0+d20, graph 1.02 center tc rgb "#7f7f7f"

set multiplot title "Comparator response to Vdiff around the idle level (champ in reset, DC)" offset 0,-0.5

# ---- VON and VnOFF ----
set tmargin at screen 0.87
set bmargin at screen 0.47
set ylabel "Voltage (V)"
set yrange [0:1.9]
set format x ""
unset xlabel
plot 'window.csv' skip 1 using 2:4 lw 2 lc rgb "#9467bd" title "VON", \
     'window.csv' skip 1 using 2:5 lw 2 dt 2 lc rgb "#17becf" title "VnOFF"

# ---- VnRstChAmp ----
unset label
set tmargin at screen 0.40
set bmargin at screen 0.08
set xlabel "Vdiff (V)"
set ylabel "VnRstChAmp (V)"
set format x "%g"
set yrange [0:1.9]
plot 'window.csv' skip 1 using 2:3 lw 2 lc rgb "#8c564b" title "VnRstChAmp"

unset multiplot
set output
