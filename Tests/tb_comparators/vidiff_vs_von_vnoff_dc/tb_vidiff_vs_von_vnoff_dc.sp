* DC sweep of VIdiff over a narrow window: Vdiff (the champ's reset level) is moved up and down around its
* set-point value by a few contrast steps, to see how VON, VnOFF and VnRstChAmp respond, full pixel attached.
* The champ is held in reset (Vreset fixed at 1.8 V), so Vdiff is the reset level set by VIdiff.
* Plot against Vdiff: 1 contrast step of 0.05 decade is about 72 mV of Vdiff at the idle level (measured in
* the fast-step transient test, champ gain about -22), so the window below spans roughly +/-4 steps.
*
* Run from this folder:
*   Xyce tb_vidiff_vs_von_vnoff_dc.sp
*   gnuplot window_plot.gp      (writes window_plot.png)

* options, supplies, models, pixel.spice
.inc ../../../common.inc

xpixel Vpd Vcasc Vg_fb Vipr Vidiff VIon VIoff Vreset Vref VON VnOFF pixel
* ---- bias voltages: edit the .param values here ----
.param Vcasc_val  = .8
.param Vg_fb_val  = 1.15
.param Vipr_val   = .74
.param Vidiff_val = .40
.param VIon_val   = .48
.param VIoff_val  = .32
* Vref: gate bias of the weak pFET in the reset cell's pull-up (1.4 V = weakly inverted)
.param Vref_val   = 1.4

vcasc0      Vcasc       GND DC {Vcasc_val}
vgfb0       Vg_fb       GND DC {Vg_fb_val}
vipr0       Vipr        GND DC {Vipr_val}
vidiff0     Vidiff      GND DC {Vidiff_val}
vion0       VIon        GND DC {VIon_val}
vioff0      VIoff       GND DC {VIoff_val}
vref0       Vref        GND DC {Vref_val}

* Vreset held high: champ in reset (VnRstChAmp low)
vreset0     Vreset      GND DC 1.8

* dark current on the photodiode node, so Vpd has a DC path
.param Idark = 1e-14
Iph  Vpd GND DC {Idark}

* sweep VIdiff
.dc vidiff0 0.2 0.56 0.001
* columns: 1 = VIdiff, 2 = Vdiff, 3 = VnRstChAmp, 4 = VON, 5 = VnOFF
.print dc file=window.csv format=csv v(Vidiff) v(xpixel:vdiff) v(xpixel:vnrstchamp) v(VON) v(VnOFF)

.end
