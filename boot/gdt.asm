
; This code sets up a minimal GDT. The seven first descriptors are valid and
; should not be changed hereafter. More descriptors are allocated as needed
; later, through the memory manager or whatever.


%include "descriptor.h"


	BITS 16

	section .text

;===[ InitGDT ]=================================================================
InitGDT:
	; zero the GDT
	mov		di, GDT_ADDR>>4
	mov		es, di
	;xor		di, di
	;mov		cx, GDT_LIMIT/4
	;xor		eax, eax
	;rep		stosd

	; copy GDT to final position (GDT_ADDR = 0x00000800, right after the IDT)
	xor		di, di
	mov		si, gdt_start
	mov		cx, gdt_size/4
	rep		movsd

	; then load the GDTR
	lgdt	[gdtr]

	ret


	BITS 32
;===[ Global Descriptor Table ]===
; We sacrifice 256 GDT entries to make the system start at a nice addr.
; Basically the IDT and GDT are in the same 0xFFFF memory position, with
; the IDT at 0x0000 and the GDT at 0x0800. (SYS_ADDR-GDT_ADDR = 0xF7FF).

;gdt_start:
;gdtr:		dw 0xFFFF, GDT_ADDR, GDT_ADDR>>16, 0		; GDTR and dummy desc
;idt_desc:	desc IDT_ADDR, 0x7FF, D_DATA32 |D_GB |D_DPL0 |D_ST_DEU |D_ST_DWY
;gdt_desc:	desc GDT_ADDR, 0xFFFF, D_DATA32 |D_GB |D_DPL0 |D_ST_DEU |D_ST_DWY
;code32:		desc SYS_ADDR, 0xFFFFF, D_CODE32 |D_GP |D_DPL0 |D_ST_CCN |D_ST_CRY
;data32:		desc SYS_ADDR, 0xFFFFF, D_DATA32 |D_GP |D_DPL0 |D_ST_DEU |D_ST_DWY
;video:		desc VIDEO_ADDR, 0x7FFF, D_DATA16 |D_GB |D_DPL0 |D_ST_DEU |D_ST_DWY
;setup:		desc SETUP_ADDR, 0xFFFFF, D_CODE32 |D_GP |D_DPL0 |D_ST_CCN |D_ST_CRY
;gdt_end:

gdt_start:
gdtr:		dw GDT_LIMIT, GDT_ADDR, GDT_ADDR>>16, 0		; GDTR and dummy desc
idt_desc:	desc IDT_ADDR, IDT_LIMIT,\
				 D_DATA32 |D_GB |D_DPL0 |D_ST_DEU |D_ST_DWY
gdt_desc:	desc GDT_ADDR, GDT_LIMIT,\
				 D_DATA32 |D_GB |D_DPL0 |D_ST_DEU |D_ST_DWY
code32:		desc SYS_ADDR, SYS_LIMIT,\
				 D_CODE32 |D_GP |D_DPL0 |D_ST_CCN |D_ST_CRY
data32:		desc SYS_ADDR, SYS_LIMIT,\
				 D_DATA32 |D_GP |D_DPL0 |D_ST_DEU |D_ST_DWY
video:		desc VIDEO_ADDR, VIDEO_LIMIT,\
				 D_DATA16 |D_GB |D_DPL0 |D_ST_DEU |D_ST_DWY
setup:		desc SETUP_ADDR, SETUP_LIMIT,\
				 D_CODE32 |D_GP |D_DPL0 |D_ST_CCN |D_ST_CRY
gdt_end:

gdt_size	equ	gdt_end-gdt_start
