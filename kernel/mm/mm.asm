
; Memory Manager. Not yet implemented.


%include "config.h"
%include "debug.h"


extern Printk
global InitMM


	BITS 32

	section .text
;=== InitMM ====================================================================
; Not implemented.
;===============================================================================
InitMM:
	push	dword init_mm_str
	call	Printk

	ret


	section .data
init_mm_str:		db	'Memory Manager Initialized', 0x0A, 0
