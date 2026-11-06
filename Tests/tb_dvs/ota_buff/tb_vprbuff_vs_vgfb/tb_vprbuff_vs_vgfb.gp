# Plots tb_vprbuff_vs_vgfb.csv from tb_vprbuff_vs_vgfb.sp: Vpr, VprAmp and VprBuff vs Vg_fb, light held constant.
# Columns: 1 = Vg_fb, 2 = Vpd, 3 = Vpr, 4 = VprAmp, 5 = VprBuff
set terminal pngcairo size 1000,1400
set output "tb_vprbuff_vs_vgfb.png"
set datafile separator ","

set grid
set autoscale xfix
set lmargin at screen 0.11
set rmargin at screen 0.95
set key top left nobox

set multiplot title "Vg_fb DC sweep, light held at 3 decades (10 pA), full pixel" noenhanced

# ---- Vpd ----
set tmargin at screen 0.93
set bmargin at screen 0.73
set title "Vpd"
set ylabel "Vpd (V)"
set format x ""
unset xlabel
plot 'tb_vprbuff_vs_vgfb.csv' skip 1 using 1:2 with lines lw 2 lc rgb "#ff7f0e" notitle

# ---- Vpr, VprAmp, VprBuff ----
set tmargin at screen 0.68
set bmargin at screen 0.38
set title "Vpr, preamp output (VprAmp) and OTA buffer output (VprBuff)"
set ylabel "Voltage (V)"
plot 'tb_vprbuff_vs_vgfb.csv' skip 1 using 1:3 with lines lw 2 lc rgb "#1f77b4" title "Vpr", \
     'tb_vprbuff_vs_vgfb.csv' skip 1 using 1:4 with lines lw 2 lc rgb "#e377c2" title "VprAmp", \
     'tb_vprbuff_vs_vgfb.csv' skip 1 using 1:5 with lines lw 2 dt 2 lc rgb "#bcbd22" title "VprBuff"

# ---- VprBuff alone ----
set tmargin at screen 0.33
set bmargin at screen 0.06
set title "OTA buffer output (VprBuff)"
set xlabel "Vg_fb (V)"
set format x "%g"
set ylabel "VprBuff (V)"
plot 'tb_vprbuff_vs_vgfb.csv' skip 1 using 1:5 with lines lw 2 lc rgb "#bcbd22" notitle

unset multiplot
set output
