* DC sweep of VIon at a fixed VIdiff: how VIon sets VON, full pixel attached.
*
* The champ is held in reset: Vreset is a fixed 1.8 V, so VnRstChAmp is pulled low and Vdiff sits at the
* reset level set by VIdiff. VIdiff is held at Vidiff_val, so Vdiff stays at one reset level while VIon is swept.
*
* Run from this folder:
*   Xyce tb_vion_vs_von_dc.sp
*   gnuplot vion_plot.gp      (writes vion_plot.png)

* options, supplies, models, pixel.spice
.inc ../../../common.inc

xpixel Vpd Vcasc Vg_fb Vipr Vidiff VIon VIoff Vreset Vref VON VnOFF pixel
* ---- bias voltages: edit the .param values here ----
.param Vcasc_val  = 0.8
.param Vg_fb_val  = 0.7
.param Vipr_val   = 0.9
.param Vidiff_val = 0.40
.param VIon_val   = 0.450
.param VIoff_val  = 0.350
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

* sweep VIon
.dc vion0 0 1.8 0.005
* columns: 1 = VIon, 2 = VON, 3 = Vdiff, 4 = VnRstChAmp
.print dc file=vion.csv format=csv v(VIon) v(VON) v(xpixel:vdiff) v(xpixel:vnrstchamp)

.end
