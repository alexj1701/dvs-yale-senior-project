* Sweep of VIprMirr with the light held at the middle of the range (tri = 3 decades above Idark = 10 pA),
* then ramped up 0.0074 decade (to tri = 3.0074, 10.17 pA) over 2 ms starting at the halfway point of the run (10 to 12 ms).
* 0.0074 decade is the rise at which the first ON event fired in the 0.05 decade / 2 ms ramp run (VON crossed 0.9 V at 10.296 ms).
*
* Each .step value is a full transient run: reset is forced high from t = 0 to 1 ms (start-up reset), then released
* to the reset cell and the pixel settles at the initial light level.
* RA and CA come from the test_ack cell inside the pixel.
*
* Run from this folder (as the container user):
*   Xyce tb_viprmirr_sweep.sp
*   gnuplot tb_viprmirr_sweep.gp      (writes tb_viprmirr_sweep.png)
* If you change the .step list below, change the vals list at the top of tb_viprmirr_sweep.gp to match.

* options, supplies, models, pixel.spice
.inc ../../../../common.inc

* pin order follows the pixel subckt in pixel.act (reset is the active-high forceReset input)
xpixel Vpd Vcasc Vg_fb Vipr Vidiff reset VIon VIoff Vref VIoffh RA CA rgnd CRes TX CSel enableBinning VIprMirr VIprBuff byp RR CRON CROFF pixel

* ---- bias voltages: edit the .param values here ----
.param Vcasc_val   = .8
.param Vg_fb_val   = 0.9
.param Vipr_val    = 0.74
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
*0.15
.param rGND_val    = 0
vrgnd0      rgnd        GND DC {rGND_val}

* ---- DVS biases (preamplifier) ----
.param VIprMirr_val = 0.4

viprmirr0   VIprMirr    GND DC {VIprMirr_val}

* OTA buffer bias
.param VIprBuff_val = 0.4

viprbuff0   VIprBuff    GND DC {VIprBuff_val}

* Bypass of the preamp: 0 = use the preamp, 1 = bypass it
.param byp_val = 0

vbyp0       byp         GND DC {byp_val}

* ---- sweep: VIprMirr_val ----
* Edit the list of values as needed.
.step VIprMirr_val LIST 0.1 0.2 0.3 0.4

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
* Starts at 3 decades and ramps linearly up to 3.0074 from 10 ms (halfway through the 20 ms run) to 12 ms. PWL values are literals:
* edit the time,decade pairs below to change the ramp.
.param Idark = 1e-14
Vtri tri 0 PWL 0 3  10m 3  12m 3.01  20m 3.01
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* columns: 1 = time, 2 = VIprMirr (identifies the .step), 3 = Vpd, 4 = Vpr, 5 = VprAmp, 6 = Vdiff, 7 = VON, 8 = VnOFF, 9 = reset, 10 = IprMirr (drain current of xM1_Npass in the preamp), 11 = rstMirrAmp, 12 = nRstChAmp, 13 = RA, 14 = CA, 15 = Vmirr1 (preamp mirror gate node), 16 = id of xM3_Npass (mirror PMOS, Vpr to VprAmp), 17 = VprBuff (OTA buffer output)
.print tran file=tb_viprmirr_sweep.csv format=csv v(VIprMirr) v(Vpd) v(xpixel:xpc0:vpr) v(xpixel:xpc0:vpramp) v(xpixel:xpc0:vdiff) v(xpixel:von) v(xpixel:vnoff) v(reset) id(xpixel:xpc0:xpa0:xM1_Npass:msky130_fd_pr__nfet_01v8) v(xpixel:rstmirramp) v(xpixel:nrstchamp) v(RA) v(CA) v(xpixel:xpc0:xpa0:vmirr1) id(xpixel:xpc0:xpa0:xM3_Npass:msky130_fd_pr__pfet_01v8) v(xpixel:xpc0:vprbuff)

.tran 1u 20m 0 10u

.end
