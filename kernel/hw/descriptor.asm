
; All access to the GDT, IDT and LDT should be through this file. The idt.asm
; is an exception since we build a default IDT at compile time and then have to
; correct the addresses at runtime in the InitIDT function.


%include "config.h"
%include "descriptor.h"


global RequestDesc:function
global RequestGate:function


	BITS 32

	section .text
;===[ RequestDesc ]=============================================================
; int RequestDesc(int addr, int size, int type, int table, int tidx)
;===============================================================================
; type:		granularity, default/big (c/d), system, 16b (tss)
;
; The return value is the index in the table where the descriptor was placed.
;
; XXX: We should have a search mechanism to scan the table for a free entry,
; instead of lettint the caller supply the index.
; NOTE: we don't support LDT yet
;===============================================================================
RequestDesc:
.addr:			equ 0x08
.size:			equ 0x0C
.type:			equ 0x10
.table:			equ 0x14
.tidx:			equ 0x18

	enter	0, 0
	push	esi, edi, es

	; clear descriptor
	mov		esi, tmp_desc
	mov		dword [esi], 0
	mov		dword [esi+4], 0

	; set addr
	mov		eax, [ebp+.addr]
	mov		[esi+2], ax
	shr		eax, 16
	mov		[esi+4], al
	mov		[esi+7], ah

	; set size
	mov		eax, [ebp+.size]
	mov		[esi], ax
	shr		eax, 16
	and		ax, 0x0F
	or		[esi+6], al			; could use mov since we know descr is cleared

	; set type and flags
	mov		eax, [ebp+.type]
	or		eax, 0x0080			; set present bit
	mov		[esi+5], ax

	; copy descriptor into table
	mov		di, GDT_SEL
	mov		es, di
	cmp		dword [ebp+.table], GDT
	je		.copy
	mov		di, IDT_SEL
	mov		es, di
	cmp		dword [ebp+.table], IDT
	je		.copy
	mov		eax, -1
	jmp		.exit
	
.copy
	mov		edi, [ebp+.tidx]
	shl		edi, 3
	movsd
	movsd

	mov		eax, [ebp+.tidx]
.exit:
	pop		esi, edi, es
	leave
	ret		0x14


;===[ RequestGate ]=============================================================
; int RequestGate(int sel, int offs, int type, int table, int tidx)
;===============================================================================
;
;===============================================================================
RequestGate:
.sel:			equ 0x08
.offs:			equ 0x0C
.type:			equ 0x10
.table:			equ 0x14
.tidx:			equ 0x18

	enter	0, 0
	push	esi, edi, es

	; clear gate descriptor
	mov		esi, tmp_gate
	mov		dword [esi], 0
	mov		dword [esi+4], 0

	; set selector
	mov		eax, [ebp+.sel]
	mov		[esi+2], ax

	; set offset
	mov		eax, [ebp+.offs]
	mov		[esi], ax
	shr		eax, 16
	mov		[esi+6], ax
	
	; set type and flags
	mov		eax, [ebp+.type]
	or		eax, 0x0080			; set present bit
	mov		[esi+5], ax

	; copy gate into table
	mov		di, GDT_SEL
	mov		es, di
	cmp		dword [ebp+.table], GDT
	je		.copy
	mov		di, IDT_SEL
	mov		es, di
	cmp		dword [ebp+.table], IDT
	je		.copy
	mov		eax, -1
	jmp		.exit

.copy:
	mov		edi, [ebp+.tidx]
	shl		edi, 3
	movsd
	movsd

	mov		eax, [ebp+.tidx]
.exit:
	pop		esi, edi, es
	leave
	ret		0x14



;===[ ReleaseDescrGate ]========================================================
; void ReleaseDescrGate(int table, int tidx)
;===============================================================================
;
;===============================================================================
ReleaseDescrGate:
.table:			equ 0x08
.tidx:			equ 0x0C

	enter	0, 0

	leave
	ret		0x08

	section .data
tmp_desc:		desc 0, 0, 0
tmp_gate:		gate 0, 0, 0

