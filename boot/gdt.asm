
; This code sets up a minimal GDT. The six first descriptors are valid and
; should not be shanged hereafter. More descriptors are allocated as needed
; later, through the memory manager or whatever.

%include "descriptor.h"


	BITS 16

	section .text

;=== InitGDT ===================================================================
InitGDT:
	; copy GDT to final position (0x00000800 right after the IDT)
	mov		di, GDT_ADDR>>4
	mov		es, di
	xor		di, di
	mov		si, gdt_start
	mov		cx, gdt_size/4
	rep		movsd

	; then load the GDTR
	lgdt	[gdtr]

	ret


	BITS 32
;=== Global Descriptor Table ===
; gdt_desc segment overlaps into system! change limit to SYS_ADDR-GDT_ADDR
gdt_start:
gdtr:		dw 0xFFFF, GDT_ADDR, GDT_ADDR>>16, 0		; GDTR and dummy desc
idt_desc:	desc IDT_ADDR, 0x7FF, D_DATA32 |D_GB |D_DPL0 |D_ST_DEU |D_ST_DWY
gdt_desc:	desc GDT_ADDR, 0xFFFF, D_DATA32 |D_GB |D_DPL0 |D_ST_DEU |D_ST_DWY
code32:		desc SYS_ADDR, 0xFFFFF, D_CODE32 |D_GP |D_DPL0 |D_ST_CCN |D_ST_CRY
data32:		desc SYS_ADDR, 0xFFFFF, D_DATA32 |D_GP |D_DPL0 |D_ST_DEU |D_ST_DWY
video:		desc VIDEO_ADDR, 0x7FFF, D_DATA16 |D_GB |D_DPL0 |D_ST_DEU |D_ST_DWY
setup:		desc SETUP_ADDR, 0xFFFFF, D_CODE32 |D_GP |D_DPL0 |D_ST_CCN |D_ST_CRY
gdt_end:

gdt_size	equ gdt_end-gdt_start
