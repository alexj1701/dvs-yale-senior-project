* Small-contrast fast-step test of the full pixel: 1 us edges with 0.05 / 0.1 / 0.2 decade steps, at 10 pA and 1 nA,
* to look for ringing and settling in Vpr / Vpd and to see how Vdiff and the comparators respond.
*
* Run from this folder:
*   Xyce tb_all_fast_small.sp
*   gnuplot tb_all_fast_small.gp      (writes tb_all_fast_small.png)

* options, supplies, models, pixel.spice
.inc ../../common.inc

xpixel Vpd Vcasc Vg_fb Vipr Vidiff VIon VIoff Vreset VON VnOFF pixel

* ---- bias voltages: edit the .param values here ----
.param Vcasc_val  = .8
.param Vg_fb_val  = 1.1
.param Vipr_val   = .74
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
* Start-up: Vreset is high for the first 1 ms, then low.
Vstart nstart GND PWL 0 1.8 1m 1.8 1.01m 0

* Event -> delay -> reset. An event is VON high OR VnOFF low (VnOFF is active low).
.param Vth = 0.9
.param k   = 50
* EventEn = 0 disables the event path (only the start-up pulse resets); set to 1 to enable.
.param EventEn = 1
Bev nev GND V={EventEn*1.8*(1-(1-0.5*(1+tanh(k*(V(VON)-Vth))))*(1-0.5*(1+tanh(k*(Vth-V(VnOFF))))))}

* RC delay: the delayed signal crosses Vth about 0.69*R*C after the event (1 Meg * 1 n = 1 ms tau)
.param Rdelay = 1Meg
.param Cdelay = 1n
Rdly nev  ndly {Rdelay}
Cdly ndly GND  {Cdelay}

* Vreset goes high when either the start-up pulse or the delayed event is high.
Bres Vreset GND V={1.8*(1-(1-V(nstart)/1.8)*(1-0.5*(1+tanh(k*(V(ndly)-Vth)))))}

* ---- photocurrent: small fast steps in log intensity ----
* V(tri) is in decades above Idark: I = Idark * 10^V(tri), so tri = 3 is 10 pA and 5 is 1 nA.
* Contrast steps of 0.05, 0.1 and 0.2 decade (about 12%, 26% and 58%); event pixels typically trigger on 10-30%.
* Every edge takes 1 us and each level is held for 4 ms. Block 1 is at tri = 3, then a slow 5 ms ramp to
* tri = 5 and block 2 repeats the same steps at 1 nA. Each block: +0.05, -0.05, +0.1, -0.1, +0.2, -0.2 decade.
.param Idark = 1e-14
Vtri tri 0 PWL 0m 3  6m 3  6.001m 3.05  10m 3.05  10.001m 3  14m 3  14.001m 3.1  18m 3.1  18.001m 3  22m 3  22.001m 3.2  26m 3.2  26.001m 3  30m 3  35m 5  40m 5  40.001m 5.05  44m 5.05  44.001m 5  48m 5  48.001m 5.1  52m 5.1  52.001m 5  56m 5  56.001m 5.2  60m 5.2  60.001m 5  64m 5  66m 5
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* columns: 1 = time, then in .print order
.print tran file=tb_all_fast_small.csv format=csv v(tri) i(Bph) v(Vpd) v(xpixel:vpr) v(xpixel:vdiff) v(VON) v(VnOFF) v(xpixel:vnrstchamp) v(Vreset)

* Max step 1 us so the 1 us edges and any ringing are resolved.
.tran 0.1u 66m 0 1u

.end
