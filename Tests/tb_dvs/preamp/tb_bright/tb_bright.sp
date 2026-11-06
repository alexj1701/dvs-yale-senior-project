* Bright-level triangle test of the full DVS pixel (preamp, OTA buffer, binning and APS inputs included) with the AER handshake
* (RA, CA). The light is held at 5.8 decades until 10 ms, ramps up to 6 decades at 20 ms, and back down to 5.8 at 30 ms.
* V(tri) is in decades above Idark.
* Copied from tb_dr (now renamed tb_bright).
*
* RA and CA are produced inside the pixel by test_ack from the pixel's own requests (RR, CRON, CROFF). The start-up
* reset is the pixel's active-high forceReset input (reset), held high from t = 0 to 1 ms.
*
* Run from this folder (as the container user):
*   Xyce tb_bright.sp
*   gnuplot tb_bright.gp      (writes tb_bright.png)

* options, supplies, models, pixel.spice
.inc ../../../../common.inc

* pin order follows the pixel subckt in pixel.act (reset is the active-high forceReset input)
xpixel Vpd Vcasc Vg_fb Vipr Vidiff reset VIon VIoff Vref VIoffh RA CA rgnd CRes TX CSel enableBinning VIprMirr VIprBuff byp RR CRON CROFF pixel

* ---- bias voltages: edit the .param values here ----
.param Vcasc_val   = .8
.param Vg_fb_val   = 0.9
.param Vipr_val    = 0.65
.param Vidiff_val  = .40
.param VIon_val    = .42
.param VIoff_val   = .38
* Vref: gate bias of the weak pFET pull-up in the reset cell
.param Vref_val    = 1.2
.param VIoffh_val  = 0.8

vcasc0      Vcasc       GND DC {Vcasc_val}
vgfb0       Vg_fb       GND DC {Vg_fb_val}
vipr0       Vipr        GND DC {Vipr_val}
vidiff0     Vidiff      GND DC {Vidiff_val}
vion0       VIon        GND DC {VIon_val}
vioff0      VIoff       GND DC {VIoff_val}
vref0       Vref        GND DC {Vref_val}
vioffh0     VIoffh      GND DC {VIoffh_val}

* rGND: ground return of the reset cell's pull-down switches
.param rGND_val    = 0.15
vrgnd0      rgnd        GND DC {rGND_val}

* ---- DVS biases ----
.param VIprMirr_val = 0.3
.param VIprBuff_val = 0.4

viprmirr0   VIprMirr    GND DC {VIprMirr_val}
viprbuff0   VIprBuff    GND DC {VIprBuff_val}

* Bypass of the preamp: 0 = use the preamp, Vdd = bypass it
.param byp_val = 0

vbyp0       byp         GND DC {byp_val}

* ---- binning ----
.param enableBinning_val = 0

vnenbin0    enableBinning GND DC {enableBinning_val}

* ---- APS global shutter ----
.param CRes_val = 0
.param TX_val   = 0
.param CSel_val = 0

vcres0      CRes        GND DC {CRes_val}
vtx0        TX          GND DC {TX_val}
vcsel0      CSel        GND DC {CSel_val}

* ---- forced start-up reset on reset ----
* reset is the pixel's active-high forceReset input: it pulls the internal rstMirrAmp and nRstChAmp low.
* It is held high from t = 0 (so the DC operating point sees it) to 1 ms, then low. PWL values are literals.
Vreset reset GND PWL 0 1.8  1m 1.8  1.00001m 0

* ---- off-pixel pull-ups: the handlers only pull RR, CRON and CROFF down ----
.param Rpu = 100k
.param Cload = 50f
Rrr    Vdd RR    {Rpu}
Rcron  Vdd CRON  {Rpu}
Rcroff Vdd CROFF {Rpu}
Crr    RR    GND {Cload}
Ccron  CRON  GND {Cload}
Ccroff CROFF GND {Cload}

* ---- photocurrent: triangle 5.8 -> 6 -> 5.8 decades (0.02 decade/ms), held at 5.8 for the first 10 ms and after 30 ms ----
.param Idark = 1e-14
Vtri tri 0 PWL 0 5.8  10m 5.8  20m 6  30m 5.8  40m 5.8
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* columns: 1 = time, 2 = tri, 3 = Vpd, 4 = Vpr, 5 = Vdiff, 6 = VON, 7 = VnOFF, 8 = reset, 9 = RR, 10 = CRON, 11 = CROFF, 12 = RA, 13 = CA,
*          14 = VprAmp, 15 = VprBuff, 16 = rstMirrAmp, 17 = nRstChAmp
.print tran file=tb_bright.csv format=csv v(tri) v(Vpd) v(xpixel:xpc0:vpr) v(xpixel:xpc0:vdiff) v(xpixel:von) v(xpixel:vnoff) v(reset) v(RR) v(CRON) v(CROFF) v(RA) v(CA) v(xpixel:xpc0:vpramp) v(xpixel:xpc0:vprbuff) v(xpixel:rstmirramp) v(xpixel:nrstchamp)

* Max step 1 us so the 1 us edges and the event pulses are resolved.
.tran 0.1u 40m 0 20u

.end
