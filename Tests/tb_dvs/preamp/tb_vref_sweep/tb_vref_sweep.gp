# Plots tb_vref_sweep.csv from tb_vref_sweep.sp: one curve per Vref step, light at 3 decades, stepping up 0.05 decade at 10 ms.
# Columns: 1 = time, 2 = Vref, 3 = Vpd, 4 = Vpr, 5 = VprAmp, 6 = Vdiff, 7 = VON, 8 = VnOFF, 9 = reset,
#          10 = rstMirrAmp, 11 = nRstChAmp, 12 = RA, 13 = CA, 14 = VprBuff
#
# vals must list the same Vref values as the .step line in tb_vref_sweep.sp.
#
# Full run:  gnuplot tb_vref_sweep.gp
# Zoom:      gnuplot -e "t0=9; t1=11; out='tb_vref_sweep_zoom.png'" tb_vref_sweep.gp
vals = "1.0 1.1 1.2"
if (!exists("t0")) t0 = 0
if (!exists("t1")) t1 = 20
if (!exists("out")) out = "tb_vref_sweep.png"

set terminal pngcairo size 1200,2200
set output out
set datafile separator ","

set style data lines
set grid
set xrange [t0:t1]
set key outside right nobox spacing 1.3
set lmargin at screen 0.09
set rmargin at screen 0.80

# keep only the rows that belong to step i (column 2 holds the step's Vref value)
step(i, c) = (abs(column(2) - real(word(vals, i))) < 1e-4 ? column(c) : 1/0)
lbl(i) = sprintf("Vref = %s V", word(vals, i))

set multiplot title "Vref sweep, full pixel"

# ---- VprAmp ----
set tmargin at screen 0.960
set bmargin at screen 0.864
set title "VprAmp (solid) and OTA buffer output VprBuff (dashed)"
set ylabel "VprAmp (V)"
set format x ""
unset xlabel
plot for [i=1:words(vals)] 'tb_vref_sweep.csv' skip 1 using ($1*1e3):(step(i, 5)) lw 2 lc i title "VprAmp, ".lbl(i), \
     for [i=1:words(vals)] 'tb_vref_sweep.csv' skip 1 using ($1*1e3):(step(i, 14)) lw 2 dt 2 lc i title "VprBuff, ".lbl(i)

# ---- Vdiff ----
set yrange [0.83:0.85]
set tmargin at screen 0.824
set bmargin at screen 0.729
set title "Vdiff"
set ylabel "Vdiff (V)"
plot for [i=1:words(vals)] 'tb_vref_sweep.csv' skip 1 using ($1*1e3):(step(i, 6)) lw 2 title lbl(i)

# ---- VON (solid) and VnOFF (dashed) ----
set yrange [-0.1:1.95]
set tmargin at screen 0.689
set bmargin at screen 0.593
set title "VON (solid) and VnOFF (dashed)"
set ylabel "Voltage (V)"
plot for [i=1:words(vals)] 'tb_vref_sweep.csv' skip 1 using ($1*1e3):(step(i, 7)) lw 2 lc i title "VON, ".lbl(i), \
     for [i=1:words(vals)] 'tb_vref_sweep.csv' skip 1 using ($1*1e3):(step(i, 8)) lw 2 dt 2 lc i title "VnOFF, ".lbl(i)

# ---- rstMirrAmp (with reset) ----
set tmargin at screen 0.553
set bmargin at screen 0.457
set title "rstMirrAmp (reset dashed, first step)"
set ylabel "Voltage (V)"
plot for [i=1:words(vals)] 'tb_vref_sweep.csv' skip 1 using ($1*1e3):(step(i, 10)) lw 2 lc i title lbl(i), \
     'tb_vref_sweep.csv' skip 1 using ($1*1e3):(step(1, 9)) lw 2 dt 2 lc rgb "red" title "reset"

# ---- nRstChAmp ----
set tmargin at screen 0.417
set bmargin at screen 0.321
set title "nRstChAmp"
plot for [i=1:words(vals)] 'tb_vref_sweep.csv' skip 1 using ($1*1e3):(step(i, 11)) lw 2 title lbl(i)

# ---- RA (solid) and CA (dashed) ----
set yrange [-0.1:1.95]
set tmargin at screen 0.281
set bmargin at screen 0.186
set title "RA (solid) and CA (dashed)"
set ylabel "Voltage (V)"
plot for [i=1:words(vals)] 'tb_vref_sweep.csv' skip 1 using ($1*1e3):(step(i, 12)) lw 2 lc i title "RA, ".lbl(i), \
     for [i=1:words(vals)] 'tb_vref_sweep.csv' skip 1 using ($1*1e3):(step(i, 13)) lw 2 dt 2 lc i title "CA, ".lbl(i)

# ---- Vpr ----
set yrange [*:*]
set tmargin at screen 0.146
set bmargin at screen 0.050
set format x "%g"
set xlabel "Time (ms)"
set title "Vpr"
set ylabel "Vpr (V)"
plot for [i=1:words(vals)] 'tb_vref_sweep.csv' skip 1 using ($1*1e3):(step(i, 4)) lw 2 title lbl(i)

unset multiplot
set output
