* DC sweep of VIdiff: the champ's reset level Vdiff (and the comparator outputs), full pixel attached.
*
* The champ is held in reset: Vreset is a fixed 1.8 V, so VnRstChAmp is pulled low and Vdiff sits at the
* reset level set by VIdiff. VIon and VIoff are held at their .param values.
*
* Run from this folder:
*   Xyce tb_vidiff_vs_vdiff_dc.sp
*   gnuplot vidiff_plot.gp      (writes vidiff_plot.png)

* options, supplies, models, pixel.spice
.inc ../../../common.inc

xpixel Vpd Vcasc Vg_fb Vipr Vidiff VIon VIoff Vreset Vref VON VnOFF pixel
* ---- bias voltages: edit the .param values here ----
.param Vcasc_val  = 0.8
.param Vg_fb_val  = 0.7
.param Vipr_val   = 0.9
.param Vidiff_val = 0.400
.param VIon_val   = 0.410
.param VIoff_val  = 0.390
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
.dc vidiff0 0 0.8 0.01
* columns: 1 = VIdiff, 2 = Vdiff, 3 = VnRstChAmp, 4 = VON, 5 = VnOFF
.print dc file=vidiff.csv format=csv v(Vidiff) v(xpixel:vdiff) v(xpixel:vnrstchamp) v(VON) v(VnOFF)

.end
