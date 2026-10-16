* One ON event and one OFF event on the full pixel, with the AER handshake (RA, CA) applied after each event,
* using the same sequence as tb_pixel_logic: event -> RA high -> short wait -> CA high -> hold -> event clears.
*
* Light level: V(tri) is in decades above Idark (I = Idark * 10^V(tri)); tri = 3 is 10 pA.
*   6 ms  : step UP   by 0.07 decade in 1 us  -> expected ON event  (VON high)
*   20 ms : step DOWN by 0.14 decade in 1 us (3.07 -> 2.93) -> expected OFF event (VnOFF low)
*           (a 0.07 decade down-step only dips VnOFF to ~1.66 V with these biases, so the step is larger than the up-step)
* RA and CA are timed by hand (PWL below) to follow each event; adjust them if the event latency changes.
*
* Run from this folder (as the container user):
*   Xyce tb_pixel_handshake.sp
*   gnuplot tb_pixel_handshake.gp      (writes tb_pixel_handshake.png)

* options, supplies, models, pixel.spice
.inc ../../common.inc

xpixel Vpd Vcasc Vg_fb Vipr Vidiff VIon VIoff Vref VIoffh RA CA RR CRON CROFF pixel

* ---- bias voltages: edit the .param values here ----
.param Vcasc_val   = .8
.param Vg_fb_val   = 1.15
.param Vipr_val    = .74
.param Vidiff_val  = .40
.param VIon_val    = .42
.param VIoff_val   = .38
* Vref: gate bias of the weak pFET pull-up in the reset cell
.param Vref_val    = 1
.param VIoffh_val  = 0.8

vcasc0      Vcasc       GND DC {Vcasc_val}
vgfb0       Vg_fb       GND DC {Vg_fb_val}
vipr0       Vipr        GND DC {Vipr_val}
vidiff0     Vidiff      GND DC {Vidiff_val}
vion0       VIon        GND DC {VIon_val}
vioff0      VIoff       GND DC {VIoff_val}
vref0       Vref        GND DC {Vref_val}
vioffh0     VIoffh      GND DC {VIoffh_val}

* ---- handshake (10 ns edges) ----
* Start-up (0.5 - 1 ms): a RA/CA pulse resets the change amplifier once at the beginning.
* ON event  (VON high at ~6.024 ms): RA high at 6.04 ms, CA high 10 us later, CA low at 6.08 ms, RA low at 6.09 ms.
* OFF event (VnOFF low at ~20.038 ms): RA high at 20.054 ms, CA high 10 us later, CA low at 20.094 ms, RA low at 20.104 ms.
Vra RA GND PWL 0 0  0.5m 0  0.50001m 1.8  1m 1.8  1.00001m 0  6.04m 0  6.04001m 1.8  6.09m 1.8  6.09001m 0  20.054m 0  20.05401m 1.8  20.104m 1.8  20.10401m 0
Vca CA GND PWL 0 0  0.6m 0  0.60001m 1.8  0.9m 1.8  0.90001m 0  6.05m 0  6.05001m 1.8  6.08m 1.8  6.08001m 0  20.064m 0  20.06401m 1.8  20.094m 1.8  20.09401m 0

* ---- off-pixel pull-ups: the handlers only pull RR, CRON and CROFF down ----
.param Rpu = 100k
.param Cload = 50f
Rrr    Vdd RR    {Rpu}
Rcron  Vdd CRON  {Rpu}
Rcroff Vdd CROFF {Rpu}
Crr    RR    GND {Cload}
Ccron  CRON  GND {Cload}
Ccroff CROFF GND {Cload}

* ---- photocurrent: one step up, one step down, 1 us edges ----
.param Idark = 1e-14
Vtri tri 0 PWL 0 3  6m 3  6.001m 3.07  20m 3.07  20.001m 2.93  34m 2.93
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* columns: 1 = time, 2 = tri, 3 = Vpd, 4 = Vpr, 5 = Vdiff, 6 = VON, 7 = VnOFF, 8 = Vreset, 9 = RR, 10 = CRON, 11 = CROFF, 12 = RA, 13 = CA
.print tran file=tb_pixel_handshake.csv format=csv v(tri) v(Vpd) v(xpixel:xpc0:vpr) v(xpixel:xpc0:vdiff) v(xpixel:von) v(xpixel:vnoff) v(xpixel:vreset) v(RR) v(CRON) v(CROFF) v(RA) v(CA)

* Max step 1 us so the 1 us edges and the event pulses are resolved.
.tran 0.1u 34m 0 1u

.end
