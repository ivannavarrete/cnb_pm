
%include "config.h"


global	request_desc
global	release_desc


	section .text
;=== request_desc ==============================================================
; int request_desc(int table, int idx, int type, int bs, int so, int flags)
;
;	table:		0=GDT, 1=LDT, 2=IDT
;	type:		0=desc, 1=gate
;	bs:			if type=desc then bs=base elseif type=gate then bs=selector
;	so:			if type=desc then so=size elseif type=gate then so=offset
;===============================================================================
request_desc:
.table:		equ		0x08
.idx:		equ		0x0C
.type:		equ		0x10
.bs:		equ		0x14
.so:		equ		0x18
.flags:		equ		0x1C

	enter	0, 0
	push	esi, edi, es

	; determine type of descriptor to build
	cmp		dword [ebp+.type], 0
	jmp		.desc
	cmp		dword [ebp+.type], 1
	jmp		.gate
	mov		eax, -1
	jmp		.exit

	; build normal descriptor
.desc:
	mov		eax, [ebp+.bs]
	mov		[desc+2], ax
	shr		eax, 16
	mov		[desc+4], al
	mov		[desc+7], ah

	mov		eax, [ebp+.so]
	mov		[desc], ax
	shr		eax, 8
	and		eax, 0x0F00
	mov		esi, [ebp+.flags]
	and		esi, 0xF0FF
	or		eax, esi
	mov		[desc+5], ax
	jmp		.inject

	; build gate descriptor
.gate:
	mov		eax, [ebp+.bs]
	mov		[desc+2], ax
	
	mov		eax, [ebp+.so]
	mov		[desc], ax
	shr		eax, 16
	mov		[desc+6], ax

	mov		eax, [ebp+.flags]
	mov		[desc+4], ax

.inject:
	cmp		dword [ebp+.table], 0
	je		.gdt
	cmp		dword [ebp+.table], 1
	je		.ldt
	cmp		dword [ebp+.table], 2
	je		.idt
	mov		eax, -1
	jmp		.exit
.gdt:
	mov		di, GDT_SEL
	jmp		.doit
.ldt:
	mov		eax, -1				; LDT not implemented
	jmp		.exit
.idt:
	mov		di, IDT_SEL
.doit:
	mov		es, di
	mov		edi, [ebp+.idx]
	shl		edi, 3
	mov		esi, desc
	movsd
	movsd

	xor		eax, eax
.exit:
	pop		esi, edi, es
	leave
	ret		0x18


;=== release_desc ==============================================================
; int release_desc(int table, int idx)
;===============================================================================
release_desc:
.table:		equ		0x08
.idx:		equ		0x0C

	enter	0, 0

	mov		eax, -1

	leave
	ret		0x8


	section .data
desc:		dd		0, 0
