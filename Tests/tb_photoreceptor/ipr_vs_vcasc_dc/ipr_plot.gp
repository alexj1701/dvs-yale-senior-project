# Plots ipr.csv from tb_ipr.sp, one curve per step of the stepped bias (name and values are read from the file).
# Columns: 1 = stepped bias, 2 = V(Vipr), 3 = V(xpixel:vpr), 4 = Id of xpixel:xpr0:xM0_N, 5 = V(Vpd)
# Panels: pull-up pFET current (log), Vpr, Vpd.
set terminal pngcairo size 1100,1300
set output "ipr_plot.png"

set datafile separator ","

# name of the stepped bias from the CSV header, e.g. V(VG_FB) -> VG_FB
bname = system("head -1 ipr.csv | cut -d, -f1 | sed 's/V(//; s/)//'")

# distinct values of the stepped bias in file order (awk skips the header and prints each value once)
vals = system("awk -F, 'NR>1 && !s[$1]++ {printf \"%s \", $1}' ipr.csv")
n = words(vals)
vc(i) = word(vals, i) + 0

set grid
set autoscale xfix
set key outside right nobox spacing 1.3
set lmargin at screen 0.09
set rmargin at screen 0.78

# pick out the rows of step i (column 1 matches the stepped value)
sel(i, col) = (abs($1 - vc(i)) < 1e-6) ? column(col) : NaN

set multiplot title sprintf("Vipr DC sweep, one curve per %s", bname) noenhanced

# ---- top: current ----
set tmargin at screen 0.93
set bmargin at screen 0.68
set title "Pull-up pFET current"
set ylabel "Drain current (A)"
set logscale y
set format y "10^{%L}"
set mytics 10
set grid ytics mytics
set format x ""
unset xlabel

# reference currents to read Vipr off the curves
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

plot for [i=1:n] 'ipr.csv' skip 1 using 2:(abs(sel(i,4))) with lines lw 2 lc i \
     title sprintf("%s = %.2f V", bname, vc(i)) noenhanced

# ---- middle: Vpr ----
unset arrow
unset label
set tmargin at screen 0.62
set bmargin at screen 0.37
set title "Vpr"
unset xlabel
set ylabel "Vpr (V)"
unset logscale y
set format y "%g"
set format x ""
set yrange [0:1.9]
set grid ytics
unset mytics

plot for [i=1:n] 'ipr.csv' skip 1 using 2:(sel(i,3)) with lines lw 2 lc i \
     title sprintf("%s = %.2f V", bname, vc(i)) noenhanced

# ---- bottom: Vpd ----
set tmargin at screen 0.31
set bmargin at screen 0.06
set title "Vpd"
set xlabel "Vipr (V)"
set ylabel "Vpd (V)"
set format x "%g"
set yrange [0:1.9]

plot for [i=1:n] 'ipr.csv' skip 1 using 2:(sel(i,5)) with lines lw 2 lc i title sprintf("%s = %.2f V", bname, vc(i)) noenhanced

unset multiplot
set output
