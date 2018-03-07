EESchema Schematic File Version 2
LIBS:BeagleDVB-SPICape-rescue
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:74xgxx
LIBS:ac-dc
LIBS:actel
LIBS:brooktre
LIBS:cmos_ieee
LIBS:dc-dc
LIBS:elec-unifil
LIBS:ftdi
LIBS:gennum
LIBS:hc11
LIBS:ir
LIBS:msp430
LIBS:nxp_armmcu
LIBS:powerint
LIBS:pspice
LIBS:references
LIBS:relays
LIBS:rfcom
LIBS:sensors
LIBS:stm8
LIBS:stm32
LIBS:supertex
LIBS:transf
LIBS:ttl_ieee
LIBS:video
LIBS:bbb
LIBS:BeagleDVB-SPICape
LIBS:switches
LIBS:BeagleDVB-SPICape-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L bbb J2
U 1 1 5474B12B
P 8950 3550
F 0 "J2" H 8950 3450 50  0000 C CNN
F 1 "bbb" H 8950 3650 50  0000 C CNN
F 2 "Custom libs:BBB" H 8950 3550 50  0001 C CNN
F 3 "DOCUMENTATION" H 8950 3550 50  0001 C CNN
	1    8950 3550
	-1   0    0    -1  
$EndComp
$Comp
L +3.3V #PWR01
U 1 1 547502DD
P 7150 1750
F 0 "#PWR01" H 7150 1710 30  0001 C CNN
F 1 "+3.3V" H 7150 1860 30  0000 C CNN
F 2 "" H 7150 1750 60  0000 C CNN
F 3 "" H 7150 1750 60  0000 C CNN
	1    7150 1750
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 547503D8
P 7350 1550
F 0 "#PWR02" H 7350 1550 30  0001 C CNN
F 1 "GND" H 7350 1480 30  0001 C CNN
F 2 "" H 7350 1550 60  0000 C CNN
F 3 "" H 7350 1550 60  0000 C CNN
	1    7350 1550
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR03
U 1 1 54750EA8
P 8000 6050
F 0 "#PWR03" H 8000 6050 30  0001 C CNN
F 1 "GND" H 8000 5980 30  0001 C CNN
F 2 "" H 8000 6050 60  0000 C CNN
F 3 "" H 8000 6050 60  0000 C CNN
	1    8000 6050
	1    0    0    -1  
$EndComp
$Comp
L AT24CS64-SSHM U4
U 1 1 547DE934
P 2050 6200
F 0 "U4" H 1850 6450 40  0000 C CNN
F 1 "AT24CS64-SSHM" H 2350 5900 40  0000 C CNN
F 2 "Housings_SOIC:SOIC-8_3.9x4.9mm_Pitch1.27mm" H 2250 5800 35  0001 C CIN
F 3 "" H 2050 6200 60  0000 C CNN
	1    2050 6200
	1    0    0    -1  
$EndComp
$Comp
L R R12
U 1 1 547E0E04
P 2600 5750
F 0 "R12" V 2680 5750 40  0000 C CNN
F 1 "4K7" V 2607 5751 40  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 2530 5750 30  0001 C CNN
F 3 "" H 2600 5750 30  0000 C CNN
	1    2600 5750
	-1   0    0    1   
$EndComp
$Comp
L R R13
U 1 1 547E0F4E
P 2750 5750
F 0 "R13" V 2830 5750 40  0000 C CNN
F 1 "4K7" V 2757 5751 40  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 2680 5750 30  0001 C CNN
F 3 "" H 2750 5750 30  0000 C CNN
	1    2750 5750
	-1   0    0    1   
$EndComp
$Comp
L R R16
U 1 1 547E1EEF
P 1300 5800
F 0 "R16" V 1380 5800 40  0000 C CNN
F 1 "10K" V 1307 5801 40  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 1230 5800 30  0001 C CNN
F 3 "" H 1300 5800 30  0000 C CNN
	1    1300 5800
	-1   0    0    1   
$EndComp
$Comp
L R R15
U 1 1 547E2062
P 1150 5800
F 0 "R15" V 1230 5800 40  0000 C CNN
F 1 "10K" V 1157 5801 40  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 1080 5800 30  0001 C CNN
F 3 "" H 1150 5800 30  0000 C CNN
	1    1150 5800
	-1   0    0    1   
$EndComp
$Comp
L R R19
U 1 1 547E2104
P 1300 6850
F 0 "R19" V 1380 6850 40  0000 C CNN
F 1 "10K" V 1307 6851 40  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 1230 6850 30  0001 C CNN
F 3 "" H 1300 6850 30  0000 C CNN
	1    1300 6850
	-1   0    0    1   
$EndComp
$Comp
L R R20
U 1 1 547E210A
P 1450 6850
F 0 "R20" V 1530 6850 40  0000 C CNN
F 1 "10K" V 1457 6851 40  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 1380 6850 30  0001 C CNN
F 3 "" H 1450 6850 30  0000 C CNN
	1    1450 6850
	-1   0    0    1   
$EndComp
$Comp
L R R14
U 1 1 547E213E
P 1000 5800
F 0 "R14" V 1080 5800 40  0000 C CNN
F 1 "10K" V 1007 5801 40  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 930 5800 30  0001 C CNN
F 3 "" H 1000 5800 30  0000 C CNN
	1    1000 5800
	-1   0    0    1   
$EndComp
$Comp
L +3.3V #PWR04
U 1 1 547E2F9D
P 2750 5150
F 0 "#PWR04" H 2750 5110 30  0001 C CNN
F 1 "+3.3V" H 2750 5260 30  0000 C CNN
F 2 "" H 2750 5150 60  0000 C CNN
F 3 "" H 2750 5150 60  0000 C CNN
	1    2750 5150
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR05
U 1 1 547E3161
P 1450 7350
F 0 "#PWR05" H 1450 7350 30  0001 C CNN
F 1 "GND" H 1450 7280 30  0001 C CNN
F 2 "" H 1450 7350 60  0000 C CNN
F 3 "" H 1450 7350 60  0000 C CNN
	1    1450 7350
	1    0    0    -1  
$EndComp
$Comp
L R R18
U 1 1 547E3181
P 1000 6850
F 0 "R18" V 1080 6850 40  0000 C CNN
F 1 "10K" V 1007 6851 40  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 930 6850 30  0001 C CNN
F 3 "" H 1000 6850 30  0000 C CNN
	1    1000 6850
	-1   0    0    1   
$EndComp
Text Notes 1600 7150 0    60   ~ 0
*DNP
$Comp
L R R17
U 1 1 547E1F4A
P 1450 5800
F 0 "R17" V 1530 5800 40  0000 C CNN
F 1 "10K" V 1457 5801 40  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 1380 5800 30  0001 C CNN
F 3 "" H 1450 5800 30  0000 C CNN
	1    1450 5800
	-1   0    0    1   
$EndComp
Text Label 10050 5700 2    47   ~ 0
CH1
Text Label 10050 5800 2    47   ~ 0
CH2
Text Label 10050 5500 2    47   ~ 0
CH3
Text Label 10050 5600 2    47   ~ 0
CH4
Text Label 10050 5300 2    47   ~ 0
CH5
Text Label 10050 5400 2    47   ~ 0
CH6
Text Label 10050 5100 2    47   ~ 0
CH7
Text Label 10050 5200 2    47   ~ 0
CH8
Text Label 10050 3200 2    47   ~ 0
CH14
Text Label 10050 3300 2    47   ~ 0
CH13
Text Label 10050 4200 2    47   ~ 0
CH12
Text Label 10050 4100 2    47   ~ 0
CH10
Text Label 10050 3900 2    47   ~ 0
CH9
Text Label 10050 4000 2    47   ~ 0
CH11
Text Label 2850 6250 0    47   ~ 0
EP_SCL
Text Label 2850 6100 0    47   ~ 0
EP_SDA
Text Label 7850 3100 0    47   ~ 0
EP_SCL
Text Label 7850 3200 0    47   ~ 0
EP_SDA
Text Label 7900 2200 2    60   ~ 0
SYS_RESETn
$Comp
L DB25_Female_MountingHoles J1
U 1 1 59CA9793
P 1500 2800
F 0 "J1" H 1500 4250 50  0000 C CNN
F 1 "DB25_Female_MountingHoles" H 1500 4175 50  0000 C CNN
F 2 "Custom libs:DB25FC" H 1500 2800 50  0001 C CNN
F 3 "" H 1500 2800 50  0001 C CNN
	1    1500 2800
	-1   0    0    -1  
$EndComp
Text Label 1800 1600 0    60   ~ 0
TS_MCLK+
Text Label 1800 1700 0    60   ~ 0
TS_MCLK-
Text Label 1800 2000 0    60   ~ 0
TS_7+
Text Label 1800 2100 0    60   ~ 0
TS_7-
Text Label 1800 2200 0    60   ~ 0
TS_6+
Text Label 1800 2300 0    60   ~ 0
TS_6-
Text Label 1800 2400 0    60   ~ 0
TS_5+
Text Label 1800 2500 0    60   ~ 0
TS_5-
Text Label 1800 2600 0    60   ~ 0
TS_4+
Text Label 1800 2700 0    60   ~ 0
TS_4-
Text Label 1800 2800 0    60   ~ 0
TS_3+
Text Label 1800 2900 0    60   ~ 0
TS_3-
Text Label 1800 3000 0    60   ~ 0
TS_2+
Text Label 1800 3100 0    60   ~ 0
TS_2-
Text Label 1800 3200 0    60   ~ 0
TS_1+
Text Label 1800 3300 0    60   ~ 0
TS_1-
Text Label 1800 3400 0    60   ~ 0
TS_0+
Text Label 1800 3500 0    60   ~ 0
TS_0-
Text Label 1800 3600 0    60   ~ 0
TS_MVAL+
Text Label 1800 3700 0    60   ~ 0
TS_MVAL-
Text Label 1800 3800 0    60   ~ 0
TS_MSTRT+
Text Label 1800 3900 0    60   ~ 0
TS_MSTRT-
$Comp
L GND #PWR06
U 1 1 59CA9FA4
P 1500 4200
F 0 "#PWR06" H 1500 3950 50  0001 C CNN
F 1 "GND" H 1500 4050 50  0000 C CNN
F 2 "" H 1500 4200 50  0001 C CNN
F 3 "" H 1500 4200 50  0001 C CNN
	1    1500 4200
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR07
U 1 1 59CA9FD0
P 2200 4000
F 0 "#PWR07" H 2200 3750 50  0001 C CNN
F 1 "GND" H 2200 3850 50  0000 C CNN
F 2 "" H 2200 4000 50  0001 C CNN
F 3 "" H 2200 4000 50  0001 C CNN
	1    2200 4000
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR08
U 1 1 59CAA098
P 2200 1800
F 0 "#PWR08" H 2200 1550 50  0001 C CNN
F 1 "GND" H 2200 1650 50  0000 C CNN
F 2 "" H 2200 1800 50  0001 C CNN
F 3 "" H 2200 1800 50  0001 C CNN
	1    2200 1800
	0    -1   -1   0   
$EndComp
Text Label 3650 3900 0    60   ~ 0
TS_MCLK+
Text Label 3650 4000 0    60   ~ 0
TS_MCLK-
Text Label 3650 3700 0    60   ~ 0
TS_7+
Text Label 3650 3800 0    60   ~ 0
TS_7-
Text Label 3650 3500 0    60   ~ 0
TS_6+
Text Label 3650 3600 0    60   ~ 0
TS_6-
Text Label 3650 3000 0    60   ~ 0
TS_5+
Text Label 3650 3100 0    60   ~ 0
TS_5-
Text Label 3650 2800 0    60   ~ 0
TS_4+
Text Label 3650 2900 0    60   ~ 0
TS_4-
Text Label 3650 2600 0    60   ~ 0
TS_3+
Text Label 3650 2700 0    60   ~ 0
TS_3-
Text Label 3650 2400 0    60   ~ 0
TS_2+
Text Label 3650 2500 0    60   ~ 0
TS_2-
Text Label 3650 1900 0    60   ~ 0
TS_1+
Text Label 3650 2000 0    60   ~ 0
TS_1-
Text Label 3650 1700 0    60   ~ 0
TS_0+
Text Label 3650 1800 0    60   ~ 0
TS_0-
Text Label 3650 1500 0    60   ~ 0
TS_MVAL+
Text Label 3650 1600 0    60   ~ 0
TS_MVAL-
Text Label 3650 1300 0    60   ~ 0
TS_MSTRT+
Text Label 3650 1400 0    60   ~ 0
TS_MSTRT-
$Comp
L R R2
U 1 1 59CACA47
P 3500 1500
F 0 "R2" V 3580 1500 50  0000 C CNN
F 1 "100" V 3500 1500 50  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 3430 1500 50  0001 C CNN
F 3 "" H 3500 1500 50  0001 C CNN
	1    3500 1500
	0    1    1    0   
$EndComp
$Comp
L R R3
U 1 1 59CACA8E
P 3500 1700
F 0 "R3" V 3580 1700 50  0000 C CNN
F 1 "100" V 3500 1700 50  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 3430 1700 50  0001 C CNN
F 3 "" H 3500 1700 50  0001 C CNN
	1    3500 1700
	0    1    1    0   
$EndComp
$Comp
L R R4
U 1 1 59CACB24
P 3500 1900
F 0 "R4" V 3580 1900 50  0000 C CNN
F 1 "100" V 3500 1900 50  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 3430 1900 50  0001 C CNN
F 3 "" H 3500 1900 50  0001 C CNN
	1    3500 1900
	0    1    1    0   
$EndComp
$Comp
L R R5
U 1 1 59CACC40
P 3500 2400
F 0 "R5" V 3580 2400 50  0000 C CNN
F 1 "100" V 3500 2400 50  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 3430 2400 50  0001 C CNN
F 3 "" H 3500 2400 50  0001 C CNN
	1    3500 2400
	0    1    1    0   
$EndComp
$Comp
L R R6
U 1 1 59CACC94
P 3500 2600
F 0 "R6" V 3580 2600 50  0000 C CNN
F 1 "100" V 3500 2600 50  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 3430 2600 50  0001 C CNN
F 3 "" H 3500 2600 50  0001 C CNN
	1    3500 2600
	0    1    1    0   
$EndComp
$Comp
L R R7
U 1 1 59CACCE7
P 3500 2800
F 0 "R7" V 3580 2800 50  0000 C CNN
F 1 "100" V 3500 2800 50  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 3430 2800 50  0001 C CNN
F 3 "" H 3500 2800 50  0001 C CNN
	1    3500 2800
	0    1    1    0   
$EndComp
$Comp
L R R8
U 1 1 59CACD3D
P 3500 3000
F 0 "R8" V 3580 3000 50  0000 C CNN
F 1 "100" V 3500 3000 50  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 3430 3000 50  0001 C CNN
F 3 "" H 3500 3000 50  0001 C CNN
	1    3500 3000
	0    1    1    0   
$EndComp
$Comp
L R R9
U 1 1 59CACDAD
P 3500 3500
F 0 "R9" V 3580 3500 50  0000 C CNN
F 1 "100" V 3500 3500 50  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 3430 3500 50  0001 C CNN
F 3 "" H 3500 3500 50  0001 C CNN
	1    3500 3500
	0    1    1    0   
$EndComp
$Comp
L R R10
U 1 1 59CACE45
P 3500 3700
F 0 "R10" V 3580 3700 50  0000 C CNN
F 1 "100" V 3500 3700 50  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 3430 3700 50  0001 C CNN
F 3 "" H 3500 3700 50  0001 C CNN
	1    3500 3700
	0    1    1    0   
$EndComp
$Comp
L R R11
U 1 1 59CACEDC
P 3500 3900
F 0 "R11" V 3580 3900 50  0000 C CNN
F 1 "100" V 3500 3900 50  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 3430 3900 50  0001 C CNN
F 3 "" H 3500 3900 50  0001 C CNN
	1    3500 3900
	0    1    1    0   
$EndComp
Text Label 5500 1800 0    47   ~ 0
CH1
Text Label 5500 1900 0    47   ~ 0
CH2
Text Label 5500 2500 0    47   ~ 0
CH3
Text Label 5500 2600 0    47   ~ 0
CH4
Text Label 5500 2900 0    47   ~ 0
CH5
Text Label 5500 3000 0    47   ~ 0
CH6
Text Label 5500 3600 0    47   ~ 0
CH7
Text Label 5500 3700 0    47   ~ 0
CH8
Text Label 5500 1500 0    47   ~ 0
CH9
Text Label 5500 4000 0    47   ~ 0
CH10
Text Label 5500 1400 0    47   ~ 0
CH11
$Comp
L SW_Push SW1
U 1 1 59CC0E0F
P 7000 2300
F 0 "SW1" H 7050 2400 50  0000 L CNN
F 1 "SW_Push" H 7000 2240 50  0000 C CNN
F 2 "Buttons_Switches_SMD:SW_SPST_PTS645" H 7000 2500 50  0001 C CNN
F 3 "" H 7000 2500 50  0001 C CNN
	1    7000 2300
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR09
U 1 1 59CC1035
P 7000 2500
F 0 "#PWR09" H 7000 2500 30  0001 C CNN
F 1 "GND" H 7000 2430 30  0001 C CNN
F 2 "" H 7000 2500 60  0000 C CNN
F 3 "" H 7000 2500 60  0000 C CNN
	1    7000 2500
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR010
U 1 1 59CD6D67
P 6200 4300
F 0 "#PWR010" H 6200 4050 50  0001 C CNN
F 1 "GND" H 6200 4150 50  0000 C CNN
F 2 "" H 6200 4300 50  0001 C CNN
F 3 "" H 6200 4300 50  0001 C CNN
	1    6200 4300
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR011
U 1 1 59CD6F58
P 5800 1100
F 0 "#PWR011" H 5800 1060 30  0001 C CNN
F 1 "+3.3V" H 5800 1210 30  0000 C CNN
F 2 "" H 5800 1100 60  0000 C CNN
F 3 "" H 5800 1100 60  0000 C CNN
	1    5800 1100
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 59CD758D
P 5950 1600
F 0 "C1" H 5975 1700 50  0000 L CNN
F 1 "100nF" H 5975 1500 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 5988 1450 50  0001 C CNN
F 3 "" H 5950 1600 50  0001 C CNN
	1    5950 1600
	0    1    1    0   
$EndComp
Wire Wire Line
	8200 1300 7350 1300
Wire Wire Line
	7350 1300 7350 1550
Wire Wire Line
	8200 1400 7350 1400
Connection ~ 7350 1400
Wire Wire Line
	8200 1500 7650 1500
Wire Wire Line
	7650 1500 7650 1750
Wire Wire Line
	7650 1750 7150 1750
Wire Wire Line
	8200 1600 7650 1600
Connection ~ 7650 1600
Wire Wire Line
	8200 5500 8000 5500
Wire Wire Line
	8000 5500 8000 6050
Wire Wire Line
	8200 5600 8000 5600
Connection ~ 8000 5600
Wire Wire Line
	8200 5700 8000 5700
Connection ~ 8000 5700
Wire Wire Line
	8200 5800 8000 5800
Connection ~ 8000 5800
Wire Wire Line
	2450 6250 2950 6250
Wire Wire Line
	2450 6100 2950 6100
Wire Wire Line
	2600 5900 2600 6250
Wire Wire Line
	2750 5900 2750 6100
Wire Wire Line
	1450 6050 1650 6050
Wire Wire Line
	1650 6150 1300 6150
Wire Wire Line
	1300 5950 1300 6700
Wire Wire Line
	1150 6250 1650 6250
Wire Wire Line
	1150 5950 1150 6250
Wire Wire Line
	1450 5950 1450 6700
Connection ~ 1300 6150
Wire Wire Line
	1650 6400 1000 6400
Wire Wire Line
	1000 5950 1000 6700
Wire Wire Line
	1450 5200 1450 5650
Wire Wire Line
	1300 5200 1300 5650
Connection ~ 1450 5200
Wire Wire Line
	1150 5200 1150 5650
Connection ~ 1300 5200
Wire Wire Line
	1000 5200 1000 5650
Connection ~ 1150 5200
Wire Wire Line
	1000 5200 2750 5200
Connection ~ 1000 6400
Wire Wire Line
	1450 7000 1450 7350
Wire Wire Line
	1300 7000 1300 7200
Wire Wire Line
	1000 7200 2050 7200
Connection ~ 1450 7200
Connection ~ 1300 7200
Wire Wire Line
	1000 7000 1000 7200
Wire Wire Line
	2050 5200 2050 5850
Wire Wire Line
	2050 7200 2050 6600
Connection ~ 2050 5200
Connection ~ 1450 6050
Wire Notes Line
	1550 7150 850  7150
Wire Notes Line
	850  7150 850  6550
Wire Notes Line
	850  6550 1550 6550
Wire Notes Line
	1550 6550 1550 7150
Wire Wire Line
	9700 5700 10050 5700
Wire Wire Line
	10050 5800 9700 5800
Wire Wire Line
	10050 5600 9700 5600
Wire Wire Line
	10050 5500 9700 5500
Wire Wire Line
	10050 5400 9700 5400
Wire Wire Line
	10050 5300 9700 5300
Wire Wire Line
	10050 5200 9700 5200
Wire Wire Line
	10050 5100 9700 5100
Wire Wire Line
	9700 3900 10050 3900
Wire Wire Line
	9700 4000 10050 4000
Wire Wire Line
	9700 4100 10050 4100
Wire Wire Line
	9700 4200 10050 4200
Wire Wire Line
	9700 3200 10050 3200
Wire Wire Line
	9700 3300 10050 3300
Connection ~ 2750 6100
Connection ~ 2600 6250
Wire Wire Line
	2750 5150 2750 5600
Wire Wire Line
	2600 5200 2600 5600
Connection ~ 2750 5200
Connection ~ 2600 5200
Wire Wire Line
	8200 3100 7850 3100
Wire Wire Line
	8200 3200 7850 3200
Wire Wire Line
	8200 2200 7900 2200
Wire Wire Line
	1800 1800 2200 1800
Wire Wire Line
	1800 1900 1900 1900
Wire Wire Line
	1900 1900 1900 1800
Connection ~ 1900 1800
Wire Wire Line
	2200 4000 1800 4000
Wire Wire Line
	4000 3900 3650 3900
Wire Wire Line
	3350 4000 4000 4000
Wire Wire Line
	4000 3700 3650 3700
Wire Wire Line
	3350 3800 4000 3800
Wire Wire Line
	4000 3500 3650 3500
Wire Wire Line
	3350 3600 4000 3600
Wire Wire Line
	4000 3000 3650 3000
Wire Wire Line
	3350 3100 4000 3100
Wire Wire Line
	4000 2800 3650 2800
Wire Wire Line
	3350 2900 4000 2900
Wire Wire Line
	4000 2600 3650 2600
Wire Wire Line
	3350 2700 4000 2700
Wire Wire Line
	4000 2400 3650 2400
Wire Wire Line
	3350 2500 4000 2500
Wire Wire Line
	4000 1900 3650 1900
Wire Wire Line
	3350 2000 4000 2000
Wire Wire Line
	4000 1300 3650 1300
Wire Wire Line
	3350 1400 4000 1400
Wire Wire Line
	4000 1500 3650 1500
Wire Wire Line
	3350 1600 4000 1600
Wire Wire Line
	4000 1700 3650 1700
Wire Wire Line
	3350 1800 4000 1800
Wire Wire Line
	3350 3500 3350 3600
Wire Wire Line
	3350 3700 3350 3800
Wire Wire Line
	3350 3900 3350 4000
Wire Wire Line
	3350 3000 3350 3100
Wire Wire Line
	3350 2800 3350 2900
Wire Wire Line
	3350 2600 3350 2700
Wire Wire Line
	3350 1300 3350 1400
Wire Wire Line
	3350 1500 3350 1600
Wire Wire Line
	3350 1700 3350 1800
Wire Wire Line
	3350 1900 3350 2000
Wire Wire Line
	3350 2400 3350 2500
Wire Wire Line
	8200 2100 7000 2100
Wire Wire Line
	5800 1100 5800 3800
Wire Wire Line
	5800 1600 5500 1600
Wire Wire Line
	5800 2700 5500 2700
Connection ~ 5800 1600
Wire Wire Line
	5800 3800 5500 3800
Connection ~ 5800 2700
Wire Wire Line
	5500 1700 6100 1700
Wire Wire Line
	6100 1700 6100 1600
Wire Wire Line
	5500 2800 6100 2800
Wire Wire Line
	6100 2800 6100 2700
Wire Wire Line
	5500 3900 6100 3900
Wire Wire Line
	6100 3900 6100 3800
Wire Wire Line
	6100 1600 6200 1600
Wire Wire Line
	6200 1600 6200 4300
Wire Wire Line
	6100 2700 6200 2700
Connection ~ 6200 2700
Wire Wire Line
	6100 3800 6200 3800
Connection ~ 6200 3800
$Comp
L C C2
U 1 1 59CD8093
P 5950 2700
F 0 "C2" H 5975 2800 50  0000 L CNN
F 1 "100nF" H 5975 2600 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 5988 2550 50  0001 C CNN
F 3 "" H 5950 2700 50  0001 C CNN
	1    5950 2700
	0    1    1    0   
$EndComp
$Comp
L C C3
U 1 1 59CD8124
P 5950 3800
F 0 "C3" H 5975 3900 50  0000 L CNN
F 1 "100nF" H 5975 3700 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805" H 5988 3650 50  0001 C CNN
F 3 "" H 5950 3800 50  0001 C CNN
	1    5950 3800
	0    1    1    0   
$EndComp
Wire Wire Line
	5500 1300 5800 1300
Connection ~ 5800 1300
Wire Wire Line
	5500 2400 5800 2400
Connection ~ 5800 2400
Wire Wire Line
	5500 3500 5800 3500
Connection ~ 5800 3500
Wire Wire Line
	5500 2000 6400 2000
Wire Wire Line
	6400 2000 6400 4200
Wire Wire Line
	6400 3100 5500 3100
Wire Wire Line
	6400 4200 5500 4200
Connection ~ 6400 3100
Text Label 6400 3100 0    60   ~ 0
SYS_RESETn
$Comp
L R R1
U 1 1 59CABE12
P 3500 1300
F 0 "R1" V 3580 1300 50  0000 C CNN
F 1 "100" V 3500 1300 50  0000 C CNN
F 2 "Resistors_SMD:R_0603" V 3430 1300 50  0001 C CNN
F 3 "" H 3500 1300 50  0001 C CNN
	1    3500 1300
	0    1    1    0   
$EndComp
$Comp
L DS90LV048A U1
U 1 1 59D25262
P 4850 1650
F 0 "U1" H 5050 2150 50  0000 C CNN
F 1 "DS90LV048A" H 4575 2125 50  0000 C BNN
F 2 "Housings_SOIC:SOIC-16W_5.3x10.2mm_Pitch1.27mm" H 4450 1150 50  0001 C CNN
F 3 "DOCUMENTATION" H 4950 1150 50  0001 C CNN
	1    4850 1650
	1    0    0    -1  
$EndComp
$Comp
L DS90LV048A U2
U 1 1 59D25303
P 4850 2750
F 0 "U2" H 5050 3250 50  0000 C CNN
F 1 "DS90LV048A" H 4575 3225 50  0000 C BNN
F 2 "Housings_SOIC:SOIC-16W_5.3x10.2mm_Pitch1.27mm" H 4450 2250 50  0001 C CNN
F 3 "DOCUMENTATION" H 4950 2250 50  0001 C CNN
	1    4850 2750
	1    0    0    -1  
$EndComp
$Comp
L DS90LV048A U3
U 1 1 59D25366
P 4850 3850
F 0 "U3" H 5050 4350 50  0000 C CNN
F 1 "DS90LV048A" H 4575 4325 50  0000 C BNN
F 2 "Housings_SOIC:SOIC-16W_5.3x10.2mm_Pitch1.27mm" H 4450 3350 50  0001 C CNN
F 3 "DOCUMENTATION" H 4950 3350 50  0001 C CNN
	1    4850 3850
	1    0    0    -1  
$EndComp
$EndSCHEMATC
