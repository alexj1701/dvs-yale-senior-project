* Bias harness: full pixel attached, edit the bias values below.
*
* Run from this folder:
*   Xyce BiasHarness.sp
*   gnuplot bias_plot.gp      (writes bias_plot.png)
* Sweep: python plot_sweep.py   (one folder of PNGs per swept bias, in sweep_plots/)

* options, supplies, models, pixel.spice
.inc ../../common.inc

xpixel Vpd Vcasc Vg_fb Vipr Vidiff VIon VIoff Vreset Vref VON VnOFF pixel
* ---- bias voltages: edit the .param values here ----
.param Vcasc_val  = .8
.param Vg_fb_val  = 0.8
.param Vipr_val   = 0.74
.param Vidiff_val = .40
.param VIon_val   = .42
.param VIoff_val  = .38
.param Vref_val   = 1.3

vcasc0      Vcasc       GND DC {Vcasc_val}
vgfb0       Vg_fb       GND DC {Vg_fb_val}
vipr0       Vipr        GND DC {Vipr_val}
vidiff0     Vidiff      GND DC {Vidiff_val}
vion0       VIon        GND DC {VIon_val}
vioff0      VIoff       GND DC {VIoff_val}
vref0       Vref        GND DC {Vref_val}

* ---- sweep: use ONE .step line, comment out the rest ----
* Each step is a full transient run. To sweep a different bias, comment out the active
* line and uncomment the one you want. Edit the list of values as needed.
*.step Vipr_val LIST 0.3 0.5 0.7 0.9 1.1 1.3

*.step Vcasc_val  LIST 0.3 0.5 0.7 0.9 1.1 1.3

*.step Vg_fb_val LIST 1.0 1.1 1.2

*.step Vidiff_val LIST 0.1 0.3 0.5 0.7 0.9 1.1

*.step VIon_val   LIST 0.1 0.2 0.3 0.4 0.5 0.6

*.step VIoff_val  LIST 0.1 0.2 0.3 0.4 0.5 0.6
*.step Vref_val   LIST 1.2 1.3 1.4 1.5 1.6

* To sweep two biases at once, leave two .step lines active (they nest: every combination runs).

* ---- Vreset: start-up pulse OR delayed event ----
* 1) Start-up: Vreset is high for the first 1 ms (settles the circuit), then low.
*    (PWL values are literals: time,voltage pairs.)
Vstart nstart GND PWL 0 1.8 1m 1.8 1.01m 0

* 2) Event -> delay -> reset. An event is VON high OR VnOFF low (VnOFF is active low).
*    tanh turns each threshold into a smooth 0..1 flag; k sets the steepness.
.param Vth = 0.9
.param k   = 50
* EventEn = 0 disables the event path (only the start-up pulse resets); set to 1 to enable.
.param EventEn = 1
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

* Dc or Stepped versions of photocurrent
.param Ldec = 0
*Vtri tri 0 DC {Ldec}
*10 fA, 1 pA, 100 pA, 10 nA
*.step Ldec LIST 0 2 4 6

Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* Column order matters: bias_plot.gp reads these by column number.
* cols 3-10: biases and Vpd; cols 11-14: pixel signals; col 15: photocurrent; col 16: VnRstChAmp
.print tran file=bias.plot format=gnuplot v(Vcasc) v(Vg_fb) v(Vipr) v(Vidiff) v(VIon) v(VIoff) v(Vreset) v(Vpd) v(xpixel:vpr) v(xpixel:vdiff) v(VON) v(VnOFF) i(Bph) v(xpixel:vnrstchamp)

* CSV copy for analysis, with the reset-chain nodes (nev = event flag, ndly = delayed event);
* the bias columns at the end identify which .step each row belongs to.
.print tran file=bias.csv format=csv v(Vpd) i(Bph) v(xpixel:vpr) v(xpixel:vdiff) v(VON) v(VnOFF) v(xpixel:vnrstchamp) v(Vreset) v(nstart) v(nev) v(ndly) v(Vcasc) v(Vg_fb) v(Vipr) v(Vidiff) v(VIon) v(VIoff)

.tran 1u 200m 0 10u

.end
