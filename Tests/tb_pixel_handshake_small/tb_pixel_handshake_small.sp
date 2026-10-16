* Small-contrast fast-step test of the full pixel with the AER handshake (RA, CA) after each step.
* Light steps are the same as tb_all_fast_small: 1 us edges with +0.05, -0.05, +0.1, -0.1, +0.2, -0.2 decade steps
* at 10 pA (steps at 6, 10, 14, 18, 22, 26 ms), a 1 us step at 30 ms up to 1 nA, then the same steps at 1 nA
* (steps at 40, 44, 48, 52, 56, 60 ms). V(tri) is in decades above Idark; tri = 3 is 10 pA.
*
* RA and CA are produced inside the pixel by test_ack from the pixel's own requests (RR, CRON, CROFF). The start-up
* reset is a global Vreset pulldown for the first 100 us.
*
* Run from this folder (as the container user):
*   Xyce tb_pixel_handshake_small.sp
*   gnuplot tb_pixel_handshake_small.gp      (writes tb_pixel_handshake_small.png)

* options, supplies, models, pixel.spice
.inc ../../common.inc

xpixel Vpd Vcasc Vg_fb Vipr Vidiff Vreset VIon VIoff Vref VIoffh RA CA RR CRON CROFF pixel

* ---- bias voltages: edit the .param values here ----
.param Vcasc_val   = .8
.param Vg_fb_val   = 1
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

* ---- global reset: pull Vreset to ground for the first Trst, then let go and let it rise back on its own ----
* (the reset cell's weak pull-up, gated by Vref, recovers Vreset). Rpd is the on-resistance of the pulldown.
.param Trst = 100u
.param Rpd  = 1k
Vgrst grst GND PWL 0 1.8  {Trst} 1.8  {Trst+10n} 0
Bgrst Vreset GND I={V(Vreset)/Rpd*V(grst)/1.8}

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
Vtri tri 0 PWL 0m 3  6m 3  6.001m 3.05  10m 3.05  10.001m 3  14m 3  14.001m 3.1  18m 3.1  18.001m 3  22m 3  22.001m 3.2  26m 3.2  26.001m 3  30m 3  30.001m 5  40m 5  40.001m 5.05  44m 5.05  44.001m 5  48m 5  48.001m 5.1  52m 5.1  52.001m 5  56m 5  56.001m 5.2  60m 5.2  60.001m 5  64m 5  66m 5
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* columns: 1 = time, 2 = tri, 3 = Vpd, 4 = Vpr, 5 = Vdiff, 6 = VON, 7 = VnOFF, 8 = Vreset, 9 = RR, 10 = CRON, 11 = CROFF, 12 = RA, 13 = CA
.print tran file=tb_pixel_handshake_small.csv format=csv v(tri) v(Vpd) v(xpixel:xpc0:vpr) v(xpixel:xpc0:vdiff) v(xpixel:von) v(xpixel:vnoff) v(Vreset) v(RR) v(CRON) v(CROFF) v(RA) v(CA)

* Max step 1 us so the 1 us edges and the event pulses are resolved.
.tran 0.1u 66m 0 1u

.end
