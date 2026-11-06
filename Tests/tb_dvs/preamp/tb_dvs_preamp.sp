* DVS preamplifier biasing on the full pixel, with a 120 dB triangle sweep of the photocurrent like BiasHarness.
*
* Light level: V(tri) is in decades above Idark (I = Idark * 10^V(tri)); 6 decades = 120 dB.
* The photocurrent is held at Idark until 2 ms, ramps up to Idark*1e6 at 101 ms, and back down to Idark at 200 ms.
* RA and CA come from the test_ack cell inside the pixel; reset is the forced start-up reset below,
* after which the reset cell drives rstMirrAmp and nRstChAmp from RA and CA.
*
* Run from this folder (as the container user):
*   Xyce tb_dvs_preamp.sp
*   gnuplot tb_dvs_preamp.gp      (writes tb_dvs_preamp.png)

* options, supplies, models, pixel.spice
.inc ../../../common.inc

* pin order follows the pixel subckt in pixel.act (reset is the active-high forceReset input)
xpixel Vpd Vcasc Vg_fb Vipr Vidiff reset VIon VIoff Vref VIoffh RA CA rgnd CRes TX CSel enableBinning VIprMirr VIprBuff byp RR CRON CROFF pixel

* ---- bias voltages: edit the .param values here ----
.param Vcasc_val   = .8
.param Vg_fb_val   = 1.15
.param Vipr_val    = .74
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
.param rGND_val    = 0
vrgnd0      rgnd        GND DC {rGND_val}

* ---- DVS biases (preamplifier) ----
.param VIprMirr_val = 0.3

viprmirr0   VIprMirr    GND DC {VIprMirr_val}

* OTA buffer bias
.param VIprBuff_val = 0.4

viprbuff0   VIprBuff    GND DC {VIprBuff_val}

* Bypass of the preamp: 0 = use the preamp, 1 = bypass it
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

* ---- photocurrent: triangle in log intensity, 0 -> 6 -> 0 decades (120 dB), held at Idark for the first 2 ms ----
.param Idark = 1e-14
Vtri tri 0 PWL 0 0  2m 0  101m 6  200m 0
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* columns: 1 = time, 2 = tri, 3 = Vpd, 4 = Vpr, 5 = Vdiff, 6 = VON, 7 = VnOFF, 8 = reset, 9 = RR, 10 = CRON, 11 = CROFF, 12 = RA, 13 = CA,
*          14 = VprAmp (preamp output), 15 = rstMirrAmp, 16 = nRstChAmp, 17 = VprBuff (OTA buffer output)
.print tran file=tb_dvs_preamp.csv format=csv v(tri) v(Vpd) v(xpixel:xpc0:vpr) v(xpixel:xpc0:vdiff) v(xpixel:von) v(xpixel:vnoff) v(reset) v(RR) v(CRON) v(CROFF) v(RA) v(CA) v(xpixel:xpc0:vpramp) v(xpixel:rstmirramp) v(xpixel:nrstchamp) v(xpixel:xpc0:vprbuff)

* Max step 10 us, as in BiasHarness, to resolve the event pulses over the 200 ms sweep.
.tran 1u 200m 0 10u

.end
