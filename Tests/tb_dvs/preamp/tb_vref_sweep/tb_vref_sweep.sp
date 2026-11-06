* Sweep of Vref (gate bias of the reset cell's pull-ups for rstMirrAmp and nRstChAmp) with the light held at the middle of the range (tri = 3 decades above Idark = 10 pA),
* then stepped up 0.05 decade (to tri = 3.05) at the halfway point of the run (10 ms).
*
* Each .step value is a full transient run: reset is forced high from t = 0 to 1 ms (start-up reset), then released
* to the reset cell and the pixel settles at the initial light level.
* RA and CA come from the test_ack cell inside the pixel.
*
* Run from this folder (as the container user):
*   Xyce tb_vref_sweep.sp
*   gnuplot tb_vref_sweep.gp      (writes tb_vref_sweep.png)
* If you change the .step list below, change the vals list at the top of tb_vref_sweep.gp to match.

* options, supplies, models, pixel.spice
.inc ../../../../common.inc

* pin order follows the pixel subckt in pixel.act (reset is the active-high forceReset input)
xpixel Vpd Vcasc Vg_fb Vipr Vidiff reset VIon VIoff Vref VIoffh RA CA rgnd CRes TX CSel enableBinning VIprMirr VIprBuff byp RR CRON CROFF pixel

* ---- bias voltages: edit the .param values here ----
.param Vcasc_val   = .8
.param Vg_fb_val   = 0.45
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
.param rGND_val    = 0.15
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

* ---- sweep: Vref_val ----
* Edit the list of values as needed.
.step Vref_val LIST 1.0 1.1 1.2

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

* ---- photocurrent: V(tri) in decades above Idark (I = Idark * 10^V(tri)); 3 decades = 10 pA ----
* Starts at 3 decades and steps up to 3.05 at 10 ms (halfway through the 20 ms run), 1 us edge. PWL values are literals:
* edit the time,decade pairs below to change the step.
.param Idark = 1e-14
Vtri tri 0 PWL 0 3  10m 3  10.001m 3.05  20m 3.05
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* columns: 1 = time, 2 = Vref (identifies the .step), 3 = Vpd, 4 = Vpr, 5 = VprAmp, 6 = Vdiff, 7 = VON, 8 = VnOFF, 9 = reset,
*          10 = rstMirrAmp, 11 = nRstChAmp, 12 = RA, 13 = CA, 14 = VprBuff (OTA buffer output)
.print tran file=tb_vref_sweep.csv format=csv v(Vref) v(Vpd) v(xpixel:xpc0:vpr) v(xpixel:xpc0:vpramp) v(xpixel:xpc0:vdiff) v(xpixel:von) v(xpixel:vnoff) v(reset) v(xpixel:rstmirramp) v(xpixel:nrstchamp) v(RA) v(CA) v(xpixel:xpc0:vprbuff)

.tran 1u 20m 0 10u

.end
