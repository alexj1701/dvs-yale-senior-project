* SPICE3 file created from photodiode.ext - technology: sky130A

.subckt photodiode Vdd GND tap
.model dpd D (IS=6.1e-17 N=1.08 CJO=<C0> M=0.49 VJ=0.5348)C0 Vdd GND 42.907f
C1 tap GND 0.1178f
C2 Vdd GND 72.7774f
.ends photodiode
