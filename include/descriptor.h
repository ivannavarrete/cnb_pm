
%ifndef DESCRIPTOR_H
%define DESCRIPTOR_H


%define D_GB		0000000000000000b		; granularity - bytes
%define D_GP		1000000000000000b		; granularity - pages

%define D_D16		0000000000000000b		; default - 16 bit code seg
%define D_D32		0100000000000000b		; default - 32 bit code seg
%define D_B16		0000000000000000b		; big - sp, stack top = 0xFFFF
%define D_B32		0100000000000000b		; big - esp, stack top = 0xFFFFFFFF

%define D_PY		0000000010000000b		; seg present - yes
%define D_PN		0000000000000000b		; seg present - no

%define D_DPL0		0000000000000000b		; DPL - 0
%define D_DPL1		0000000000100000b		; DPL - 1
%define D_DPL2		0000000001000000b		; DPL - 2
%define D_DPL3		0000000001100000b		; DPL - 3

%define D_SY		0000000000000000b		; sys seg - yes
%define D_SN		0000000000010000b		; sys seg - no

; segment type (non system segments)
%define D_ST_C		0000000000001000b		; seg type - code
%define D_ST_D		0000000000000000b		; seg type - data
%define D_ST_DED	0000000000000100b		; seg type - data expand down
%define D_ST_DEU	0000000000000000b		; seg type - data expand up
%define D_ST_DWY	0000000000000010b		; seg type - data read/write
%define D_ST_DWN	0000000000000000b		; seg type - data read only
%define D_ST_CCY	0000000000000100b		; seg type - code conforming
%define D_ST_CCN	0000000000000000b		; seg type - code non-conforming
%define D_ST_CRY	0000000000000010b		; seg type - code read/exec
%define D_ST_CRN	0000000000000000b		; seg type - code exec only
%define D_ST_AY		0000000000000001b		; seg type - accessed
%define D_ST_AN		0000000000000000b		; seg type - not accessed

; segment type (system segments) (LDT is undefined for 16-bit)
%define D_ST_16		0000000000000000b		; seg type - sys seg is 16 bit
%define D_ST_32		0000000000001000b		; seg type - sys seg is 32 bit
%define D_ST_ATSS	0000000000000001b		; seg type - available TSS
%define D_ST_LDT	0000000000000010b		; seg type - LDT
%define D_ST_BTSS	0000000000000011b		; seg type - busy TSS
%define D_ST_CG		0000000000000100b		; seg type - call gate
%define D_ST_TSG	0000000000000101b		; seg type - task gate
%define D_ST_IG		0000000000000110b		; seg type - interrupt gate
%define D_ST_TRG	0000000000000111b		; seg type - trap gate

; some default half-build descriptor flags (for easier descriptor building)
%define D_CODE16	D_D16 | D_PY | D_SN | D_ST_C
%define D_CODE32	D_D32 | D_PY | D_SN | D_ST_C
%define D_DATA16	D_B16 | D_PY | D_SN | D_ST_D
%define D_DATA32	D_B32 | D_PY | D_SN | D_ST_D

%define D_IGATE16	D_PY | D_SY | D_ST_16 | D_ST_IG
%define D_IGATE32	D_PY | D_SY | D_ST_32 | D_ST_IG
%define D_TRGATE16	D_PY | D_SY | D_ST_16 | D_ST_TRG
%define D_TRGATE32	D_PY | D_SY | D_ST_32 | D_ST_TRG


; Macro for easy definition of descriptors.
; (%1)		segment base (32-bit)
; (%2)		segment limit (20-bit)
; (%3)		segment attributes (16-bit, packed to 12-bit in desc)
%macro desc 3
	dw	(%2) & 0xFFFF								; limit 15:0
	dw	(%1) & 0xFFFF								; base 15:0
	db	((%1)>>16) & 0xFF							; base 16:23
	db	(%3) & 0xFF									; attr 7:0
	db	(((%2)>>16) & 0x0F) | (((%3)>>8) & 0xFF)	; attr 11:8, limit 19:16
	db	(%1)>>24									; base 31:24
%endmacro


; Macro for easy definition of Interrupt/Trap/Task gates.
; (%1)		segment selector (16-bit)
; (%2)		offset (32-bit)
; (%3)		flags
%macro gate 3
	dw	(%2) & 0xFFFF
	dw	(%1)
	db	0
	db	(%3) & 0xFF
	dw	(%2)>>16
%endmacro


%endif
