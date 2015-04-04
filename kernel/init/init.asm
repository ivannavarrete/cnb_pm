
; This code is executed right after the system loader. It is responsible for
; initialization of the different subsystems of the kernel.

%include "config.h"
%include "debug.h"


extern InitConsole
extern GotoXY
extern InitIDT
extern InitMM
extern InitSched

global kernel_init
global Halt


	BITS 32

	section .text
kernel_init:
	push	dword 7
	push	dword 0
	call	InitConsole
	DEBUG	VIDEO_SEL, 4, 4

	call	InitIDT
	DEBUG	VIDEO_SEL, 5, 5

	call	InitMM
	DEBUG	VIDEO_SEL, 6, 6
	
	call	InitSched
	DEBUG	VIDEO_SEL, 7, 7

	call	Idle


;=== Idle ======================================================================
Idle:
	DEBUG	VIDEO_SEL, 8, 8
	DEBUG	VIDEO_SEL, 60, 1
	jmp		Idle


;=== Halt ======================================================================
Halt:
	jmp		$
