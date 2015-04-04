
%include "config.h"
%include "irq.h"
%include "descriptor.h"
%include "debug.h"


extern RequestGate


global RequestIRQ
global ReleaseIRQ
global EnableIRQ
global DisableIRQ



	BITS 32

	section .text
;===[ RequestIRQ ]==============================================================
; int RequestIRQ(int irqn, int sel, int offs, int type)
;===============================================================================
; The type must be D_TSGATE, D_IGATE32 or D_TRGATE32
;===============================================================================
RequestIRQ:
.irqn:			equ	0x08
.sel:			equ 0x0C
.offs:			equ	0x10
.dtype:			equ 0x14

	enter	0, 0
	push	esi, edi, es

	; allocate irq line
	mov		eax, -1
	mov		esi, [ebp+.irqn]
	cmp		esi, MAX_IRQ			; check if irq line is valid
	jae		.exit
	cmp		byte [irq_list+esi], 0	; check if irq line is available
	jne		.exit
	mov		byte [irq_list+esi], 1	; allocate irq line

	; set up IDT vector to point to handler
	mov		eax, [ebp+.irqn]
	add		eax, IRQ_BASE
	push	eax
	push	dword IDT
	push	dword [ebp+.dtype]
	push	dword [ebp+.offs]
	push	dword [ebp+.sel]
	call	RequestGate
	cmp		eax, -1
	je		.exit					; XXX need to dealloc irq line if error

	xor		eax, eax
.exit:
	pop		esi, edi, es
	leave
	ret		0x10


;===[ ReleaseIRQ ]==============================================================
; int ReleaseIRQ(int irqn)
;===============================================================================
;
;===============================================================================
ReleaseIRQ:
.irqn:			equ	0x08

	enter	0, 0
	push	ebx

	; free irq line
	mov		eax, -1
	mov		ebx, [ebp+.irqn]
	cmp		ebx, MAX_IRQ			; check if irq line is valid
	jae		.exit
	mov		byte [irq_list+ebx], 0	; free irq line

	xor		eax, eax
.exit:
	pop		ebx
	leave
	ret		4


;===[ EnableIRQ ]===============================================================
; int EnableIRQ(int irqn)
;===============================================================================
; Enable IRQ line in the PIC.
;===============================================================================
EnableIRQ:
.irqn:			equ 0x08

	enter	0, 0
	push	ecx

	; sanity check
	mov		eax, -1
	mov		ecx, [ebp+.irqn]
	cmp		ecx, MAX_IRQ
	jae		.exit

	; enable irq line
	mov		ax, 0xFFFE
	rol		al, cl
	cmp		cl, 7				; check which controller the line is attached to
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


;===[ DisableIRQ ]==============================================================
; int DisableIRQ(int irqn)
;===============================================================================
; Disable IRQ line in the PIC.
; <<< not implemented >>>
;===============================================================================
DisableIRQ:
.irqn:			equ 0x08

	enter	0, 0

	mov		eax, -1

	leave
	ret		4


	section .data
irq_list:	times MAX_IRQ db 0
