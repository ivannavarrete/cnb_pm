; This code loads the system at SYSSEG:0 (0100:0000). Thereafter it enters
; protected mode and passes control to the system code.

%include "config.h"
%include "descriptor.h"
%include "debug.h"

	org	0x0

	section .text
start:
; prepare entry to pmode
	mov		ax, cs
	mov		ds, ax
	mov		es, ax

	call	Cls
	DEBUG	VIDEOSEG, 0, 0 

	call	LoadSys
	DEBUG	VIDEOSEG, 1, 1
	
	call	A20Enable
	DEBUG	VIDEOSEG, 2, 2

	call	SetGDT
	DEBUG	VIDEOSEG, 3, 3

	call	SetIDT
	DEBUG	VIDEOSEG, 4, 4

; enter protected mode
	mov		eax, cr0
	inc		ax					; turn on PE bit
	mov		cr0, eax
	
; reload segment registers and pass control to system code
	mov		ax, data32-gdt_start
	mov		ds, ax
	mov		es, ax
	mov		fs, ax
	mov		gs, ax
	mov		ss, ax
	mov		sp, 0xFFFF
	
	DEBUG	video-gdt_start, 5, 5
	;int		0x33
	;DEBUG	video-gdt_start, 9, 9
	;jmp		Halt

	jmp		code32-gdt_start:0x40


;=== LoadSys ======
; move system to final position SYSSEG:0 (0x00010800)
LoadSys:
	mov		si, 4				; retry count
.sysread:
	xor		ax, ax				; reset disc controller
	mov		dl, 0x80			; both hd and fd
	int		0x13
	
	mov		ax, 0x0204			; read sectors
	mov		cx, 0x0009			; cylinder, sector
	xor		dx, dx				; head, drive
	mov		bx, SYSSEG			; dest is es:bx
	mov		es, bx
	xor		bx, bx
	int		0x13
	jnc		.sysread_ok
	dec		si
	jnz		.sysread
	jmp		Halt
.sysread_ok:
	ret


;=== A20Enable ========
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
	je		.done
	jmp		Halt
.done:
	pop		es
	pop		ds
	ret

A20Test:
	mov		al, [ds:0]			; get first byte
	mov		ah, al
	xor		al, 0xFF			; invert it
	xchg	[es:0x10], al		; store at end of addr space: use A20
	cmp		ah, [ds:0]			; 
	mov		[es:0x10], al
	ret


;=== SetGDT ===
SetGDT:
	mov		ax, cs
	mov		ds, ax
	xor		eax, eax			; patch GTDR entry (descriptor 0)
	mov		ax, GDTSEG
	shl		eax, 4
	mov		[gdt_reg+2], eax

	mov		si, gdt_start		; copy GDT to GDTSEG:0 (0000:0000)
	mov		ax, GDTSEG
	mov		es, ax
	xor		di, di
	mov		cx, gdt_size/4
	rep		movsd
	
	lgdt	[gdt_reg]			; set GDTR
	ret


;=== SetIDT ===
SetIDT:
	cli
	mov		ax, cs
	mov		ds, ax
	
;	mov		ebx, def_int		; patch interrupt gates in IDT to use def_int
	mov		ebx, 0x0100

	mov		cx, 255
	mov		di, idt_start
.patch_idt:
	mov		eax, ebx
	mov		word [di], ax
	shr		eax, 16
	mov		word [di+6], ax
	add		di, 8
	loop	.patch_idt

	mov		si, idt_start
	mov		ax, IDTSEG
	mov		es, ax
	xor		di, di
	mov		cx, 0x0200
	rep		movsd
	
	lidt	[idt_reg]
	ret

;=== Halt ==========================
; halt processor; reboot to recover
Halt:
	jmp		$


;=== Cls ===========================
; clear screen
Cls:
	push	es
	mov		ax, 0xB800
	mov		es, ax
	xor		di, di
	xor		ax, ax
	mov		cx, 80*25
	rep		stosw
	pop		es
	ret


	;=== debug start ===
; ax=val, si=pos
DumpHex:
	push	ax
	push	bx
	push	cx
	push	dx
	
	mov		dx, ax
	mov		cx, 12
.dump	
	mov		ax, dx
	shr		ax, cl
	and		ax, 0x000F
	cmp		ax, 9
	jbe		.ok
	add		ax, 7
.ok:
	inc		si
	mov		bx, ax
	DEBUG	gs, si, bx
	
	sub		cx, 4
	jae		.dump

	pop		dx
	pop		cx
	pop		bx
	pop		ax
	ret

; fs:di=desc, si=dest
DumpDesc:
	push	ax
	push	si

	mov		ax, [fs:di+6]
	call	DumpHex
	mov		ax, [fs:di+4]
	add		si, 2
	call	DumpHex
	mov		ax, [fs:di+2]
	add		si, 2
	call	DumpHex
	mov		ax, [fs:di]
	add		si, 2
	call	DumpHex
	
	pop		si
	pop		ax
	ret

;=== DumpGDT ===
; gs = video seg/selector
; fs:di = gdt seg:off
DumpGDT:
	push	cx
	push	si
	push	di

	mov		cx, gdt_size/8
	mov		si, 80
.dump
	call	DumpDesc
	add		di, 8
	add		si, 80
	loop	.dump

	pop		di
	pop		si
	pop		cx
	ret
	;=== debug end ===


; Default Interrupt Service Routine
def_int:
	DEBUG	video-gdt_start, 70, 0 
	jmp		$
	iret


;=== Global Descriptor Table ===
gdt_start:
gdt_reg:	dw		gdt_size, 0, 0, 0 		; GDTR and dummy desc
code32:		desc	0xFFFFF, SYSSEG*16, D_CODE|D_OP32|D_CREAD|D_GRANB|D_DPL0
data32:		desc	0xFFFFF, SYSSEG*16, D_DATA|D_OP32|D_DWRITE|D_GRANB|D_DPL0
flat32		desc	0xFFFFF, 0, D_DATA|D_OP32|D_GRANP|D_DWRITE|D_DPL0
video:		desc	0xFFFFF, VIDEOSEG*16, D_DATA|D_OP16|D_DWRITE|D_GRANB|D_DPL0
gdt_seg		desc	0x10000, GDTSEG*16, D_DATA|D_OP16|D_DWRITE|D_GRANB|D_DPL0
idt_seg		desc	0x00800, IDTSEG*16, D_DATA|D_OP16|D_DWRITE|D_GRANB|D_DPL0
gdt_end:

gdt_size 	equ		gdt_end-gdt_start


;=== Interrupt Descriptor Table ===
idt_reg: 	dw		idt_size,
			dd		IDTSEG*16

idt_start:
%rep 256
			gate	code32-gdt_start, 0, D_INT32
%endrep
idt_end:

idt_size	equ		idt_end-idt_start
