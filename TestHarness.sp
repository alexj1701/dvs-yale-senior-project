* Every input voltage needs a defined input

* 
* Xyce simulation example
*
*
* Default supply nodes 
*
.global vdd
.global gnd

*
* Set Vdd to 1.8V, GND to 0V
*
vpwr0 vdd 0 dc 1.8v
vpwr1 gnd 0 dc 0.0v

*
* include nfet and pfet models
*
.inc /usr/local/cad/conf/sky130l/models.sp

*
* include circuit model
*
.inc pixel.spice

xpixel Vpd Vcasc Vg_fb Vipr Vidiff VnRstChAmp VIon VIoff Vreset VON VnOFF pixel

vcasc0 Vcasc GND DC .1
vgfb0 Vg_fb GND DC 1.6
vipr0 Vipr GND DC .1
vidiff0 Vidiff GND DC .250
vnrstchamp0 VnRstChAmp GND DC 0
vion0 VIon GND DC .275
vioff0 VIoff GND DC .200
vreset0 Vreset GND DC .01

*
* set the voltage of "in" to be a piecewise linear  (PWL)
* curve. The rest of the parameters are (time,voltage) pairs. 
*
vtst Vpd 0 PWL 0 0 100m .1

*
* Save the output in "gnuplot" friendly format
* Print out the voltages for in and out
* You can also say v(*) for all the voltages
*
.print tran file=test.plot format=gnuplot v(Vpd) v(Vcasc) v(Vg_fb) v(Vipr) v(Vidiff) v(VnRstChAmp) v(VIon) v(VIoff) v(Vreset) v(VON) v(VnOFF) v(xpixel:vdiff)  v(xpixel:vpr)

*
* Run a transient simulation with 1ps timestep
* for 50 nanoseconds
*
.tran 1p 200m noop

.end
