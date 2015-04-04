
; The setup code loads the kernel into memory, enables A20, reprograms the PIC,
; sets up a minimal GDT and a default IDT, switches to pmode, and jumps to
; kernel init code. The code must not exceed 15 sectors (7680b).


%include "config.h"
%include "descriptor.h"
%include "sysdef.h"
%include "debug.h"


; FOR THE LOVE OF GOD, FIX THIS UGLY HACK!!
%define sectors 18		; sectors/track, must not be greater than 80
%define heads 1			; max head
%define startsec 0x11	; start of kernel on disk


	BITS 16

	org 0

	section .text
start:
	; init segment regs and stack
	mov		ax, cs
	mov		ds, ax
	mov		es, ax
	mov		ss, ax
	xor		sp, sp

	call	LoadSys
	DEBUG	0xB800, 0, 0

	call	A20Enable
	DEBUG	0xB800, 1, 1

	call	InitPIC
	DEBUG	0xB800, 2, 2

	call	InitGDT
	DEBUG	0xB800, 3, 3

	; enter protected mode
	mov		eax, cr0
	or		eax, 0x00000001
	mov		cr0, eax

	; reload segment registers and pass control to system code
	mov		ax, DATA32_SEL
	mov		ds, ax
	mov		es, ax
	mov		fs, ax
	mov		gs, ax
	mov		ss, ax
	mov		esp, SYSEND-SYS_ADDR

	jmp		CODE32_SEL:0


;=== Load Sys ==================================================================
; This routine is a bit more complex than I would like it to be. This is because
; we can't read more than one track per int 13, before having to change cyl.
; More complexity is added by the fact that the read can start in the middle of
; a track so the rest of it must be read in first, before resorting to full
; track reads. Furthermore, the destination pointer must be updated after each
; read with the proper amount of bytes. The one thing this routine can't do
; is to place the data at an arbitrary memory position.
;===============================================================================
LoadSys:
	mov		di, 8					; load 512K from disk (8 read loops)

	mov		bx, SYS_ADDR>>4			; es:bx is system start (0x1000:0000)
	mov		es, bx					; don't put sys start at non-64K boundary
	xor		bx, bx					; or else the code wont work (yet)

	mov		bp, 0x80				; read 64K per loop

	mov		ax, sectors+1-startsec	; read up to beginning of next track
	mov		cx, startsec
	xor		dx, dx					; head 0, drive 0 (floppy)
	call	ReadSect
	sub		bp, ax
	add		bx, (sectors+1-startsec)*0x200
	
	mov		cx, 0x0001
.read:								; here we read one track at a time
	mov		ax, sectors				; xcept for possibly the last read
	cmp		bp, ax
	ja		.10
	mov		ax, bp
.10:
	cmp		dh, heads				; if last head on this cyl, switch cyl
	jne		.20
	xor		dh, dh
	add		ch, 1					; next cyl
	jmp		.30
.20:
	add		dh, 1					; next head
.30:
	call	ReadSect
	sub		bp, ax
	shl		ax, 9
	add		bx, ax
	or		bp, bp
	jnz		.read

	call	FloppyOff

	ret


;=== ReadSect ==================================================================
; es:bx		destination buffer (don't cross 64k boundary)
; cx		cylinder, sector
; dx		head, drive
; al		sectors to read (no more than one track)
;===============================================================================
ReadSect:
	push	ax, si
	
	mov		si, 4					; retry 4 times
	; << NEXT INSTR SHOULD BE IN .read LOOP (?) >>
	mov		ah, 0x02				; read sectors function
.read:
	; read sectors
	push	ax						; al can get fucked up sometimes, so save it
	int		0x13
	pop		ax
	jnc		.exit
	; reset disc controller
	xor		ah, ah
	int		0x13
	dec		si
	jnz		.read
	; too many failures, halt exeution
	call	FloppyOff
	jmp		Halt16

.exit:
	pop		ax, si
	ret


;=== FloppyOff =================================================================
FloppyOff:
	mov		dx, 0x3F2				; kill floppy motor
	xor		al, al
	out		dx, al
	ret
	
	
;=== A20Enable =================================================================
A20Enable:
	push	ds, es
	
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
	jz		.done
	jmp		Halt16

.done:
	pop		ds, es
	ret

A20Test:
	mov		al, [0]
	mov		ah, al
	xor		al, 0xFF
	xchg	[es:0x10], al
	cmp		[0], ah				; if zf=1 then A20 enabled
	mov		[es:0x10], al
	ret


;=== InitPIC ===================================================================
InitPIC:
	cli

	; ICW1
	mov		al, 0x11			; cascaded PICs, edge triggered, will send ICW4
	out		0x20, al
	out		0xA0, al
	; ICW2
	mov		al, 0x20			; PIC1 vectors = 32-39
	out		0x21, al			; PIC2 vectors = 40-47
	mov		al, 0x28
	out		0xA1, al
	; ICW3
	mov		al, 0x04			; PIC1 = IR2 connected to slave
	out		0x21, al			; PIC2 = slave ID 2
	mov		al, 0x02
	out		0xA1, al
	; ICW4
	mov		al, 0x01			; not specially fully nested mode, 8086 mode
	out		0x21, al			; non-buffered mode, normal EOI
	out		0xA1, al
	
	; OCW1 - mask all interrupts
	mov		al, 0xFF
	out		0x21, al
	out		0xA1, al

	ret


;=== Halt16 ====================================================================
Halt16:
	jmp		$


	BITS 32
;=== Halt32 ====================================================================
Halt32:
	jmp		$


%include "gdt.asm"
