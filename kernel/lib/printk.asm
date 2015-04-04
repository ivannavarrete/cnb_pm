
; Basic console output. All output to console in the kernel should be through
; this module (except for the console driver of course). PrintB/W/D() are here
; until correct formatting conversion is implemented in Printk().


extern ConsoleWrite
global Printk
global PrintB
global PrintW
global PrintD


	section .text
;=== Printk ====================================================================
; int Printk(const char *str)
;===============================================================================
; This should be a printf() equivalent and not just a ConsoleWrite() wrapper.
;===============================================================================
Printk:
.str:			equ 0x08

	enter	0, 0

	push	dword [ebp+.str]
	call	ConsoleWrite

	xor		eax, eax
	leave
	ret		4


;=== PrintB ====================================================================
;
;===============================================================================
PrintB:

	ret


;=== PrintW ====================================================================
;
;===============================================================================
PrintW:

	ret


;=== PrintD ====================================================================
;
;===============================================================================
PrintD:

	ret
