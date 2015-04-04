
%include "config.h"
%include "descriptor.h"
%include "debug.h"


extern InitIDT
extern InitMM
extern InitSched

extern InitConsole			; Bad! Should be a driver
extern GotoXY				; ==="===

global kernel_init
global Halt


	BITS 32

	section .text
kernel_init:
	push	dword 7
	push	dword 0
	call	InitConsole
	push	dword 3
	push	dword 0
	call	GotoXY
	
	call	InitIDT

	mov		eax, dbg_test
	add		eax, SYS_ADDR
	mov		dr0, eax
	mov		eax, 0x00050001
	mov		dr7, eax

	mov		al, [dbg_test]
	mov		[dbg_test], al

;	call	InitMM
;	call	InitSched

	call	Idle


;=== idle ======================================================================
Idle:
	jmp		$


;=== halt ======================================================================
Halt:
	jmp		$


	section .data
dbg_test:		dd	0
