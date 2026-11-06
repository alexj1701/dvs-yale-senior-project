* DC sweep of Vipr, stepped over Vcasc: M_pr current, Vpr and Vpd, full pixel attached.
*
* Run from this folder:
*   Xyce tb_ipr_vs_vcasc.sp
*   gnuplot ipr_plot.gp      (writes ipr_plot.png)

* options, supplies, models, pixel.spice
.inc ../../../common.inc

* DC convergence aid to try if the DC solve still fails (larger gmin ties every node to ground more strongly):
*.options device gmin=1e-12

* pin order follows the pixel subckt in pixel.act (reset is the active-high forceReset input)
xpixel Vpd Vcasc Vg_fb Vipr Vidiff reset VIon VIoff Vref VIoffh RA CA rgnd CRes TX CSel enableBinning VIprMirr VIprBuff byp RR CRON CROFF pixel

* ---- bias voltages: edit the .param values here ----
.param Vcasc_val   = .8
.param Vg_fb_val   = .5
.param Vipr_val    = 1.2
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

* ---- DVS biases ----
.param VIprMirr_val = 0.3
.param VIprBuff_val = 0.4

viprmirr0   VIprMirr    GND DC {VIprMirr_val}
viprbuff0   VIprBuff    GND DC {VIprBuff_val}

* Bypass of the preamp: 0 = use the preamp, 1 = bypass it
.param byp_val = 0

vbyp0       byp         GND DC {byp_val}

* ---- binning ----
* DC convergence aid: 1.8 V turns the binning switches on, which ties Vpd_bin and Vpr_bin to Vpd and Vpr. With 0 V they are
* floating nodes (only off switches attached), which can make the DC operating point singular. Binning has no effect on
* Vpr or Vpd in DC, so this does not change the photoreceptor result.
.param enableBinning_val = 1.8

vnenbin0    enableBinning GND DC {enableBinning_val}

* ---- APS global shutter ----
* DC convergence aid: TX and CSel at 1.8 V connect the APS internal nodes and apsOut to Vpd and to each other, so they are
* not floating. CRes stays 0 so the reset switch does not pull Vpd up to Vdd.
.param CRes_val = 0
.param TX_val   = 1.8
.param CSel_val = 1.8

vcres0      CRes        GND DC {CRes_val}
vtx0        TX          GND DC {TX_val}
vcsel0      CSel        GND DC {CSel_val}


* ---- reset ----
* reset is the pixel's active-high forceReset input. In this DC test it is held at 1.8 V, so the internal rstMirrAmp and
* nRstChAmp are held low (preamp mirror and change amplifier in reset) at every point. The behavioral start-up/event/delay
* circuit the transient tests use is not needed here (it was disabled with EventEn = 0 and only adds nodes and B sources).
Vreset reset GND DC 1.8

* ---- off-pixel pull-ups: the handlers only pull RR, CRON and CROFF down (RA and CA come from test_ack inside the pixel) ----
.param Rpu = 100k
.param Cload = 50f
Rrr    Vdd RR    {Rpu}
Rcron  Vdd CRON  {Rpu}
Rcroff Vdd CROFF {Rpu}
Crr    RR    GND {Cload}
Ccron  CRON  GND {Cload}
Ccroff CROFF GND {Cload}

* ---- photocurrent: triangle in log intensity, pulled from Vpd to ground ----
* V(tri) is in decades: I = Idark * 10^V(tri). Held at 0 (dark current) until 2 ms so the start-up reset finishes first,
* then a triangle 0 -> 6 -> 0 V ending at 200 ms,
* so the current sweeps Idark -> Idark*1e6 -> Idark (change the 6 to change the decades).
.param Idark = 1e-14
Vtri tri 0 PWL 0 0 2m 0 101m 6 200m 0
Bph  Vpd GND I={Idark*exp(V(tri)*2.302585)}

* Outer loop: repeat the whole Vipr sweep for each value of Vcasc.
.step Vcasc_val LIST 0.3 0.4 0.5 0.6 0.7 0.8 1 1.1 1.2
.dc vipr0 0.6 1.6 0.01
* columns: 1 = Vcasc, 2 = Vipr, 3 = Vpr, 4 = Id of M_pr (pull-up pFET, gate = Vipr), 5 = Vpd
.print dc file=ipr.csv format=csv v(Vcasc) v(Vipr) v(xpixel:xpc0:vpr) id(xpixel:xpc0:xpr0:xM0_N:msky130_fd_pr__pfet_01v8) v(Vpd)

.end
