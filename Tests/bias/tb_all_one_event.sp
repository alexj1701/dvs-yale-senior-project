* One ON event and one OFF event: the full pixel is given a single light step up and then an equal step down,
* with the event path enabled so each event resets the change amplifier through the reset cell.
*
* Light level: V(tri) is in decades above Idark (I = Idark * 10^V(tri)); tri = 3 is 10 pA.
*   0 - 6 ms    : settle at tri = 3 (the start-up pulse resets the champ at the beginning)
*   6 ms        : step UP   by 0.07 decade (about +17.4%) in 1 us   -> expected ON event
*   6 - 20 ms   : hold; the event resets the champ at the new level
*   20 ms       : step DOWN by 0.07 decade (about -14.8%) in 1 us   -> expected OFF event
*   20 - 34 ms  : hold; the event resets the champ again
* The comparator thresholds measured in the DC test are about 0.05 decade from idle on each side, so 0.07 decade
* is a little past them. To change the step size, edit the two tri levels (3.07) in the PWL below.
*
* Run from this folder:
*   Xyce tb_all_one_event.sp
*   gnuplot tb_all_one_event.gp      (writes tb_all_one_event.png)

* options, supplies, models, pixel.spice
.inc ../../common.inc

xpixel Vpd Vcasc Vg_fb Vipr Vidiff VIon VIoff Vreset Vref VON VnOFF pixel 
* ---- bias voltages: edit the .param values here ----
.param Vcasc_val  = .8
.param Vg_fb_val  = 1.15
.param Vipr_val   = .74
.param Vidiff_val = .40
.param VIon_val   = .42
.param VIoff_val  = .38
* Vref: gate bias of the weak pFET in the reset cell's pull-up (1.4 V = weakly inverted)
.param Vref_val   = 1.3

vcasc0      Vcasc       GND DC {Vcasc_val}
vgfb0       Vg_fb       GND DC {Vg_fb_val}
vipr0       Vipr        GND DC {Vipr_val}
vidiff0     Vidiff      GND DC {Vidiff_val}
vion0       VIon        GND DC {VIon_val}
vioff0      VIoff       GND DC {VIoff_val}
vref0       Vref        GND DC {Vref_val}

*.step Vref_val   LIST 0.9 1.0 1.1 1.2 1.3

* ---- Vreset: start-up pulse OR delayed event ----
* 1) Start-up: Vreset is high for the first 1 ms (settles the circuit), then low.
*    (PWL values are literals: time,voltage pairs.)
Vstart nstart GND PWL 0 1.8 1m 1.8 1.01m 0

* 2) Event -> delay -> reset. An event is VON high OR VnOFF low (VnOFF is active low).
*    tanh turns each threshold into a smooth 0..1 flag; k sets the steepness.
.param Vth = 0.9
.param k   = 1
* EventEn = 1 enables the event path: each event resets the champ after the RC delay below.
.param EventEn = 1
*Bev nev GND V={EventEn*1.8*(1-(1-0.5*(1+tanh(k*(V(VON)-Vth))))*(1-0.5*(1+tanh(k*(Vth-V(VnOFF))))))}

*    RC delay: the delayed signal crosses Vth about 0.69*R*C after the event (1 Meg * 1 n = 1 ms tau)
.param Rdelay = 1Meg
.param Cdelay = 1n
*Rdly nev  ndly {Rdelay}
*Cdly ndly GND  {Cdelay}

*    Vreset goes high when either the start-up pulse or the delayed event is high.
*Bres Vreset GND V={1.8*(1-(1-V(nstart)/1.8)*(1-0.5*(1+tanh(k*(V(ndly)-Vth)))))}
Bres Vreset GND V={1.8*(1-(1-V(nstart)/1.8))}

* ---- photocurrent: one step up, one step down, 1 us edges ----
.param Idark = 1e-14
Vtri tri 0 PWL 0 3  6m 3  6.001m 3.07  20m 3.07  20.001m 3  34m 3
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* columns: 1 = time, then in .print order; the last seven are the bias voltages (plot_sweep.py uses them to label .step runs)
*.print tran file=tb_all_one_event.csv format=csv v(tri) i(Bph) v(Vpd) v(xpixel:vpr) v(xpixel:vdiff) v(VON) v(VnOFF) v(xpixel:vnrstchamp) v(Vreset) v(nev) v(ndly)
.print tran file=tb_all_one_event.csv format=csv v(tri) i(Bph) v(Vpd) v(xpixel:vpr) v(xpixel:vdiff) v(VON) v(VnOFF) v(xpixel:vnrstchamp) v(Vreset) v(Vcasc) v(Vg_fb) v(Vipr) v(Vidiff) v(VIon) v(VIoff) v(Vref)
* Max step 1 us so the 1 us edges and the event pulses are resolved.
.tran 0.1u 34m 0 1u

.end
