* DC sweep of Vipr, stepped over Vg_fb: M_pr current, Vpr and Vpd, full pixel attached.
*
* Run from this folder:
*   Xyce tb_ipr_vs_vgfb.sp
*   gnuplot ipr_plot.gp      (writes ipr_plot.png)

* options, supplies, models, pixel.spice
.inc ../../../common.inc

xpixel Vpd Vcasc Vg_fb Vipr Vidiff VIon VIoff Vreset VON VnOFF pixel

* ---- bias voltages: edit the .param values here ----
.param Vcasc_val  = .6
.param Vg_fb_val  = .7
.param Vipr_val   = .7
.param Vidiff_val = .250
.param VIon_val   = .275
.param VIoff_val  = .200

vcasc0      Vcasc       GND DC {Vcasc_val}
vgfb0       Vg_fb       GND DC {Vg_fb_val}
vipr0       Vipr        GND DC {Vipr_val}
vidiff0     Vidiff      GND DC {Vidiff_val}
vion0       VIon        GND DC {VIon_val}
vioff0      VIoff       GND DC {VIoff_val}


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
Vtri tri 0 PWL 0 0 2m 0 101m 6 200m 0
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* Outer loop: repeat the whole Vipr sweep for each value of Vg_fb.
.step Vg_fb_val LIST 0.3 0.5 0.7 0.9 1.1 1.3
.dc vipr0 0.6 1.6 0.01
* columns: 1 = Vg_fb, 2 = Vipr, 3 = Vpr, 4 = Id of M_pr (pull-up pFET, gate = Vipr), 5 = Vpd
.print dc file=ipr.csv format=csv v(Vg_fb) v(Vipr) v(xpixel:vpr) id(xpixel:xpr0:xM0_N:msky130_fd_pr__pfet_01v8) v(Vpd)

.end
