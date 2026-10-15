# Plots iph.csv from tb_iph_vs_vcasc_dc.sp: one curve per Vcasc step (name and values read from the file).
# Columns: 1 = stepped bias, 2 = I(Bph), 3 = V(xpixel:vpr), 4 = V(Vpd), 5 = Id of M_pr
# Panels: Vpr, Vpd, M_pr current vs photocurrent. Vdiff/VON/VnOFF are not plotted: the champ is
# capacitively coupled to Vpr, so they do not respond in a DC sweep.
set terminal pngcairo size 1100,1300
set output "iph_plot.png"

set datafile separator ","

# name of the stepped bias from the CSV header, e.g. V(VG_FB) -> VG_FB
bname = system("head -1 iph.csv | cut -d, -f1 | sed 's/V(//; s/)//'")

# distinct values of the stepped bias in file order (awk skips the header and prints each value once)
vals = system("awk -F, 'NR>1 && !s[$1]++ {printf \"%s \", $1}' iph.csv")
n = words(vals)
vc(i) = word(vals, i) + 0

# rows of step i (column 1 matches the stepped value)
sel(i, col) = (abs($1 - vc(i)) < 1e-6) ? column(col) : NaN

set grid
set logscale x
set format x "10^{%L}"
set xrange [8e-15:1.3e-8]
set key outside right nobox spacing 1.3
set lmargin at screen 0.09
set rmargin at screen 0.78

set multiplot title sprintf("Photocurrent DC sweep, one curve per %s", bname) noenhanced

# ---- top: Vpr ----
set tmargin at screen 0.93
set bmargin at screen 0.68
set title "Vpr"
set ylabel "Vpr (V)"
set yrange [0:1.9]
set format x ""
unset xlabel
plot for [i=1:n] 'iph.csv' skip 1 using (abs($2)):(sel(i,3)) with lines lw 2 lc i title sprintf("%s = %.2f V", bname, vc(i)) noenhanced

# ---- middle: Vpd ----
set tmargin at screen 0.62
set bmargin at screen 0.37
set title "Vpd"
set ylabel "Vpd (V)"
set yrange [*:*]
plot for [i=1:n] 'iph.csv' skip 1 using (abs($2)):(sel(i,4)) with lines lw 2 lc i title sprintf("%s = %.2f V", bname, vc(i)) noenhanced

# ---- bottom: M_pr current, with the photocurrent as a reference ----
set tmargin at screen 0.31
set bmargin at screen 0.06
set title "Pull-up pFET current (dotted line: photocurrent)"
set xlabel "Photocurrent (A)"
set ylabel "Drain current (A)"
set logscale y
set format y "10^{%L}"
set format x "10^{%L}"
set yrange [1e-11:1e-5]
plot for [i=1:n] 'iph.csv' skip 1 using (abs($2)):(abs(sel(i,5))) with lines lw 2 lc i title sprintf("%s = %.2f V", bname, vc(i)) noenhanced,      x with lines lw 1 dt 3 lc rgb "#555555" title "I_{ph}"

unset multiplot
set output
