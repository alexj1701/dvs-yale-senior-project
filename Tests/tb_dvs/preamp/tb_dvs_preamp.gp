# Plots tb_dvs_preamp.csv from tb_dvs_preamp.sp: one ON event and one OFF event with the AER handshake from test_ack,
# plus the preamp output (VprAmp).
# Columns: 1 = time, 2 = tri, 3 = Vpd, 4 = Vpr, 5 = Vdiff, 6 = VON, 7 = VnOFF, 8 = reset,
#          9 = RR, 10 = CRON, 11 = CROFF, 12 = RA, 13 = CA, 14 = VprAmp, 15 = rstMirrAmp, 16 = nRstChAmp, 17 = VprBuff
#
# Full run:       gnuplot tb_dvs_preamp.gp
# Zoom:           gnuplot -e "t0=0; t1=10; out='tb_dvs_preamp_zoom.png'" tb_dvs_preamp.gp
if (!exists("t0")) t0 = 0
if (!exists("t1")) t1 = 200
if (!exists("out")) out = "tb_dvs_preamp.png"

set terminal pngcairo size 1200,2000
set output out
set datafile separator ","

set style data lines
set grid
set xrange [t0:t1]
set key outside right nobox spacing 1.3
set lmargin at screen 0.09
set rmargin at screen 0.80

set multiplot title "DVS preamplifier biasing, full pixel"

# ---- light level ----
set tmargin at screen 0.96
set bmargin at screen 0.86
set title "Light level (tri, decades above 10 fA; 6 decades = 120 dB)"
set ylabel "tri (decades)"
set format x ""
unset xlabel
plot 'tb_dvs_preamp.csv' skip 1 using ($1*1e3):2 lw 2 lc rgb "#8c564b" title "tri"

# ---- Vpr (left) and Vpd (right) ----
set tmargin at screen 0.82
set bmargin at screen 0.72
set title "Vpr (left) and Vpd (right)"
set ylabel "Vpr (V)"
set y2label "Vpd (V)"
set ytics nomirror
set y2tics
plot 'tb_dvs_preamp.csv' skip 1 using ($1*1e3):4 axes x1y1 lw 2 lc rgb "#1f77b4" title "Vpr", \
     'tb_dvs_preamp.csv' skip 1 using ($1*1e3):3 axes x1y2 lw 2 lc rgb "#ff7f0e" title "Vpd"
unset y2label
unset y2tics
set ytics mirror

# ---- preamp ----
set tmargin at screen 0.68
set bmargin at screen 0.58
set title "Preamp output (VprAmp) and OTA buffer output (VprBuff)"
set ylabel "Voltage (V)"
plot 'tb_dvs_preamp.csv' skip 1 using ($1*1e3):14 lw 2 lc rgb "#e377c2" title "VprAmp", \
     'tb_dvs_preamp.csv' skip 1 using ($1*1e3):17 lw 2 dt 2 lc rgb "#bcbd22" title "VprBuff"

# ---- Vdiff ----
set tmargin at screen 0.54
set bmargin at screen 0.44
set title "Vdiff"
set ylabel "Vdiff (V)"
plot 'tb_dvs_preamp.csv' skip 1 using ($1*1e3):5 lw 2 lc rgb "#2ca02c" title "Vdiff"

# ---- comparator outputs ----
set yrange [-0.1:1.95]
set tmargin at screen 0.40
set bmargin at screen 0.30
set title "VON and VnOFF"
set ylabel "Voltage (V)"
plot 'tb_dvs_preamp.csv' skip 1 using ($1*1e3):6 lw 2 lc rgb "#9467bd" title "VON", \
     'tb_dvs_preamp.csv' skip 1 using ($1*1e3):7 lw 2 dt 2 lc rgb "#17becf" title "VnOFF"

# ---- RA and CA from test_ack ----
set tmargin at screen 0.26
set bmargin at screen 0.16
set title "RA and CA (from test_ack)"
plot 'tb_dvs_preamp.csv' skip 1 using ($1*1e3):12 lw 2 lc rgb "#7f7f7f" title "RA", \
     'tb_dvs_preamp.csv' skip 1 using ($1*1e3):13 lw 2 lc rgb "#8c564b" title "CA"

# ---- reset and request outputs ----
set tmargin at screen 0.12
set bmargin at screen 0.04
set title "reset, rstMirrAmp, nRstChAmp, RR, CRON, CROFF"
set xlabel "Time (ms)"
set format x "%g"
plot 'tb_dvs_preamp.csv' skip 1 using ($1*1e3):8  lw 3 lc rgb "red"     title "reset", \
     'tb_dvs_preamp.csv' skip 1 using ($1*1e3):15 lw 2 lc rgb "#e377c2" title "rstMirrAmp", \
     'tb_dvs_preamp.csv' skip 1 using ($1*1e3):16 lw 2 dt 2 lc rgb "#8c564b" title "nRstChAmp", \
     'tb_dvs_preamp.csv' skip 1 using ($1*1e3):9  lw 2 lc rgb "#1f77b4" title "RR", \
     'tb_dvs_preamp.csv' skip 1 using ($1*1e3):10 lw 2 lc rgb "#2ca02c" title "CRON", \
     'tb_dvs_preamp.csv' skip 1 using ($1*1e3):11 lw 2 lc rgb "#ff7f0e" title "CROFF"

unset multiplot
set output
