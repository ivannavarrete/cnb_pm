
; This module handles IRQ resources. It is currently not possible to handle
; linked handlers, (several handlers for the same IRQ line).


%include "config.h"
%include "descriptor.h"
%include "debug.h"


global RequestIRQ
global ReleaseIRQ
global EnableIRQ
global DisableIRQ


;=== RequestIRQ ================================================================
; int RequestIRQ(int irq, void (*handler)(void), const char *device)
;===============================================================================
; Set handler to be the new service routine for the particular irq.
;===============================================================================
RequestIRQ:
.irq:		equ		0x08
.handler:	equ		0x0C
.device:	equ		0x10

	enter	0, 0
	push	esi, edi, ds, es

	; allocate irq line
	mov		eax, -1
	mov		esi, [ebp+.irq]
	cmp		esi, MAX_IRQ			; check if irq line is valid
	jae		.exit
	cmp		byte [irq_list+esi], 0	; check if irq line is available
	jne		.exit
	mov		byte [irq_list+esi], 1	; allocate irq line

	; fix the gate (insert handler offset)
	mov		si, DATA32_SEL
	mov		ds, si
	mov		esi, int_gate
	mov		edi, [ebp+.handler]
	mov		[esi], di
	shr		edi, 16
	mov		[esi+6], di

	; insert gate into IDT
	mov		di, IDT_SEL
	mov		es, di
	mov		edi, [ebp+.irq]
	add		edi, IRQ_BASE
	shl		edi, 3
	movsd
	movsd

	xor		eax, eax
.exit:
	pop		esi, edi, ds, es
	leave
	ret		0x0C
	

;=== ReleaseIRQ ================================================================
; int ReleaseIRQ(int irq)
;===============================================================================
ReleaseIRQ:
.irq:		equ		0x08

	enter	0, 0
	push	ebx

	; free irq line
	mov		eax, -1
	mov		ebx, [ebp+.irq]
	cmp		ebx, MAX_IRQ			; check if irq line is valid
	jae		.exit
	mov		byte [irq_list+ebx], 0

	xor		eax, eax
.exit:
	pop		ebx
	leave
	ret		4


;=== EnableIRQ =================================================================
; int EnableIRQ(int irq)
;===============================================================================
; Enable IRQ line in the PIC (Programmable Interrupt Controller).
;===============================================================================
EnableIRQ:
.irq:		equ		0x08

	enter	0, 0
	push	ecx

	; sanity check
	mov		eax, -1
	mov		ecx, [ebp+.irq]
	cmp		ecx, MAX_IRQ
	jae		.exit
	
	; enable irq line
	mov		al, 0xFE
	rol		al, cl
	cmp		cl, 7			; check which controller the line is attached to
	ja		.10
	out		0x21, al
	jmp		.20
.10:
	out		0xA1, al

.20:
	xor		eax, eax
.exit:
	pop		ecx
	leave
	ret		4

	
;=== DisableIRQ ================================================================
; int DisableIRQ(int)
;===============================================================================
; Disable IRQ line in the PIC (Programmable Interrupt Controller).
; <<< not implemented >>>
;===============================================================================
DisableIRQ:
.irq:		equ		0x08

	enter	0, 0

	mov		eax, -1

	leave
	ret		4



	section .data
trap_gate:	gate	CODE32_SEL, 0, D_TRGATE32 | D_DPL0
int_gate:	gate	CODE32_SEL, 0, D_IGATE32 | D_DPL3
irq_list:	times MAX_IRQ db 0

