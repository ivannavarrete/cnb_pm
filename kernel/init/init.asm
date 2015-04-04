
; This code is executed right after the system loader. It is responsible for
; initialization of the different subsystems of the kernel.

%include "config.h"
%include "descriptor.h"
%include "debug.h"


extern InitConsole
extern InitIDT
extern InitMM
extern InitSched

global kernel_init
global Idle
global Halt


	BITS 32

	section .text
kernel_init:

	push	dword 7
	push	dword 0
	call	InitConsole
	DEBUG	VIDEO_SEL, 4, 4, DATA32_SEL

	call	InitIDT
	DEBUG	VIDEO_SEL, 5, 5, DATA32_SEL

	;call	InitMM
	;DEBUG	VIDEO_SEL, 6, 6, DATA32_SEL

	call	InitSched
	DEBUG	VIDEO_SEL, 7, 7, DATA32_SEL

	; clear debug registers (not really necessary)
	xor		eax, eax
	mov		dr0, eax
	mov		dr1, eax
	mov		dr2, eax
	mov		dr3, eax					; dr4 and dr5 are reserved
	mov		dr6, eax
	mov		dr7, eax

	mov		ebx, 0x0002
	mov		ecx, 0x0003
	mov		edx, 0x0004
	mov		esi, 0x0005
	mov		edi, 0x0006
	mov		ebp, 0x0007

	call	Idle


;===[ Idle ]====================================================================
	section .data
tmp:		dd	0
	section .text
Idle:
	DEBUG	VIDEO_SEL, 8, 8, DATA32_SEL

.loop:
	inc		dword [tmp]
	cmp		dword [tmp], 10000000
	ja		.10
	DEBUG	VIDEO_SEL, 61, 0, DATA32_SEL
	jmp		.loop
.10:
	cmp		dword [tmp], 20000000
	ja		.20
	DEBUG	VIDEO_SEL, 61, 1, DATA32_SEL
	jmp		.loop
.20:
	mov		dword [tmp], 0
	jmp		.loop
	

;===[ Halt ]====================================================================
Halt:
	jmp		$
