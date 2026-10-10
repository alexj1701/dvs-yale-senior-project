# Plots vioff.csv from tb_vioff_vs_vnoff_dc.sp: VnOFF as VIoff is swept, at a fixed VIdiff (champ held in reset).
# Columns: 1 = VIoff, 2 = VnOFF, 3 = Vdiff, 4 = VnRstChAmp
# Vdiff is plotted as a sanity check: it should stay flat, since VIoff only drives comparator gates.
#
# The dashed vertical line marks the VIoff set in the netlist (VIoff_val); change vset to move it.
vset = 0.2

set terminal pngcairo size 1000,700
set output "vioff_plot.png"
set datafile separator ","

set style data lines
set grid
set autoscale xfix
set yrange [0:1.9]
set xlabel "VIoff (V)"
set ylabel "Voltage (V)"
set title "VnOFF vs VIoff at fixed VIdiff (full pixel, DC, champ in reset)"
set key top right nobox
set arrow 1 from first vset, graph 0 to first vset, graph 1 nohead dt 2 lc rgb "#7f7f7f"

plot 'vioff.csv' skip 1 using 1:2 lw 2 lc rgb "#17becf" title "VnOFF",      'vioff.csv' skip 1 using 1:3 lw 1 dt 2 lc rgb "#2ca02c" title "Vdiff (reset level)"

set output
