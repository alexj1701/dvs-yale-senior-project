* DVS version of tb_pixel_handshake_small: small-step test of the full DVS pixel (preamp, OTA buffer, binning
* and APS inputs included) with the AER handshake (RA, CA) after each step.
* Light steps up 0.2 decade at a time from tri = 0 to 7 (steps at 10, 20, ... 350 ms), then back down 0.2 decade at a time
* to 0 (steps at 360, 370, ... 700 ms), with 1 us edges and a 10 ms hold at each level. V(tri) is in decades above Idark.
*
* RA and CA are produced inside the pixel by test_ack from the pixel's own requests (RR, CRON, CROFF). The start-up
* reset is the pixel's active-high forceReset input (reset), held high from t = 0 to 1 ms.
*
* Run from this folder (as the container user):
*   Xyce tb_dvs_handshake_small.sp
*   gnuplot tb_dvs_handshake_small.gp      (writes tb_dvs_handshake_small.png)

* options, supplies, models, pixel.spice
.inc ../../../common.inc

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
.param rGND_val    = 0.15
vrgnd0      rgnd        GND DC {rGND_val}

* ---- DVS biases ----
.param VIprMirr_val = 0.3
.param VIprBuff_val = 0.4

viprmirr0   VIprMirr    GND DC {VIprMirr_val}
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

* ---- photocurrent: 0.2 decade steps, 0 -> 7 and back down to 0, 1 us edges, 10 ms hold per step ----
.param Idark = 1e-14
Vtri tri 0 PWL 0 0  10m 0  10.001m 0.2  20m 0.2  20.001m 0.4  30m 0.4  30.001m 0.6  40m 0.6  40.001m 0.8  50m 0.8  50.001m 1  60m 1  60.001m 1.2  70m 1.2  70.001m 1.4  80m 1.4  80.001m 1.6  90m 1.6  90.001m 1.8  100m 1.8  100.001m 2  110m 2  110.001m 2.2  120m 2.2  120.001m 2.4  130m 2.4  130.001m 2.6  140m 2.6  140.001m 2.8  150m 2.8  150.001m 3  160m 3  160.001m 3.2  170m 3.2  170.001m 3.4  180m 3.4  180.001m 3.6  190m 3.6  190.001m 3.8  200m 3.8  200.001m 4  210m 4  210.001m 4.2  220m 4.2  220.001m 4.4  230m 4.4  230.001m 4.6  240m 4.6  240.001m 4.8  250m 4.8  250.001m 5  260m 5  260.001m 5.2  270m 5.2  270.001m 5.4  280m 5.4  280.001m 5.6  290m 5.6  290.001m 5.8  300m 5.8  300.001m 6  310m 6  310.001m 6.2  320m 6.2  320.001m 6.4  330m 6.4  330.001m 6.6  340m 6.6  340.001m 6.8  350m 6.8  350.001m 7  360m 7  360.001m 6.8  370m 6.8  370.001m 6.6  380m 6.6  380.001m 6.4  390m 6.4  390.001m 6.2  400m 6.2  400.001m 6  410m 6  410.001m 5.8  420m 5.8  420.001m 5.6  430m 5.6  430.001m 5.4  440m 5.4  440.001m 5.2  450m 5.2  450.001m 5  460m 5  460.001m 4.8  470m 4.8  470.001m 4.6  480m 4.6  480.001m 4.4  490m 4.4  490.001m 4.2  500m 4.2  500.001m 4  510m 4  510.001m 3.8  520m 3.8  520.001m 3.6  530m 3.6  530.001m 3.4  540m 3.4  540.001m 3.2  550m 3.2  550.001m 3  560m 3  560.001m 2.8  570m 2.8  570.001m 2.6  580m 2.6  580.001m 2.4  590m 2.4  590.001m 2.2  600m 2.2  600.001m 2  610m 2  610.001m 1.8  620m 1.8  620.001m 1.6  630m 1.6  630.001m 1.4  640m 1.4  640.001m 1.2  650m 1.2  650.001m 1  660m 1  660.001m 0.8  670m 0.8  670.001m 0.6  680m 0.6  680.001m 0.4  690m 0.4  690.001m 0.2  700m 0.2  700.001m 0  710m 0
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* columns: 1 = time, 2 = tri, 3 = Vpd, 4 = Vpr, 5 = Vdiff, 6 = VON, 7 = VnOFF, 8 = reset, 9 = RR, 10 = CRON, 11 = CROFF, 12 = RA, 13 = CA,
*          14 = VprAmp, 15 = VprBuff, 16 = rstMirrAmp, 17 = nRstChAmp
.print tran file=tb_dvs_handshake_small.csv format=csv v(tri) v(Vpd) v(xpixel:xpc0:vpr) v(xpixel:xpc0:vdiff) v(xpixel:von) v(xpixel:vnoff) v(reset) v(RR) v(CRON) v(CROFF) v(RA) v(CA) v(xpixel:xpc0:vpramp) v(xpixel:xpc0:vprbuff) v(xpixel:rstmirramp) v(xpixel:nrstchamp)

* Max step 1 us so the 1 us edges and the event pulses are resolved.
.tran 0.1u 710m 0 20u

.end
