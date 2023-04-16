v {xschem version=3.1.0 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 60 -320 60 -310 {
lab=VDD}
N 60 -250 60 -230 {
lab=GND}
N 220 -230 220 -210 {
lab=GND}
N 220 -220 280 -220 {
lab=GND}
N 280 -230 280 -220 {
lab=GND}
N 220 -300 220 -290 {
lab=en_qutrans}
N 280 -300 280 -290 {
lab=ts_cfg4}
N 340 -220 400 -220 {
lab=GND}
N 400 -230 400 -220 {
lab=GND}
N 340 -300 340 -290 {
lab=ts_cfg3}
N 400 -300 400 -290 {
lab=ts_cfg2}
N 460 -230 460 -220 {
lab=GND}
N 460 -300 460 -290 {
lab=ts_cfg1}
N 280 -220 340 -220 {
lab=GND}
N 340 -230 340 -220 {
lab=GND}
N 400 -220 460 -220 {
lab=GND}
N 520 -230 520 -220 {
lab=GND}
N 520 -300 520 -290 {
lab=ts_cfg0}
N 460 -220 520 -220 {
lab=GND}
N 660 -400 700 -400 {
lab=rst}
N 660 -220 660 -210 {
lab=GND}
N 660 -340 660 -330 {
lab=GND}
N 660 -290 660 -280 {
lab=clk}
N 660 -290 700 -290 {
lab=clk}
N 1330 -590 1330 -570 {
lab=VDD}
N 1330 -360 1330 -340 {
lab=GND}
N 1060 -540 1130 -540 {
lab=clk}
N 1060 -520 1130 -520 {
lab=rst}
N 1060 -500 1130 -500 {
lab=en_qutrans}
N 1060 -480 1130 -480 {
lab=ts_cfg0}
N 1060 -460 1130 -460 {
lab=ts_cfg1}
N 1060 -440 1130 -440 {
lab=ts_cfg2}
N 1060 -420 1130 -420 {
lab=ts_cfg3}
N 1060 -400 1130 -400 {
lab=ts_cfg4}
N 1510 -540 1580 -540 {
lab=state0}
N 1510 -520 1580 -520 {lab=state1}
N 1510 -400 1580 -400 {
lab=pwm_out}
N 1740 -280 1740 -240 {
lab=GND}
N 1740 -260 1920 -260 {
lab=GND}
N 1920 -280 1920 -260 {
lab=GND}
N 1840 -280 1840 -260 {
lab=GND}
N 1580 -400 1740 -400 {
lab=pwm_out}
N 1740 -400 1740 -340 {
lab=pwm_out}
N 1580 -520 1840 -520 {
lab=state1}
N 1840 -520 1840 -340 {
lab=state1}
N 1580 -540 1920 -540 {
lab=state0}
N 1920 -540 1920 -340 {
lab=state0}
C {devices/title.sym} 160 -30 0 0 {name=l1 author="Harald Pretl, Institute for Integrated Circuits, Johannes Kepler University"}
C {devices/vsource.sym} 60 -280 0 0 {name=VDD1 value=1.8}
C {devices/vdd.sym} 60 -320 0 0 {name=l2 lab=VDD}
C {devices/gnd.sym} 60 -230 0 0 {name=l3 lab=GND}
C {devices/code.sym} 30 -570 0 0 {name=TT_MODELS
only_toplevel=true
format="tcleval( @value )"
value="
** opencircuitdesign pdks install
.lib $::SKYWATER_MODELS/sky130.lib.spice tt

"
spice_ignore=false}
C {devices/simulator_commands.sym} 210 -570 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
* ngspice commands
****************
.include ../hpretl_tt03_temperature_sensor.pex.spice
*.include /foss/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice

****************
* Misc
****************
.param fclk=10k

*.save all
.save clk rst en_qutrans ts_cfg4 ts_cfg3 ts_cfg2 ts_cfg1 ts_cfg0 state0 state1 pwm_out i(VDD1)
.control
set num_threads=6
tran 1n 0.5m

plot clk rst pwm_out

set wr_vecnames
write tb_tempsens.raw clk rst en_qutrans ts_cfg4 ts_cfg3 ts_cfg2 ts_cfg1 ts_cfg0 state0 state1 pwm_out
.endc
"}
C {devices/gnd.sym} 220 -210 0 0 {name=l21 lab=GND}
C {devices/lab_wire.sym} 220 -300 1 0 {name=l22 sig_type=std_logic lab=en_qutrans}
C {devices/lab_wire.sym} 280 -300 1 0 {name=l23 sig_type=std_logic lab=ts_cfg4}
C {devices/lab_wire.sym} 340 -300 1 0 {name=l24 sig_type=std_logic lab=ts_cfg3}
C {devices/lab_wire.sym} 400 -300 1 0 {name=l25 sig_type=std_logic lab=ts_cfg2}
C {devices/lab_wire.sym} 460 -300 1 0 {name=l26 sig_type=std_logic lab=ts_cfg1}
C {devices/lab_wire.sym} 520 -300 1 0 {name=l27 sig_type=std_logic lab=ts_cfg0}
C {devices/vsource.sym} 220 -260 0 0 {name=V19 value=1.8
}
C {devices/vsource.sym} 280 -260 0 0 {name=V20 value=0}
C {devices/vsource.sym} 340 -260 0 0 {name=V21 value=1.8}
C {devices/vsource.sym} 400 -260 0 0 {name=V22 value=0}
C {devices/vsource.sym} 460 -260 0 0 {name=V23 value=0}
C {devices/vsource.sym} 520 -260 0 0 {name=V24 value=0}
C {devices/vsource.sym} 660 -250 0 0 {name=VCM value="0 pulse(0 1.8 1u 1n 1n \{0.5/fclk\} \{1/fclk\})"}
C {devices/gnd.sym} 660 -210 0 0 {name=l4 lab=GND}
C {devices/vsource.sym} 660 -370 0 0 {name=VRES value="0 pwl(0 1.8 \{0.5/fclk\} 1.8 \{0.5/fclk+1n\} 0)"}
C {devices/gnd.sym} 660 -330 0 0 {name=l5 lab=GND}
C {devices/lab_wire.sym} 700 -400 0 1 {name=l6 sig_type=std_logic lab=rst}
C {devices/lab_wire.sym} 700 -290 0 1 {name=l7 sig_type=std_logic lab=clk}
C {hpretl_tt03_temperature_sensor.sym} 1150 -380 0 0 {name=x1}
C {devices/gnd.sym} 1330 -340 0 0 {name=l8 lab=GND}
C {devices/vdd.sym} 1330 -590 0 0 {name=l9 lab=VDD}
C {devices/lab_wire.sym} 1060 -520 0 1 {name=l10 sig_type=std_logic lab=rst}
C {devices/lab_wire.sym} 1060 -540 0 1 {name=l11 sig_type=std_logic lab=clk}
C {devices/lab_wire.sym} 1060 -500 0 1 {name=l12 sig_type=std_logic lab=en_qutrans}
C {devices/lab_wire.sym} 1060 -480 0 1 {name=l13 sig_type=std_logic lab=ts_cfg0}
C {devices/lab_wire.sym} 1060 -460 0 1 {name=l14 sig_type=std_logic lab=ts_cfg1}
C {devices/lab_wire.sym} 1060 -440 0 1 {name=l15 sig_type=std_logic lab=ts_cfg2}
C {devices/lab_wire.sym} 1060 -420 0 1 {name=l16 sig_type=std_logic lab=ts_cfg3}
C {devices/lab_wire.sym} 1060 -400 0 1 {name=l17 sig_type=std_logic lab=ts_cfg4}
C {devices/lab_wire.sym} 1640 -540 0 1 {name=l18 sig_type=std_logic lab=state0}
C {devices/lab_wire.sym} 1640 -520 0 1 {name=l19 sig_type=std_logic lab=state1}
C {devices/lab_wire.sym} 1640 -400 0 1 {name=l20 sig_type=std_logic lab=pwm_out}
C {devices/capa.sym} 1740 -310 0 0 {name=C1
m=1
value=10f}
C {devices/gnd.sym} 1740 -240 0 0 {name=l28 lab=GND}
C {devices/capa.sym} 1840 -310 0 0 {name=C3
m=1
value=10f}
C {devices/capa.sym} 1920 -310 0 0 {name=C4
m=1
value=10f}
