* Fast-step test of the full pixel: sharp photocurrent steps (1 us edges) to look for ringing,
* overshoot and settling time in Vpr / Vpd, and to see how Vdiff and the comparators respond.
*
* Run from this folder:
*   Xyce tb_all_fast.sp
*   gnuplot tb_all_fast.gp      (writes tb_all_fast.png)

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
.param EventEn = 0
Bev nev GND V={EventEn*1.8*(1-(1-0.5*(1+tanh(k*(V(VON)-Vth))))*(1-0.5*(1+tanh(k*(Vth-V(VnOFF))))))}

* RC delay: the delayed signal crosses Vth about 0.69*R*C after the event (1 Meg * 1 n = 1 ms tau)
.param Rdelay = 1Meg
.param Cdelay = 1n
Rdly nev  ndly {Rdelay}
Cdly ndly GND  {Cdelay}

* Vreset goes high when either the start-up pulse or the delayed event is high.
Bres Vreset GND V={1.8*(1-(1-V(nstart)/1.8)*(1-0.5*(1+tanh(k*(V(ndly)-Vth)))))}

* ---- photocurrent: fast steps in log intensity ----
* V(tri) is in decades above Idark: I = Idark * 10^V(tri), so tri = 3 is 10 pA, 4 is 100 pA, 6 is 10 nA.
* Every edge takes 1 us; each level is held for 10 ms. Sequence (tri):
*   3 (settle) -> 4 -> 3 -> 5 -> 3 -> 6 -> 3   i.e. +1, -1, +2, -2, +3, -3 decades
.param Idark = 1e-14
Vtri tri 0 PWL 0 3  12m 3  12.001m 4  22m 4  22.001m 3  32m 3  32.001m 5  42m 5  42.001m 3  52m 3  52.001m 6  62m 6  62.001m 3  72m 3
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* columns: 1 = time, then in .print order
.print tran file=tb_all_fast.csv format=csv v(tri) i(Bph) v(Vpd) v(xpixel:vpr) v(xpixel:vdiff) v(VON) v(VnOFF) v(xpixel:vnrstchamp) v(Vreset)

* Max step 1 us so the 1 us edges and any ringing are resolved.
.tran 0.1u 72m 0 1u

.end
