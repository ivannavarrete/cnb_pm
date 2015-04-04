;
; 18 Jul 2000 (?)
;

;-----------------------------------------------------------------------------
; This program tests switch into pmode. Main purpose is to determine whether
; to move the CNB OS project into realization stage..
;
; The code is based on multiple pmode tutorials (pmcom [johnfine@erols.com],
; pmtut [tig@ngo.ol.ni.schule.de], ...)
;-----------------------------------------------------------------------------


%include "pmode.h"

%define code32_idx 0x08
%define data32_idx 0x10
%define core32_idx 0x18
%define code16_idx 0x20
%define data16_idx 0x28

	BITS 16
	org 0x0

	section .text
code16_start:
;-----------------------------------------
; copy us to initseg
;-----------------------------------------
	mov		ax, VIDEOSEG			; set up debug mechanism
	mov		gs, ax
	mov		ax, BOOTSEG
	mov		ds, ax
	mov		ax, INITSEG
	mov		es, ax
	mov		word [gs:0], STAGE0

	xor		si, si
	xor		di, di
	mov		cx, 0x100
	cld
	rep		movsw
	jmp		INITSEG:.go_on

;-----------------------------------------
; init stack
;-----------------------------------------
.go_on:
	mov		ds, ax
	cli
	mov		ss, ax
	mov		sp, 0xFFFF
	sti
	
	mov		word [gs:2], STAGE1
	call	CheckMode

;------------------------------------------
; set up gdt
;------------------------------------------
	mov		ax, cs
	movzx	eax, ax						; convert to doubleword
	shl		eax, 4
	mov		[code16_desc+2], ax
	mov		[data16_desc+2], ax
	mov		[code32_desc+2], ax
	mov		[data32_desc+2], ax
	mov		[core32_desc+2], ax
	
	shr		eax, 16
	mov		[code16_desc+4], al
	mov		[data16_desc+4], al
	mov		[code16_desc+7], ah
	mov		[data16_desc+7], ah
	
	mov		[code32_desc+4], al
	mov		[data32_desc+4], al
	mov		[core32_desc+4], al
	mov		[code32_desc+7], ah
	mov		[data32_desc+7], ah
	mov		[core32_desc+7], ah

	mov		ax, cs
	movzx	eax, ax
	shl		eax, 4
	add		eax, gdt_start				; prepare the gdt reg image for use
	mov		[gdt_reg+2], eax

;------------------------------------------
; load GDTR and switch to pmode
;------------------------------------------
	cli
	lgdt	[gdt_reg]					; load gdtr
	mov		eax, cr0
	inc		al

	mov		cr0, eax					; switch to pmode
	mov		word [gs:6], STAGE3
	jmp		code32_idx:code32_start		; reload segment register
	

;========================================
; Halt execution
;========================================
Halt:
	mov		word [gs:18], STAGE9
.loop:
	nop
	jmp		short .loop


Halt_PM:
	mov		word [gs:16], STAGE8
.loop:
	nop
	jmp		short .loop
	

;===============================================================================
; CheckMode
;   Check wheter we are in pmode already. If so, halt.
;===============================================================================
CheckMode:
	mov		eax, cr0
	and		al, 1
	jnz		.not_rm
	mov		word [gs:4], STAGE2
	ret
.not_rm:
	call	Halt


;==============================================
; DumpReg	-- val in ax
;==============================================
DumpReg:
	mov		bx, ax
	xor		di, di
.dump:
	rol		bx, 4
	mov		ax, bx
	and		ax, 0xF
	cmp		al, 9
	jbe		.num
	add		al, 7
.num:
	add		ax, 0x0430
	shl		di, 1
	mov		word [gs:di+160], ax
	shr		di, 1
	inc		di
	cmp		di, 4
	jnz		.dump

	ret


data32_start:
gdt_reg:			dw	gdt_end-gdt_start, 0, 0
	
gdt_start:
dummy_desc:			desc 0, 0, 0, 0
code32_desc:		desc 0x0FFFF, 0, 0x9A, 0xCF		; 4Gb 32-b code
data32_desc:		desc 0x0FFFF, 0, 0x92, 0xCF		; 4Gb 32-b data
core32_desc:		desc 0x0FFFF, 0, 0x92, 0xCF		; 4Gb 32-b core
code16_desc: 		desc 0x0FFFF, 0, 0x9A, 0x00		; 64k 16-b code
data16_desc:		desc 0x0FFFF, 0, 0x92, 0x00		; 64k 16-b data
gdt_end:



;	.text32
code32_start:
	mov		word [gs:32], STAGE8
.halt:
	nop
	jmp		.halt
