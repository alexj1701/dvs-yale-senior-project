# Plots tb_viprmirr_sweep2.csv from tb_viprmirr_sweep2.sp: one curve per Vg_fb step, light ramp (tri = 0 -> 1 decade).
# Columns: 1 = time, 2 = Vg_fb, 3 = Vpd, 4 = Vpr, 5 = VprAmp, 6 = Vdiff, 7 = VON, 8 = VnOFF, 9 = reset, 10 = id of xM1_Npass (negative: netlist drain is GND), plotted as -id,
#          11 = rstMirrAmp, 12 = nRstChAmp, 13 = RA, 14 = CA, 15 = Vmirr1, 16 = id of xM3_Npass (plotted as |id|), 17 = VprBuff, 18 = tri
#
# vals must list the same Vg_fb values as the .step line in tb_viprmirr_sweep2.sp.
#
# Full run:  gnuplot tb_viprmirr_sweep2.gp
# Zoom:      gnuplot -e "t0=0; t1=5; out='tb_viprmirr_sweep2_zoom.png'" tb_viprmirr_sweep2.gp
vals = "0.4"
if (!exists("t0")) t0 = 0
if (!exists("t1")) t1 = 200
if (!exists("out")) out = "tb_viprmirr_sweep2.png"

set terminal pngcairo size 1200,3000
set output out
set datafile separator ","

set style data lines
set grid
set xrange [t0:t1]
set key outside right nobox spacing 1.3
set lmargin at screen 0.1
set rmargin at screen 0.80

# keep only the rows that belong to step i (column 2 holds the step's Vg_fb value)
step(i, c) = (abs(column(2) - real(word(vals, i))) < 1e-4 ? column(c) : 1/0)
lbl(i) = sprintf("Vg_fb = %s V", word(vals, i))

set multiplot title "Vg_fb sweep, light ramp 0 to 1 decade (10 fA to 100 fA), full pixel"

# ---- light level (tri) ----
set tmargin at screen 0.960
set bmargin at screen 0.896
set title "Light level (tri, decades above 10 fA)"
set ylabel "tri (decades)"
set format x ""
unset xlabel
plot 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(1, 18)) lw 2 lc rgb "#8c564b" title "tri"

# ---- Vpr ----
set tmargin at screen 0.866
set bmargin at screen 0.802
set title "Vpr"
set ylabel "Vpr (V)"
set format x ""
unset xlabel
plot for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(i, 4)) lw 2 title lbl(i)

# ---- VprAmp ----
set tmargin at screen 0.772
set bmargin at screen 0.708
set title "VprAmp (solid) and OTA buffer output VprBuff (dashed)"
set ylabel "VprAmp (V)"
plot for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(i, 5)) lw 2 lc i title "VprAmp, ".lbl(i), \
     for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(i, 17)) lw 2 dt 2 lc i title "VprBuff, ".lbl(i)

# ---- Vmirr1 ----
set tmargin at screen 0.678
set bmargin at screen 0.614
set title "Vmirr1 (preamp mirror gate node)"
set ylabel "Vmirr1 (V)"
plot for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(i, 15)) lw 2 title lbl(i)

# ---- IprMirr ----
set tmargin at screen 0.584
set bmargin at screen 0.520
set title "IprMirr (xM1_Npass, solid) and xM3_Npass current (dashed)"
set ylabel "Current (A)"
set format y "%.2e"
plot for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(-step(i, 10)) lw 2 lc i title "IprMirr, ".lbl(i), \
     for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(abs(step(i, 16))) lw 2 dt 2 lc i title "xM3_Npass, ".lbl(i)
set format y "% h"

# ---- Vdiff ----
set tmargin at screen 0.490
set bmargin at screen 0.426
set title "Vdiff"
set ylabel "Vdiff (V)"
plot for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(i, 6)) lw 2 title lbl(i)

# ---- VON (solid) and VnOFF (dashed) ----
set yrange [-0.1:1.95]
set tmargin at screen 0.396
set bmargin at screen 0.332
set title "VON (solid) and VnOFF (dashed)"
set ylabel "Voltage (V)"
plot for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(i, 7)) lw 2 lc i title "VON, ".lbl(i), \
     for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(i, 8)) lw 2 dt 2 lc i title "VnOFF, ".lbl(i)

# ---- RA (solid) and CA (dashed) ----
set yrange [-0.1:1.95]
set tmargin at screen 0.302
set bmargin at screen 0.238
set title "RA (solid) and CA (dashed)"
set ylabel "Voltage (V)"
plot for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(i, 13)) lw 2 lc i title "RA, ".lbl(i), \
     for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(i, 14)) lw 2 dt 2 lc rgb "#e377c2" title "CA, ".lbl(i)

# ---- reset ----
set yrange [-0.1:1.95]
set tmargin at screen 0.208
set bmargin at screen 0.144
set format x "%g"
set xlabel "Time (ms)"
set ylabel "Voltage (V)"
set title "reset, rstMirrAmp, nRstChAmp"
plot 'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(1, 9)) lw 2 lc rgb "red" title "reset", \
     'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(1, 11)) lw 2 lc rgb "#e377c2" title "rstMirrAmp", \
     'tb_viprmirr_sweep2.csv' skip 1 using ($1*1e3):(step(1, 12)) lw 2 dt 2 lc rgb "#8c564b" title "nRstChAmp"

# ---- VprAmp and Vpr vs light level ----
set autoscale y
set xrange [0:1]
set tmargin at screen 0.114
set bmargin at screen 0.050
set title "VprAmp (solid) and Vpr (dashed) vs light level"
set xlabel "tri (decades above 10 fA)"
set format x "%g"
set ylabel "Voltage (V)"
plot for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using 18:(step(i, 5)) lw 2 lc i title "VprAmp, ".lbl(i), \
     for [i=1:words(vals)] 'tb_viprmirr_sweep2.csv' skip 1 using 18:(step(i, 4)) lw 2 dt 2 lc i title "Vpr, ".lbl(i)

unset multiplot
set output
