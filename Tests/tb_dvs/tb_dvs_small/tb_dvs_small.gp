# Plots tb_dvs_small.csv from tb_dvs_small.sp: one ON event and one OFF event with the AER handshake from test_ack,
# plus the preamp output (VprAmp).
# Columns: 1 = time, 2 = tri, 3 = Vpd, 4 = Vpr, 5 = Vdiff, 6 = VON, 7 = VnOFF, 8 = reset,
#          9 = RR, 10 = CRON, 11 = CROFF, 12 = RA, 13 = CA, 14 = VprAmp, 15 = rstMirrAmp, 16 = nRstChAmp, 17 = VprBuff, 18 = Vmirr0, 19 = Vmirr1, 20 = ra_i, 21 = ca_i
#
# Full run:       gnuplot tb_dvs_small.gp
# Zoom:           gnuplot -e "t0=0; t1=10; out='tb_dvs_small_zoom.png'" tb_dvs_small.gp
if (!exists("t0")) t0 = 0
if (!exists("t1")) t1 = 110
if (!exists("out")) out = "tb_dvs_small.png"

set terminal pngcairo size 2400,2600
set output out
set datafile separator ","

set style data lines
set grid
set xrange [t0:t1]
set key outside right nobox spacing 1.3
set lmargin at screen 0.045
set rmargin at screen 0.865

set multiplot title "DVS preamplifier, small 5-6-5 decade ramp, full pixel"

# ---- light level ----
set tmargin at screen 0.960
set bmargin at screen 0.905
set title "Light level (tri, decades above 10 fA; 5 to 6 decades = 1 nA to 10 nA)"
set ylabel "tri (decades)"
set format x ""
unset xlabel
plot 'tb_dvs_small.csv' skip 1 using ($1*1e3):2 lw 2 lc rgb "#8c564b" title "tri"

# ---- Vpr (left) and Vpd (right) ----
set tmargin at screen 0.865
set bmargin at screen 0.810
set title "Vpr (left) and Vpd (right)"
set ylabel "Vpr (V)"
set y2label "Vpd (V)"
set ytics nomirror
set y2tics
plot 'tb_dvs_small.csv' skip 1 using ($1*1e3):4 axes x1y1 lw 2 lc rgb "#1f77b4" title "Vpr", \
     'tb_dvs_small.csv' skip 1 using ($1*1e3):3 axes x1y2 lw 2 lc rgb "#ff7f0e" title "Vpd"
unset y2label
unset y2tics
set ytics mirror

# ---- preamp ----
set tmargin at screen 0.770
set bmargin at screen 0.715
set title "Preamp output (VprAmp) and OTA buffer output (VprBuff)"
set ylabel "Voltage (V)"
plot 'tb_dvs_small.csv' skip 1 using ($1*1e3):14 lw 2 lc rgb "#e377c2" title "VprAmp", \
     'tb_dvs_small.csv' skip 1 using ($1*1e3):17 lw 2 dt 2 lc rgb "#bcbd22" title "VprBuff"

# ---- preamp mirror nodes ----
set tmargin at screen 0.675
set bmargin at screen 0.620
set title "Preamp mirror nodes: Vmirr0 (diode node) and Vmirr1 (held gate of the mirror)"
set ylabel "Voltage (V)"
plot 'tb_dvs_small.csv' skip 1 using ($1*1e3):18 lw 2 lc rgb "#17becf" title "Vmirr0", \
     'tb_dvs_small.csv' skip 1 using ($1*1e3):19 lw 2 dt 2 lc rgb "#d62728" title "Vmirr1"

# ---- Vdiff ----
set tmargin at screen 0.580
set bmargin at screen 0.525
set title "Vdiff"
set ylabel "Vdiff (V)"
plot 'tb_dvs_small.csv' skip 1 using ($1*1e3):5 lw 2 lc rgb "#2ca02c" title "Vdiff"

# ---- comparator outputs ----
set yrange [-0.1:1.95]
set tmargin at screen 0.485
set bmargin at screen 0.430
set title "VON and VnOFF"
set ylabel "Voltage (V)"
plot 'tb_dvs_small.csv' skip 1 using ($1*1e3):6 lw 2 lc rgb "#9467bd" title "VON", \
     'tb_dvs_small.csv' skip 1 using ($1*1e3):7 lw 2 lc rgb "#17becf" title "VnOFF"

# ---- RA and CA from test_ack ----
set tmargin at screen 0.390
set bmargin at screen 0.335
set title "RA and CA (from test_ack)"
plot 'tb_dvs_small.csv' skip 1 using ($1*1e3):12 lw 2 lc rgb "#7f7f7f" title "RA", \
     'tb_dvs_small.csv' skip 1 using ($1*1e3):13 lw 2 lc rgb "#8c564b" title "CA"

# ---- internal delay nodes ----
set tmargin at screen 0.295
set bmargin at screen 0.240
set title "Internal delay nodes in test_ack: ra_i and ca_i"
set ylabel "Voltage (V)"
plot 'tb_dvs_small.csv' skip 1 using ($1*1e3):20 lw 2 lc rgb "#7f7f7f" title "ra_i", \
     'tb_dvs_small.csv' skip 1 using ($1*1e3):21 lw 2 dt 2 lc rgb "#8c564b" title "ca_i"

# ---- reset signals ----
set tmargin at screen 0.200
set bmargin at screen 0.145
set title "reset, rstMirrAmp, nRstChAmp"
set ylabel "Voltage (V)"
plot 'tb_dvs_small.csv' skip 1 using ($1*1e3):8  lw 3 lc rgb "red"     title "reset", \
     'tb_dvs_small.csv' skip 1 using ($1*1e3):15 lw 2 lc rgb "#e377c2" title "rstMirrAmp", \
     'tb_dvs_small.csv' skip 1 using ($1*1e3):16 lw 2 dt 2 lc rgb "#8c564b" title "nRstChAmp"

# ---- request outputs ----
set tmargin at screen 0.105
set bmargin at screen 0.050
set title "RR, CRON, CROFF"
set xlabel "Time (ms)"
set format x "%g"
plot 'tb_dvs_small.csv' skip 1 using ($1*1e3):9  lw 2 lc rgb "#1f77b4" title "RR", \
     'tb_dvs_small.csv' skip 1 using ($1*1e3):10 lw 2 lc rgb "#2ca02c" title "CRON", \
     'tb_dvs_small.csv' skip 1 using ($1*1e3):11 lw 2 lc rgb "#ff7f0e" title "CROFF"

unset multiplot
set output
