
; os loader
;	sets up GDT and IDT
;	switches to pmode
;	reads in and launches kernel

%include "osloader.h"

	bits 16
	org 0x0


	segment .text
os_loader:
	mov		ax, 0xB800				; debug mechanism
	mov		gs, ax

	call	Cls

	mov		word [gs:0], 0x0430

;====== set up segment registers ======
	mov		ax, cs
	mov		ds, ax
	mov		es, ax

;====== enable A20 address line
	call	A20Enable

	mov		word [gs:2], 0x0431

;====== patch the GDT and GDT pseudo reg ======
	xor		eax, eax
	mov		ax, ds
	shl		eax, 4
	add		eax, gdt_start
	mov		[gdt_reg+2], eax		; GDT pseudo reg

	xor		eax, eax				; physical addrs of code16 and data16
	mov		ax, cs					; point at this segment in low mem (0x1000)
	shl		eax, 4
	mov		ecx, 0xFFFFF
	mov		ebx, code16
	call	DPatch
	mov		ebx, data16
	call	DPatch

	mov		word [gs:4], 0x0432

;====== load kernel (sector 5) and place it in low mem ======
	mov		si, 4
.read:
	xor		ax, ax					; reset drive
	mov		dl, 0x80				; both hd and fd
	int		0x13

	mov		ax, 0x210				; read kernel into mem
	mov		cx, 0x0005				; cylinder, sector
	xor		dx, dx					; head, drive
	mov		bx, 0x5000				; es:bx  destination buffer
	mov		es, bx
	xor		ebx, ebx
	int		0x13
	jnc		.kernel_read_ok
	dec		si
	jnz		.read
	jmp		halt
.kernel_read_ok:

	mov		word [gs:12], 0x0436

;====== switch to pmode ======
	cli
	lgdt	[gdt_reg]				; set up GDTR
	lidt	[idt_reg]				; and IDTR
	mov		eax, cr0
	inc		al						; cr0.PE
	mov		cr0, eax				; switch to pmode
	jmp		code16_idx:start32		; reload cs selector


;=====================================
; A20 enable
;=====================================
A20Enable:
	push	ds
	push	es
	xor		ax, ax
	mov		ds, ax
	dec		ax
	mov		es, ax
	
	call	A20Test
	jz		.done
	mov		al, 0xD1
	out		0x64, al
	mov		cx, 0x8000
	loop	$
	mov		al, 0xDF
	out		0x60, al
	mov		cx, 0x8000
	loop	$
	call	A20Test
	jnz		halt
.done:
	pop		es
	pop		ds
	ret

A20Test:
	mov		al, [ds:0]
	mov		ah, al
	dec		al
	xchg	[es:0x10], al
	cmp		ah, [ds:0]
	mov		[es:0x10], al
	ret


;=====================================
; Cls
;=====================================
Cls:
	xor		edi, edi
	xor		ax, ax
	mov		ecx, 0xA0*25
.clear:
	mov		[gs:edi], ax
	inc		edi
	inc		edi
	loop	.clear
	ret


;=====================================
; halt (real mode), reboot to recover
;=====================================
halt:
	mov		word [gs:18], 0x0439
.loop:
	jmp		.loop



	bits32
start32:
;====== reload all selectors ======
	mov		ax, data16_idx			; reload all segment registers
	mov		ds, ax
	mov		es, ax
	mov		fs, ax
	mov		ax, video_idx
	mov		gs, ax

	mov		ax, stack32_idx
	mov		ss, ax
	xor		esp, esp

	mov		word [gs:0x06], 0x0433
	push	eax

;====== detect amount of memory ======
	mov		eax, cr0				; save cr0 state
	push	eax
	or		eax, 0x40000000			; cr0.CD
	wbinvd							; invalidate cache
	mov		cr0, eax				; disacble cache

	mov		word [gs:0x08], 0x0434

	push	ds
	mov		ax, flat_idx
	mov		ds, ax

	mov		ebx, 0x110000			; start of extended mem
.check_mem:
	mov		eax, [ebx]				; read first dword of page
	xor		dword [ebx], -1			; change the memory dword
	xor		eax, -1					; change the read dword
	mov		ebp, [0]				; dummy read
	cmp		[ebx], eax				; if equal, memory is found
	jnz		.mem_done
	add		ebx, 0x1000				; check next page
	jmp		.check_mem
.mem_done:
	pop		ds
	mov		[mem_bytes], ebx		; save memory size in bytes and pages
	shr		ebx, 12
	mov		[mem_pages], ebx
	pop		eax						; restore cr0 state
	mov		cr0, eax

	mov		word [gs:0x0A], 0x0435

;====== copy kernel from low mem and place it at 0x110000 ======
	push	ds
	push	es

	mov		ax, flat_idx
	mov		ds, ax
	mov		esi, 0x50000

	mov		ax, data32_idx
	mov		es, ax
	xor		edi, edi

	mov		ecx, 0xFFFF
	cld
	rep		movsb

	pop		es
	pop		ds

	mov		ax, flat_idx
;	mov		ax, data32_idx
	mov		ss, ax
	mov		eax, 0x50014
;	mov		eax, 0x00020
	mov		esp, eax

	mov		ax, data32_idx
	mov		fs, ax
	mov		ebx, [fs:0x14]
	mov		ax, flat_idx
	mov		fs, ax
	mov		ecx, [fs:0x50014]

	call	CPUDump
	jmp		halt32

;====== transfer control to the kernel ======
	jmp		code32_idx:0			; jump to kernel
	

;======================================
; descriptor patch
;--------------------------------------
;  eax	base addr
;  ebx	ptr to descriptor
;  ecx	limit
;======================================
DPatch:
	push	eax
	push	ecx

	mov		word [ebx], cx			; segment limit
	shr		ecx, 0x10
	and		cl, 0x0F
	or		byte [ebx+6], cl
	
	mov		word [bx+2], ax			; segment base
	shr		eax, 0x10
	mov		byte [bx+4], al
	mov		byte [bx+7], ah

	pop		ecx
	pop		eax
	ret


;======================================
; CPUDump
;--------------------------------------
; ds	kernel data segment
; gs	video segment
;======================================
CPUDump:
	push	eax
	push	edx
	push	esi

	push	esi
	push	edx
	push	ecx

	mov		dx, 0x100					; row, column of dump
	mov		esi, cpu_state_msg
	call	PrintStr
	
	mov		cx, 8						; register size
	mov		esi, eax_reg
	call	RegDumpNL
	mov		esi, ebx_reg
	mov		eax, ebx
	call	RegDump
	mov		esi, ecx_reg
	pop		eax
	call	RegDump
	mov		esi, edx_reg
	pop		eax
	call	RegDump
	
	mov		esi, esi_reg
	pop		eax
	call	RegDumpNL
	mov		esi, edi_reg
	mov		eax, edi
	call	RegDump
	mov		esi, ebp_reg
	mov		eax, ebp
	call	RegDump
	mov		esi, esp_reg
	mov		eax, esp
	call	RegDump

	mov		cx, 4						; register size
	mov		esi, ds_reg
	xor		eax, eax
	mov		ax, ds
	call	RegDumpNL
	mov		esi, es_reg
	mov		ax, es
	call	RegDump
	mov		esi, fs_reg
	mov		ax, fs
	call	RegDump
	mov		esi, gs_reg
	mov		ax, gs
	call	RegDump

	mov		esi, cs_reg
	xor		eax, eax
	mov		ax, cs
	call	RegDumpNL
	mov		esi, ss_reg
	mov		ax, ss
	call	RegDump
;	mov		esi, eip_reg
;	call	.get_eip
;.get_eip:
;	pop		eax
;	call	RegDump
	
;	mov		esi, eflags_reg
;	pushf
;	pop		eax
;	call	RegDumpNL

	mov		cx, 8						; register size
	mov		esi, cr0_reg
	mov		eax, cr0
	call	RegDumpNL
	mov		esi, cr1_reg
	xor		eax, eax
	;mov		eax, cr1
	call	RegDump
	mov		esi, cr2_reg
	mov		eax, cr2
	call	RegDump
	mov		esi, cr3_reg
	mov		eax, cr3
	call	RegDump

	call	StackDump
	
	pop		esi
	pop		edx
	pop		eax
	ret

;=============================================
; RegDumpNL, RegDump, RegDumpNS
;---------------------------------------------
; RegDumpNL		new line
; RegDump		no new line
;	esi			first string
;	eax			value to dump
; RegDumpNS		no first string
;	eax			value to dump
;==============================================
RegDumpNL:
	inc		dh						; new line
	xor		dl, dl
RegDump:
	call	PrintStr
RegDumpNS:
	mov		esi, tmp1				; convert register to ascii
	call	Hex2Asc
	add		dx, 0x5					; advance row
	call	PrintStr				; print register
	add		dx, 14					; advance row
	ret


;===============================================
; StackDump
;===============================================
StackDump:
	mov		dx, 0x800
	mov		esi, stack_dump_msg
	call	PrintStr

	xor		edi, edi				; stack index
	mov		bh, 0x04				; 4 rows
.row:
	inc		dh						; next row
	xor		dl, dl
	mov		cx, 4					; register size
	mov		bl, cl					; 4 values per row
	xor		eax, eax				; get ss, convert to ascii, and print
	mov		ax, ss
	mov		esi, tmp1
	call	Hex2Asc
	call	PrintStr
	mov		dl, 0x04				; put colon after ss value
	mov		esi, colon_str
	call	PrintStr
	xor		dl, dl
	mov		cx, 8					; register size
	lea		eax, [esp+edi]			; dump esp register
	call	RegDumpNS

	mov		dl, 15					; start column of hex value dump
	mov		bp, 0x0035				; start column of ascii value dump
.value:
	mov		eax, [esp+edi]			; get stack val, convert to ascii and print
	mov		esi, tmp1
	call	Hex2Asc
	call	PrintStr
	add		edi, 4					; adjust stack index
	add		dl, 9					; adjust column value, for next dump

	push	dx
	push	cx
	mov		cx, 4
	xor		dl, dl
	add		dx, bp
.ascii:
	cmp		al, ' '
	ja		.above_asc
	mov		al, '.'
.above_asc:
	cmp		al, 'z'
	jbe		.below_asc
	mov		al, '.'
.below_asc:
	mov		[esi], al
	shr		eax, 8
	mov		byte [esi+1], 0
	call	PrintStr
	inc		dl
	loop	.ascii
	add		bp, 4
	pop		cx
	pop		dx
	
	dec		bl						; one more value done
	jnz		.value
	dec		bh						; one more row done
	jz		.exit
	jmp		.row
	
.exit:	
	ret

	
;======================================
; PrintStr
;--------------------------------------
; ds:esi	string
; dh, dl	row, column
;======================================
PrintStr:
	push	eax
	push	ecx
	push	edx
	push	esi
	push	edi
	push	ds
	push	es

	xor		edi, edi
	xor		cx, cx
	xchg	cl, dh
.rows:
	or		cx, cx
	jz		.columns
	add		edi, 0xA0
	dec		cx
	jmp		.rows
.columns:
	shl		dx, 1
	add		di, dx

	mov		ax, video_idx
	;mov		ax, 0xB800
	mov		es, ax
	mov		ah, 07
.loop:
	cld
	lodsb
	or		al, al
	jz		.done
	stosw
	jmp		.loop

.done:
	pop		es
	pop		ds
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	pop		eax
	ret


;======================================
; Hex2Asc
;--------------------------------------
; eax		value
; ds:esi	dest string
; cx		requested number of ascii chars (0 = dynamic)
;======================================
Hex2Asc:
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	ebp

	mov		ebx, 0x10				; number base of dest string
	xor		ebp, ebp				; stack character counter
	or		cx, cx					; requested number of ascii chars
	jz		.convert
	inc		cx
.convert:
	xor		edx, edx
	div		ebx
	
	or		cx, cx
	jz		.static_len
	dec		cx
.static_len:
	or		edx, edx
	jnz		.goon
	or		cx, cx
	jz		.store

.goon:
	cmp		dl, 9
	jbe		.dig
	add		dl, 7
.dig:
	add		dl, 0x30
	push	dx
	inc		ebp
	jmp		.convert

.store:
	or		ebp, ebp
	jz		.done
	pop		dx
	mov		[esi], dl
	inc		esi
	dec		ebp
	jmp		.store

.done:
	mov		byte [esi], 0

	pop		ebp
	pop		esi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	ret


;======================================
; halt (pmode), reboot to recover
;======================================
halt32:
	mov		word [gs:0x10], 0x0438

.loop:
	jmp		.loop
	

;**************************************
; Global Descriptor Table
;**************************************
;	gdt_reg			the null descriptor and the GDT pseudo reg
;	gdt_flat		kernel data seg for the 4Gb address space
;	gdt_alias		kernel access to the GDT itself
;	code32			kernel 32b code segment
;	data32			kernel 32b data segment
;	stack32			kernel 32b stack segment
;	code16			kernel 16b code segment
;	data16			kernel 16b data segment
;	idt_alias		kernel and user access to IDT
;	tss_alias		kernel tss descriptor access
;	tss				kernel tss descriptor
;**************************************

gdt_start:
gdt_reg:
dummy:		dw		gdt_size, 0, 0, 0			; GDTR *and* dummy descriptor
flat:		desc	0xFFFFF, 0x0, D_DATA32 + D_GRANP + D_WRITE + D_DPL0
gdt_alias:	desc	gdt_size*8, 0, D_DATA32 + D_WRITE + D_DPL0
code32:		desc	0xFFFFF, 0x110000, D_CODE32 + D_GRANP + D_READ + D_DPL0
data32:		desc	0xFFFFF, 0x110000, D_DATA32 + D_GRANP + D_WRITE + D_DPL0
stack32:	desc	0xFFFFF, 0x110000, D_DATA32 + D_GRANP + D_WRITE + D_DPL0
code16:		desc	0xFFFFF, 0x0000, D_CODE16 + D_GRANB + D_READ + D_DPL0
data16:		desc	0xFFFFF, 0x0000, D_DATA16 + D_GRANB + D_WRITE + D_DPL0
idt_alias:	desc	0xFFFFF, 0, D_DATA32 + D_WRITE + D_DPL0
tss_alias:	desc	0xFFFFF, 0, D_DATA32 + D_WRITE + D_DPL0
tss:		desc	0xFFFFF, 0, D_DATA32 + D_WRITE + D_DPL0
video:		desc	0xFFFFF, 0xB8000, D_DATA16 + D_WRITE + D_DPL0
test1:		desc	0xFFFFF, 0x110000, D_DATA32 + D_GRANP + D_WRITE + D_DPL0
gdt_end:

dummy_idx		equ	0x0
flat_idx		equ 0x8
gdt_alias_idx	equ	0x10
code32_idx		equ	0x18
data32_idx		equ	0x20
stack32_idx		equ	0x28
code16_idx		equ	0x30
data16_idx		equ	0x38
idt_alias_idx	equ	0x40
tss_alias_idx	equ	0x48
tss_idx			equ	0x50
video_idx		equ 0x58
test1_idx		equ 0x60

gdt_num_desc	equ	($ - gdt_start) / 8
;gdt_size		equ	gdt_start-gdt_end
gdt_size		equ 1024*8


idt_reg:		dw	idt_size, 0, 0
idt_start:
;int0:			desc 	0xFFFF, 0, D_INTGATE + D
idt_end:

idt_size		equ	0x0100*8

test_str:		db	'hahaha', 0





;****** kernel data *****************************************************
;====== dump screen strings ======
cpu_state_msg:	db	'--- CPU state --------------------------------------------------------------', 0
eax_reg:		db	'eax: ', 0
ebx_reg:		db	'ebx: ', 0
ecx_reg:		db	'ecx: ', 0
edx_reg:		db	'edx: ', 0
esi_reg:		db	'esi: ', 0
edi_reg:		db	'edi: ', 0
ebp_reg:		db	'ebp: ', 0
esp_reg:		db	'esp: ', 0
eip_reg:		db	'eip: ', 0
cs_reg:			db	'cs: ', 0
ds_reg:			db	'ds: ', 0
es_reg:			db	'es: ', 0
fs_reg:			db	'fs: ', 0
gs_reg:			db	'gs: ', 0
ss_reg:			db	'ss: ', 0
eflags_reg:		db	'eflags: ', 0
cr0_reg:		db	'cr0: ', 0
cr1_reg:		db	'cr1: ', 0
cr2_reg:		db	'cr2: ', 0
cr3_reg:		db	'cr3: ', 0

stack_dump_msg:	db	'--- stack dump -------------------------------------------------------------', 0

tmp1:			dd	0, 0, 0, 0 
tmp2:			dd	0, 0, 0, 0
colon_str:		db	':', 0
null			dd	0


mem_bytes:		dd	0
mem_pages:		dd	0
