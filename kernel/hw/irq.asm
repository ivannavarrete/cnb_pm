
%include "descriptor.h"
%include "config.h"

%define irq_base 0x20
%define MAX_IRQ 0x10

global request_irq
global release_irq
global enable_irq
global disable_irq


;=== request_irq ===============================================================
; int request_irq(int irq, void (*handler)(void), const char *device)
;===============================================================================
request_irq:
.irq:			equ		0x08
.handler:		equ		0x0C
.device:		equ		0x10
	
	enter	0, 0
	push	esi, edi, ds, es

	mov		eax, -1
	mov		esi, [ebp+.irq]
	cmp		esi, MAX_IRQ			; invalid irq line
	ja		.exit
	cmp		byte [irq_list+esi], 1		; irq is not available
	ja		.exit
	mov		byte [irq_list+esi], 1		; allocate irq line
	
	; fix the gate
	mov		si, DATA32_SEL
	mov		ds, si
	mov		esi, int_gate
	mov		edi, [ebp+.handler]
	mov		[esi], di
	shr		edi, 16
	mov		[esi+6], di
	; insert new gate into IDT
	mov		di, IDT_SEL
	mov		es, di
	mov		edi, [ebp+.irq]
	add		edi, irq_base
	shl		edi, 3
	movsd
	movsd
	
	xor		eax, eax
.exit:
	pop		esi, edi, ds, es
	leave
	ret		0x0C


;=== release_irq ===============================================================
; int release_irq(int irq)
;===============================================================================
release_irq:
.irq:			equ		0x08
	
	enter	0, 0

	mov		eax, [ebp+.irq]			; free irq line
	mov		byte [irq_list+eax], 0
	
	mov		eax, -1
	leave
	ret		4


;=== enable_irq ================================================================
; int enable_irq(int irq)
;===============================================================================
enable_irq:
.irq:			equ		0x08

	enter	0, 0
	push	ecx
	
	mov		al, 0xFE
	mov		ecx, [ebp+.irq]
	rol		al, cl

	cmp		ecx, 7
	ja		.10
	out		0x21, al
	jmp		.exit
.10:
	out		0xA1, al

.exit:
	xor		eax, eax
	pop		ecx
	leave
	ret		4


;=== disable_irq ===============================================================
; int disable_irq(int irq)
;===============================================================================
disable_irq:
.irq:			equ		0x08

	enter	0, 0
	mov		eax, -1
	leave
	ret


	section .data
int_gate:	gate	CODE32_SEL, 0, 0, D_IGATE32 | D_DPL0
irq_list:	times MAX_IRQ db 0
