.title ssAD and band gap reference
.protect
.lib "~/spice_model/cic018.l"tt
.unprotect
.temp 25
.option
+ post				$output waveform to user
+ acout=0 runlvl=6	$increase simulation accuracy
+ captable			$list every node capacitance

.include "./bgr.spi"
.include './ssadc.spi'


.param VSS=0
.param Fs=20k   
.param sampling_duty_cycle=0.2
.param cnt_freq=1.594x    
.param NFIN=511
.param NSAMPLE=1024

.param cnt_period='1/cnt_freq'
.param Ts='1/Fs'

******************** you can modify start***********************
.param VDD=1.8			$ you could only have three type of VDD(1.62V, 1.8V 1.98V)
						$ There is no spec when supply voltage=1.62V and 1.98V
						$ just for you to observe the performance change of ssAD
						
.param Vb=0.5			$ comparator biasing voltage

.param ramp_max = 1.3	$ ramping signal maximum value
.param ramp_min = 0.35	$ ramping signal minimum value

.param VCM = 0.825		$ common mode of input sine wave
.param amplitude = 473m	$ amplitude of input sine wave  " (ramp_max-ramp_min)/2 - 2mV "
******************** you can modify end*************************



*************define voltage source*************
Vdd vdd gnd dc=VDD
Vss vss gnd dc=VSS
Vb Vb GND Vb

Vramp_in ramp_in vss dc=0 pulse(ramp_min ramp_max 'Ts/2 + sampling_duty_cycle * Ts + 5n' 'Ts - sampling_duty_cycle * Ts - 5n - 0.01 * Ts' 0.1n 5n Ts)
Vinput input gnd sin(VCM 474m 'Fs*NFIN/NSAMPLE')

************* sampling clk *****************
VClks Clks gnd pulse(0 VDD 'Ts/2' 0.1n 0.1n 'sampling_duty_cycle * Ts' Ts)
VClksb Clksb gnd pulse(VDD 0 'Ts/2' 0.1n 0.1n 'sampling_duty_cycle * Ts' Ts)

************* control signal for counter *****************
VCNT_RST_N CNT_RST_N gnd pulse(VDD 0 'Ts/2 + sampling_duty_cycle * Ts - 0.01 * Ts' 0.1n 0.1n '0.01 * Ts' Ts)
VCNT_EN CNT_EN gnd pulse(0 VDD 'Ts/2 + sampling_duty_cycle * Ts + 5n' 0.1n 0.1n '0.79 * Ts' Ts)
VCNT_ENb CNT_ENb gnd pulse(VDD 0 'Ts/2 + sampling_duty_cycle * Ts + 5n' 0.1n 0.1n '0.79 * Ts' Ts)
VClk_CNT Clk_CNT gnd pulse(0 VDD 'Ts/2 + 5n + cnt_period/2 + 20n' 0.1n 0.1n 'cnt_period/2' cnt_period)

************* control signal for latch after counter *****************
Vlatch latch gnd pulse(0 VDD 'Ts/2 + Ts - 5n' 0.1n 0.1n 5n Ts)
Vlatchb latchb gnd pulse(VDD 0 'Ts/2 + Ts - 5n' 0.1n 0.1n 5n Ts)


*************************************************
**** below are the circuit you have designed ****
*************************************************
*************band gap reference(BGR)*************
x1 VDD VSS Vref_0 bgr			$ your band gap reference(BGR) circuit
Eop Vref Vss Vref_0 Vref 10000	$ the unity gain buffer between BGR and ssAD 

*************single slope AD(ssAD)*************
X_ssAD Vref Vss Clks Clksb Clk_CNT CNT_EN CNT_ENb CNT_RST_N input ramp_in vb ssAD


************ analysis ************
.tran 1n '(NSAMPLE+1)*Ts'


