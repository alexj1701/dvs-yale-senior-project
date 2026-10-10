# Plots vion.csv from tb_vion_vs_von_dc.sp: VON as VIon is swept, at a fixed VIdiff (champ held in reset).
# Columns: 1 = VIon, 2 = VON, 3 = Vdiff, 4 = VnRstChAmp
# Vdiff is plotted as a sanity check: it should stay flat, since VIon only drives comparator gates.
#
# The dashed vertical line marks the VIon set in the netlist (VIon_val); change vset to move it.
vset = 0.275

set terminal pngcairo size 1000,700
set output "vion_plot.png"
set datafile separator ","

set style data lines
set grid
set autoscale xfix
set yrange [0:1.9]
set xlabel "VIon (V)"
set ylabel "Voltage (V)"
set title "VON vs VIon at fixed VIdiff (full pixel, DC, champ in reset)"
set key top right nobox
set arrow 1 from first vset, graph 0 to first vset, graph 1 nohead dt 2 lc rgb "#7f7f7f"

plot 'vion.csv' skip 1 using 1:2 lw 2 lc rgb "#9467bd" title "VON",      'vion.csv' skip 1 using 1:3 lw 1 dt 2 lc rgb "#2ca02c" title "Vdiff (reset level)"

set output
