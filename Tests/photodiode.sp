* Photodiode extracted from mag/analog/photodiode.mag (sky130A, 19 x 19 um).
* Ports: Vdd = outer deep n-well / n-ring, GND = p-substrate (diode anode), tap = photodiode cathode (connect to Vpd).
* Needs the sky130A diode subcircuit: .lib <pdk>/libs.tech/combined/sky130.lib.spice tt (or models_diodes.spice) before this is used.
.subckt photodiode Vdd GND tap
* diode is a subcircuit in the PDK, so it is an X instance; perim = 4 * 19 um
X0 GND tap sky130_fd_pr__model__parasitic__diode_ps2dn area=361 perim=76
C0 Vdd GND 42.907f
C1 tap GND 0.1178f
C2 Vdd GND 72.7774f
.ends photodiode
