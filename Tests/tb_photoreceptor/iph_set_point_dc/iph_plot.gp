# Plots iph.csv from tb_iph_set_point_dc.sp: Vpr, Vpd and the pull-up pFET current vs photocurrent.
# Columns: 1 = I(Bph), 2 = V(xpixel:vpr), 3 = V(Vpd), 4 = Id of xpixel:xpr0:xM0_N
# Bias set point: Vg_fb = 0.7 V, Vipr = 0.74 V, Vcasc = 0.8 V (set in the netlist).
set terminal pngcairo size 1000,1200

set output "iph_plot.png"
set datafile separator ","

set grid
set logscale x
set format x "10^{%L}"
set autoscale xfix
set lmargin at screen 0.11
set rmargin at screen 0.95
set key top left nobox

set multiplot title "Photocurrent DC sweep (Vg_fb = 0.7 V, Vipr = 0.74 V, Vcasc = 0.8 V)" noenhanced

# ---- top: Vpr ----
set tmargin at screen 0.93
set bmargin at screen 0.67
set title "Vpr"
set ylabel "Vpr (V)"
set format x ""
unset xlabel
plot 'iph.csv' skip 1 using (abs($1)):2 with lines lw 2 lc rgb "#1f77b4" notitle

# ---- middle: Vpd ----
set tmargin at screen 0.61
set bmargin at screen 0.35
set title "Vpd"
set ylabel "Vpd (V)"
plot 'iph.csv' skip 1 using (abs($1)):3 with lines lw 2 lc rgb "#ff7f0e" notitle

# ---- bottom: M_pr current, photocurrent dotted for reference ----
set tmargin at screen 0.29
set bmargin at screen 0.06
set title "Pull-up pFET current (Ipr)"
set xlabel "Photocurrent (A)"
set ylabel "Ipr (A)"
set logscale y
set format y "10^{%L}"
set format x "10^{%L}"
plot 'iph.csv' skip 1 using (abs($1)):(abs($4)) with lines lw 2 lc rgb "#2ca02c" title "Ipr", \
     'iph.csv' skip 1 using (abs($1)):(abs($1)) with lines lw 1 dt 3 lc rgb "#555555" title "I_{ph}"

unset multiplot
set output
