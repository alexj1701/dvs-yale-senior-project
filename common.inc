* Shared include for every test harness: simulator options, supplies, models, pixel netlist.
* Use from a harness in Tests/<name>/ with:   .inc ../../common.inc
* (Relative paths here are resolved from this file's folder, so pixel.spice is found
*  wherever the harness lives.)

.options device gmin=1e-15

.global vdd
.global gnd

vpwr0 vdd 0 dc 1.8v
vpwr1 gnd 0 dc 0.0v

.inc /usr/local/cad/conf/sky130l/models.sp
.inc pixel.spice
