* Test of pixel_logic (on_handler, off_handler, reset) driven directly, without pixel_core.
*
* Procedure (times in us):
*   ON event : VON high at 10, RA high at 20, CA high at 30, hold, VON low at 40,
*              then CA low at 45 and RA low at 50 so the sequence can repeat.
*   OFF event: VnOFF LOW at 60 (active low), RA high at 70, CA high at 80, hold,
*              VnOFF high at 90, then CA low at 95 and RA low at 100.
*   VIoffh is held at 0.8 V the whole time.
*
* Run from this folder (as the container user):
*   Xyce tb_pixel_logic.sp
*   gnuplot tb_pixel_logic.gp      (writes tb_pixel_logic.png)

* options, supplies, models, pixel.spice
.inc ../../common.inc

xlogic Vref VIoffh VON VnOFF RA CA Vreset RR CRON CROFF pixel_logic

* ---- static inputs ----
* Vref: gate bias of the weak pFET pull-up in the reset cell
.param Vref_val   = 1
.param VIoffh_val = 0.8
vref0    Vref    GND DC {Vref_val}
vioffh0  VIoffh  GND DC {VIoffh_val}

* ---- stimulus (10 ns edges) ----
Von   VON   GND PWL 0 0  10u 0  10.01u 1.8  40u 1.8  40.01u 0
Vnoff VnOFF GND PWL 0 1.8 60u 1.8 60.01u 0  90u 0   90.01u 1.8
Vra   RA    GND PWL 0 0  20u 0  20.01u 1.8  50u 1.8  50.01u 0   70u 0  70.01u 1.8  100u 1.8  100.01u 0
Vca   CA    GND PWL 0 0  30u 0  30.01u 1.8  45u 1.8  45.01u 0   80u 0  80.01u 1.8   95u 1.8   95.01u 0

* ---- off-pixel pull-ups: the handlers only pull RR, CRON and CROFF down ----
.param Rpu = 100k
.param Cload = 50f
Rrr    Vdd RR    {Rpu}
Rcron  Vdd CRON  {Rpu}
Rcroff Vdd CROFF {Rpu}
Crr    RR    GND {Cload}
Ccron  CRON  GND {Cload}
Ccroff CROFF GND {Cload}

* columns: 1 = time, 2 = VON, 3 = VnOFF, 4 = Vref, 5 = VIoffh, 6 = Vreset, 7 = RR, 8 = CRON, 9 = CROFF, 10 = RA, 11 = CA
.print tran file=tb_pixel_logic.csv format=csv v(VON) v(VnOFF) v(Vref) v(VIoffh) v(Vreset) v(RR) v(CRON) v(CROFF) v(RA) v(CA)

.tran 10n 120u

.end
