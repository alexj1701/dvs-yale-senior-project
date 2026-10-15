# Plots vidiff.csv from tb_vidiff_vs_vdiff_dc.sp (champ held in reset, VIdiff swept).
# Columns: 1 = VIdiff, 2 = Vdiff, 3 = VnRstChAmp, 4 = VON, 5 = VnOFF
# Panels: Vdiff, and the comparator outputs.
#
# The dashed line marks the VIdiff set in the other tests' netlists (Vidiff_val); change vset to move it.
vset = 0.25

set terminal pngcairo size 1000,900
set output "vidiff_plot.png"
set datafile separator ","

set style data lines
set grid
set autoscale xfix
set lmargin at screen 0.11
set rmargin at screen 0.95
set key top right nobox
set arrow 1 from first vset, graph 0 to first vset, graph 1 nohead dt 2 lc rgb "#7f7f7f"

set multiplot title "VIdiff sweep with the champ in reset (full pixel, DC)"

# ---- Vdiff ----
set tmargin at screen 0.92
set bmargin at screen 0.52
set title "Vdiff (reset level)"
set ylabel "Vdiff (V)"
set format x ""
unset xlabel
plot 'vidiff.csv' skip 1 using 1:2 lw 2 lc rgb "#2ca02c" title "Vdiff"

# ---- comparator outputs ----
set tmargin at screen 0.44
set bmargin at screen 0.09
set title "Comparator outputs"
set xlabel "VIdiff (V)"
set ylabel "Voltage (V)"
set format x "%g"
set yrange [0:1.9]
plot 'vidiff.csv' skip 1 using 1:4 lw 2 lc rgb "#9467bd" title "VON",      'vidiff.csv' skip 1 using 1:5 lw 2 dt 2 lc rgb "#17becf" title "VnOFF"

unset multiplot
set output
