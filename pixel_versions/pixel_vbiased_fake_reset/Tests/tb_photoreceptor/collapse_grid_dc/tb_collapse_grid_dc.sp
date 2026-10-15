* Collapse-point grid: photocurrent DC sweep for every combination of Vipr (about 30, 100, 240 nA of Ipr) and Vg_fb. Records Vpd and Vpr.
*
* Run from this folder:
*   Xyce tb_collapse_grid_dc.sp
*   gnuplot grid_plot.gp      (writes grid_plot.png)

* options, supplies, models, pixel.spice
.inc ../../../common.inc

xpixel Vpd Vcasc Vg_fb Vipr Vidiff VIon VIoff Vreset Vref VON VnOFF pixel
* ---- bias voltages: edit the .param values here ----
.param Vcasc_val  = .8
.param Vg_fb_val  = 1.0
.param Vipr_val   = .74
.param Vidiff_val = .250
.param VIon_val   = .275
.param VIoff_val  = .200
* Vref: gate bias of the weak pFET in the reset cell's pull-up (1.4 V = weakly inverted)
.param Vref_val   = 1.4

vcasc0      Vcasc       GND DC {Vcasc_val}
vgfb0       Vg_fb       GND DC {Vg_fb_val}
vipr0       Vipr        GND DC {Vipr_val}
vidiff0     Vidiff      GND DC {Vidiff_val}
vion0       VIon        GND DC {VIon_val}
vioff0      VIoff       GND DC {VIoff_val}
vref0       Vref        GND DC {Vref_val}


* ---- Vreset: start-up pulse OR delayed event ----
* 1) Start-up: Vreset is high for the first 1 ms (settles the circuit), then low.
*    (PWL values are literals: time,voltage pairs.)
Vstart nstart GND PWL 0 1.8 1m 1.8 1.01m 0

* 2) Event -> delay -> reset. An event is VON high OR VnOFF low (VnOFF is active low).
*    tanh turns each threshold into a smooth 0..1 flag; k sets the steepness.
.param Vth = 0.9
.param k   = 50
* EventEn = 0 disables the event path (only the start-up pulse resets); set to 1 to enable.
.param EventEn = 0
Bev nev GND V={EventEn*1.8*(1-(1-0.5*(1+tanh(k*(V(VON)-Vth))))*(1-0.5*(1+tanh(k*(Vth-V(VnOFF))))))}

*    RC delay: the delayed signal crosses Vth about 0.69*R*C after the event (1 Meg * 1 n = 1 ms tau)
.param Rdelay = 1Meg
.param Cdelay = 1n
Rdly nev  ndly {Rdelay}
Cdly ndly GND  {Cdelay}

*    Vreset goes high when either the start-up pulse or the delayed event is high.
Bres Vreset GND V={1.8*(1-(1-V(nstart)/1.8)*(1-0.5*(1+tanh(k*(V(ndly)-Vth)))))}

* ---- photocurrent: triangle in log intensity, pulled from Vpd to ground ----
* V(tri) is in decades: I = Idark * 10^V(tri). Held at 0 (dark current) until 2 ms so the start-up reset finishes first,
* then a triangle 0 -> 6 -> 0 V ending at 200 ms,
* so the current sweeps Idark -> Idark*1e6 -> Idark (change the 6 to change the decades).
.param Idark = 1e-14
* Vtri is swept by the .dc below: 1 V = 1 decade above Idark.
Vtri tri 0 DC 0
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* Two active .step lines nest, so every combination runs (9 photocurrent sweeps).
* Vipr values give M_pr about 30 / 100 / 240 nA (measured at Vcasc = 0.8 V, Vg_fb = 1.15 V).
.step Vipr_val  LIST 0.87 0.80 0.74
.step Vg_fb_val LIST 0.95 1.0 1.1
*.step Vcasc_val LIST 0.6 0.7 0.8

* Photocurrent sweep: Vtri is in decades above Idark (10 fA), so 0..6 V = 10 fA .. 10 nA.
.dc vtri 0 6 0.05
* columns: 1 = Vipr, 2 = Vg_fb, 3 = vtri (decades above 10 fA), 4 = Vpd, 5 = Vpr, 6 = Id of M_pr, 7 = photocurrent
.print dc file=grid.csv format=csv v(Vipr) v(Vg_fb) v(tri) v(Vpd) v(xpixel:vpr) id(xpixel:xpr0:xM0_N:msky130_fd_pr__pfet_01v8) i(Bph)

.end
