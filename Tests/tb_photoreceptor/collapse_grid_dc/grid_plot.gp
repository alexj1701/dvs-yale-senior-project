# Plots grid.csv from tb_collapse_grid_dc.sp as a grid of panels: one row per Vipr, one column per Vg_fb.
# Columns: 1 = Vipr, 2 = Vg_fb, 3 = vtri (decades above 10 fA), 4 = Vpd, 5 = Vpr, 6 = Id of M_pr, 7 = photocurrent
# Each panel: Vpd (left axis, blue) and Vpr (right axis, red) against vtri. Read the vtri where Vpd starts to drop.
set terminal pngcairo size 1500,1100
set output "grid_plot.png"

set datafile separator ","

# distinct values of the two stepped biases (file order; awk skips the header)
rows = system("awk -F, 'NR>1 && !s[$1]++ {printf \"%s \", $1}' grid.csv")
cols = system("awk -F, 'NR>1 && !s[$2]++ {printf \"%s \", $2}' grid.csv")
nr = words(rows)
nc = words(cols)

set grid
set xrange [0:6]
set xtics 0,1,6
set ytics nomirror
set y2tics
set yrange [-1:0.8]
set y2range [1.2:1.85]
set key off
set tics font ",8"

set multiplot layout nr, nc title "Vpd (blue, left) and Vpr (red, right) vs vtri, one panel per Vipr / Vg_fb combination" noenhanced

do for [i=1:nr] {
  do for [j=1:nc] {
    vi = word(rows, i) + 0
    vg = word(cols, j) + 0
    set title sprintf("Vipr = %.2f V, Vg_fb = %.2f V", vi, vg) noenhanced font ",10"
    if (i == nr) { set xlabel "vtri (decades above 10 fA)" } else { unset xlabel }
    if (j == 1)  { set ylabel "Vpd (V)" } else { unset ylabel }
    if (j == nc) { set y2label "Vpr (V)" } else { unset y2label }
    plot 'grid.csv' skip 1 using 3:((abs($1-vi)<1e-6 && abs($2-vg)<1e-6) ? $4 : NaN) axes x1y1 with lines lw 2 lc rgb "#1f77b4", \
         'grid.csv' skip 1 using 3:((abs($1-vi)<1e-6 && abs($2-vg)<1e-6) ? $5 : NaN) axes x1y2 with lines lw 2 lc rgb "#d62728"
  }
}

unset multiplot
set output
