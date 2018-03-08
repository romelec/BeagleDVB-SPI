;* PRU1 Firmware for BeagleDVB-SPI
;*
;* Copyright (C) 2014 Kumar Abhishek <abhishek@theembeddedkitchen.net>
;* Copyright (C) 2017 R Colomban
;*
;* This file is a part of the BeagleDVB-SPI project
;*
;* This program is free software; you can redistribute it and/or modify
;* it under the terms of the GNU General Public License version 2 as
;* published by the Free Software Foundation.

	.include "beagledvbspi-pru-defs.inc"

NOP	.macro
	 ADD R0.b0, R0.b0, R0.b0
	.endm

; Generic delay loop macro
; Also includes a post-finish op
DELAY	.macro Rx, op
	SUB	R0, Rx, 2
	QBEQ	$E?, R0, 0
$M?:	SUB	R0, R0, 1
	QBNE	$M?, R0, 0
$E?:	op
	.endm

WAITCLK .macro
	WBC    R31.b1, 1
	NOP
	WBS    R31.b1, 1
	.endm

;WAITCLK .macro
;	NOP
;	NOP
;	NOP
;	NOP
;	.endm

	.sect ".text:main"
	.global asm_main
asm_main:
	; Set C28 in this PRU's bank =0x24000
	LDI32  R0, CTPPR_0+0x2000               ; Add 0x2000
	LDI    R1, 0x00000240                   ; C28 = 00_0240_00h = PRU1 CFG Registers
	SBBO   &R1, R0, 0, 4

	; Configure R2 = 0x0000 - ptr to PRU1 RAM
	LDI    R2, 0

	; Enable the cycle counter
	LBCO   &R0, C28, 0, 4
	SET    R0, R0, 3
	SBCO   &R0, C28, 0, 4

	; Load Cycle count reading to registers [LBCO=4 cycles, SBCO=2 cycles]
	LBCO   &R0, C28, 0x0C, 4
	SBCO   &R0, C24, 0, 4

	; Load magic bytes into R2
	LDI32  R0, 0xBEA61E10

	; Wait for PRU0 to be configured (no actual data needed)
	; This will occur from an downcall issued to us by PRU0
	HALT

	; Jump to the appropriate sample loop
	; TODO

	LDI    R31, PRU0_ARM_INTERRUPT_B + 16   ; Signal SYSEV_PRU0_TO_ARM_B to kernel driver
	HALT

	; Sample starts here
	; Maintain global bytes transferred counter (8 byte bursts)
	LDI    R29, 0

    ;JMP test_sample_dual
    JMP sample_dual
    ;JMP sample

;sampleincnumberstest:
;	LDI    R21, 0
;	NOP
;	NOP
;	NOP
;$S1:	ADD    R22, R21, 1
;	NOP
;	NOP
;	NOP
;	ADD    R23, R22, 1
;	NOP
;	NOP
;	NOP
;	ADD    R24, R23, 1
;	NOP
;	NOP
;	NOP
;	ADD    R25, R24, 1
;	NOP
;	NOP
;	NOP
;	ADD    R26, R25, 1
;	NOP
;	NOP
;	NOP
;	ADD    R27, R26, 1
;	NOP
;	NOP
;	NOP
;	ADD    R28, R27, 1
	;XOUT   10, &R21, 36
	;LDI    R31, PRU1_PRU0_INTERRUPT + 16
;	NOP
;	ADD    R21, R28, 1
;	NOP
;	NOP
;	JMP    $S1



test_sample_dual:
	MOV    R21.b0, R31.b0
	NOP
	MOV    R21.b1, R31.b1
	NOP
$sample100m8$2:
	MOV    R21.b2, R31.b0
	NOP
	MOV    R21.b3, R31.b1
	NOP
	MOV    R22.b0, R31.b0
	NOP
	MOV    R22.b1, R31.b1
	NOP
	MOV    R22.b2, R31.b0
	NOP
	MOV    R22.b3, R31.b1
	NOP
	MOV    R23.b0, R31.b0
	NOP
	MOV    R23.b1, R31.b1
	NOP
	MOV    R23.b2, R31.b0
	NOP
	MOV    R23.b3, R31.b1
	NOP
	MOV    R24.b0, R31.b0
	NOP
	MOV    R24.b1, R31.b1
	NOP
	MOV    R24.b2, R31.b0
	NOP
	MOV    R24.b3, R31.b1
	NOP
	MOV    R25.b0, R31.b0
	NOP
	MOV    R25.b1, R31.b1
	NOP
	MOV    R25.b2, R31.b0
	NOP
	MOV    R25.b3, R31.b1
	NOP
	MOV    R26.b0, R31.b0
	NOP
	MOV    R26.b1, R31.b1
	NOP
	MOV    R26.b2, R31.b0
	NOP
	MOV    R26.b3, R31.b1
	NOP
	MOV    R27.b0, R31.b0
	NOP
	MOV    R27.b1, R31.b1
	NOP
	MOV    R27.b2, R31.b0
	NOP
	MOV    R27.b3, R31.b1
	NOP
	MOV    R28.b0, R31.b0
	NOP
	MOV    R28.b1, R31.b1
	NOP
	MOV    R28.b2, R31.b0
	ADD    R29, R29, 32
	MOV    R28.b3, R31.b1
	XOUT   10, &R21, 36                     ; Move data across the broadside
	MOV    R21.b0, R31.b0
	LDI    R31, PRU1_PRU0_INTERRUPT + 16    ; Jab PRU0
	MOV    R21.b1, R31.b1
	JMP    $sample100m8$2


sample:
	WAITCLK
	MOV    R21.b0, R31.b0
	WAITCLK
	MOV    R21.b1, R31.b0
	WAITCLK
	MOV    R21.b2, R31.b0
	WAITCLK
	MOV    R21.b3, R31.b0
	WAITCLK
	MOV    R22.b0, R31.b0
	WAITCLK
	MOV    R22.b1, R31.b0
	WAITCLK
	MOV    R22.b2, R31.b0
	WAITCLK
	MOV    R22.b3, R31.b0
	WAITCLK
	MOV    R23.b0, R31.b0
	WAITCLK
	MOV    R23.b1, R31.b0
	WAITCLK
	MOV    R23.b2, R31.b0
	WAITCLK
	MOV    R23.b3, R31.b0
	WAITCLK
	MOV    R24.b0, R31.b0
	WAITCLK
	MOV    R24.b1, R31.b0
	WAITCLK
	MOV    R24.b2, R31.b0
	WAITCLK
	MOV    R24.b3, R31.b0
	WAITCLK
	MOV    R25.b0, R31.b0
	WAITCLK
	MOV    R25.b1, R31.b0
	WAITCLK
	MOV    R25.b2, R31.b0
	WAITCLK
	MOV    R25.b3, R31.b0
	WAITCLK
	MOV    R26.b0, R31.b0
	WAITCLK
	MOV    R26.b1, R31.b0
	WAITCLK
	MOV    R26.b2, R31.b0
	WAITCLK
	MOV    R26.b3, R31.b0
	WAITCLK
	MOV    R27.b0, R31.b0
	WAITCLK
	MOV    R27.b1, R31.b0
	WAITCLK
	MOV    R27.b2, R31.b0
	WAITCLK
	MOV    R27.b3, R31.b0
	WAITCLK
	MOV    R28.b0, R31.b0
	WAITCLK
	MOV    R28.b1, R31.b0
	WAITCLK
	MOV    R28.b2, R31.b0
	WAITCLK
	MOV    R28.b3, R31.b0

	ADD    R29, R29, 32                     ; Increment counter
	XOUT   10, &R21, 36                     ; Move data across the broadside
	LDI    R31, PRU1_PRU0_INTERRUPT + 16    ; Jab PRU0
	JMP    sample

sample_dual:
	WAITCLK
	MOV    R21.b0, R31.b1
	MOV    R21.b1, R31.b0
	WAITCLK
	MOV    R21.b2, R31.b1
	MOV    R21.b3, R31.b0
	WAITCLK
	MOV    R22.b0, R31.b1
	MOV    R22.b1, R31.b0
	WAITCLK
	MOV    R22.b2, R31.b1
	MOV    R22.b3, R31.b0
	WAITCLK
	MOV    R23.b0, R31.b1
	MOV    R23.b1, R31.b0
	WAITCLK
	MOV    R23.b2, R31.b1
	MOV    R23.b3, R31.b0
	WAITCLK
	MOV    R24.b0, R31.b1
	MOV    R24.b1, R31.b0
	WAITCLK
	MOV    R24.b2, R31.b1
	MOV    R24.b3, R31.b0
	WAITCLK
	MOV    R25.b0, R31.b1
	MOV    R25.b1, R31.b0
	WAITCLK
	MOV    R25.b2, R31.b1
	MOV    R25.b3, R31.b0
	WAITCLK
	MOV    R26.b0, R31.b1
	MOV    R26.b1, R31.b0
	WAITCLK
	MOV    R26.b2, R31.b1
	MOV    R26.b3, R31.b0
	WAITCLK
	MOV    R27.b0, R31.b1
	MOV    R27.b1, R31.b0
	WAITCLK
	MOV    R27.b2, R31.b1
	MOV    R27.b3, R31.b0
	WAITCLK
	MOV    R28.b0, R31.b1
	MOV    R28.b1, R31.b0
	WAITCLK
	MOV    R28.b2, R31.b1
	MOV    R28.b3, R31.b0

	ADD    R29, R29, 32                     ; Increment counter
	XOUT   10, &R21, 36                     ; Move data across the broadside
	LDI    R31, PRU1_PRU0_INTERRUPT + 16    ; Jab PRU0
	JMP    sample_dual
; End-of-firmware
	HALT
