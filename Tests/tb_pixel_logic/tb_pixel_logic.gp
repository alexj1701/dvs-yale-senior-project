# Plots tb_pixel_logic.csv from tb_pixel_logic.sp.
# Columns: 1 = time, 2 = VON, 3 = VnOFF, 4 = Vref, 5 = VIoffh, 6 = Vreset, 7 = RR, 8 = CRON, 9 = CROFF, 10 = RA, 11 = CA
# Top panel: RA, CA.  Middle panel: Vreset, RR, CRON, CROFF.  Bottom panel: VON, VnOFF, Vref, VIoffh.

set terminal pngcairo size 1200,1100
set output "tb_pixel_logic.png"
set datafile separator ","

set style data lines
set grid
set key outside right nobox spacing 1.3
set lmargin at screen 0.09
set rmargin at screen 0.82
set yrange [-0.1:1.95]
set ylabel "Voltage (V)"

set multiplot title 'pixel logic test'

# ---- handshake ----
set tmargin at screen 0.93
set bmargin at screen 0.70
set title "RA, CA"
set format x ""
plot 'tb_pixel_logic.csv' skip 1 using ($1*1e6):10 lw 2 lc rgb "#7f7f7f" title "RA", \
     'tb_pixel_logic.csv' skip 1 using ($1*1e6):11 lw 2 lc rgb "#8c564b" title "CA"

# ---- outputs ----
set tmargin at screen 0.63
set bmargin at screen 0.38
set title "Vreset, RR, CRON, CROFF"
plot 'tb_pixel_logic.csv' skip 1 using ($1*1e6):6 lw 3 lc rgb "red"     title "Vreset", \
     'tb_pixel_logic.csv' skip 1 using ($1*1e6):7 lw 2 lc rgb "#1f77b4" title "RR", \
     'tb_pixel_logic.csv' skip 1 using ($1*1e6):8 lw 2 lc rgb "#2ca02c" title "CRON", \
     'tb_pixel_logic.csv' skip 1 using ($1*1e6):9 lw 2 lc rgb "#ff7f0e" title "CROFF"

# ---- inputs ----
set tmargin at screen 0.31
set bmargin at screen 0.07
set title "VON, VnOFF, Vref, VIoffh"
set xlabel "Time (us)"
set format x "%g"
plot 'tb_pixel_logic.csv' skip 1 using ($1*1e6):2 lw 2 lc rgb "#9467bd" title "VON", \
     'tb_pixel_logic.csv' skip 1 using ($1*1e6):3 lw 2 lc rgb "#17becf" title "VnOFF", \
     'tb_pixel_logic.csv' skip 1 using ($1*1e6):4 lw 2 lc rgb "#bcbd22" title "Vref", \
     'tb_pixel_logic.csv' skip 1 using ($1*1e6):5 lw 2 lc rgb "#e377c2" title "VIoffh"

unset multiplot
set output
