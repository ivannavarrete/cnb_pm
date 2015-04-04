
%include "config.h"
%include "debug.h"


extern ConsoleWrite
global Printk
global PrintB
global PrintW
global PrintD


	section .text
;=== Printk ====================================================================
; int Printk(const char *str)
;===============================================================================
; This should be a printf equivalent and not just a ConsoleWrite wrapper
Printk:
.str			equ	0x08
	
	enter	0, 0
	push	esi, edi, es

	push	dword [ebp+.str]
	call	ConsoleWrite

	xor		eax, eax
	pop		esi, edi, es
	leave
	ret		4


;=== Hex2Asc ===================================================================
Hex2Asc:
	push	eax
	
	mov		ah, al
	shr		al, 4
	and		ah, 0x0F
	add		ax, 0x3030

	cmp		al, '9'
	jbe		.10
	add		al, 7
.10:
	mov		[ebx], al

	cmp		ah, '9'
	jbe		.20
	add		ah, 7
.20:
	mov		[ebx+1], ah

	pop		eax
	ret


;=== PrintB ====================================================================
PrintB:
	push	eax, ebx

	mov		ebx, buf
	mov		word [ebx], 0
	call	Hex2Asc
	mov		byte [ebx+3], 0

	push	dword buf
	call	Printk

	pop		eax, ebx
	ret


;=== PrintW ====================================================================
PrintW:
	ror		ax, 8
	call	PrintB
	ror		ax, 8
	call	PrintB
	
	ret


;=== PrintD ====================================================================
PrintD:
	ror		eax, 16
	call	PrintW
	ror		eax, 16
	call	PrintW

	ret


	section .data
buf:			times 9 db 0
