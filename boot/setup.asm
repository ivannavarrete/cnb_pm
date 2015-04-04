
; The setup code loads the kernel into memory, enables A20, reprograms the PIC,
; sets up a minimal GDT, switches to pmode, and jumps to kernel init code. The
; setup code must not exceed 15 sectors (7680 bytes).


%include "config.h"
%include "irq.h"
%include "debug.h"


; FOR THE LOVE OF GOD, FIX THIS UGLY HACK!!
; Maybe these (and some other constants) should be in the bootsector, set to
; proper values for the disc when the bootsector is created.
%define sectors 18			; sectors/track, must not be greater than 80
%define heads 1				; max head
%define startsec 0x11		; start of kernel on disk


	BITS 16
	org 0

	section .text
start:
	; clear screen of possible BIOS output (not that important but more clean)
	mov		ax, VIDEO_ADDR>>4
	mov		es, ax
	xor		eax, eax
	xor		edi, edi
	mov		ecx, 40*25
	rep		stosd

	; init segment registers and stack
	mov		ax, cs
	mov		ds, ax
	mov		es, ax
	mov		ss, ax
	xor		sp, sp

	; set different video mode
	mov		ax, 0x001C
	int		0x10

	call	LoadSys
	DEBUG	VIDEO_ADDR>>4, 0, 0, ax

	call	A20Enable
	DEBUG	VIDEO_ADDR>>4, 1, 1, ax

	call	InitPIC
	DEBUG	VIDEO_ADDR>>4, 2, 2, ax

	call	InitGDT
	DEBUG	VIDEO_ADDR>>4, 3, 3, ax

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
	mov		esp, SYS_END-SYS_ADDR		; XXX Is this correct?

	; the offset of kernel_init is determined by the linking in the kernel
	; subdir so make sure it is correct (this file and the kernel are
	; completely independent so that's why we hardcode the offset here)
	jmp		CODE32_SEL:0


;===[ LoadSys ]=================================================================
; Load kernel into memory.
; This funcrtion is dependant on the defined values sectors/heads/startsec
; as well as using the floppy by default, which needs to be fixed later on.
;===============================================================================
LoadSys:
	mov		di, 8					; load 512k from disk (8 read loops)

	mov		bx, SYS_ADDR>>4			; es:bx is system start (0x1000:0000)
	mov		es, bx					; don't put sys start at non-64k boundary
	xor		bx, bx					; or else the code won't work (int 0x13)

	mov		bp, 0x80				; read 64k in each loop

	; read up to beginning of next track
	mov		ax, sectors+1-startsec
	mov		cx, startsec
	xor		dx, dx					; head 0, drive 0 (floppy)
	call	ReadSect
	sub		bp, ax
	add		bx, (sectors+1-startsec)*0x200

	; read one track at a time (xcept for possibly the last read)
	mov		cx, 0x0001				; start sector (on track)
.read:
	mov		ax, sectors				; number of sectors per track
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

	call	KillFloppy

	ret


;===[ ReadSect ]================================================================
; Read sectors.
;
; input:
;	es:bx		destination buffer (don't cross 64k boundary)
;	cx			cylinder, sector
;	dx			head, drive
;	al			sectors to read (no more than one track)
;===============================================================================
ReadSect:
	push	ax, si

	mov		si, 4				; retry 4 times
.read:
	; read sectors
	mov		ah, 0x02			; read sectors function
	push	ax					; al can get fucked up sometimes, so save it
	int		0x13
	pop		ax
	jnc		.exit
	; reset disc controller
	xor		ah, ah
	int		0x13
	dec		si
	jnz		.read
	; to many failures, halt execution
	call	KillFloppy
	jmp		Halt16

.exit:
	pop		ax, si
	ret


;===[ KillFloppy ]==============================================================
; Kill floppy motor.
;===============================================================================
KillFloppy:
	mov		dx, 0x3F2
	xor		al, al
	out		dx, al
	ret


;===[ A20Enable ]===============================================================
; Enable address line 20.
;===============================================================================
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


;===[ A20Test ]=================================================================
; Test whether address line 20 is masked or not. This is done by reading a byte
; at address 0x00000 and then writing a different byte at address 0x10000. If
; after the write the byte at address 0x00000 changed it means that 0x10000 is
; the same address as 0x00000, i.e. address line 20 is masked.
;
; output:
;	EFlag[Z] set	= Addr[20] enabled
;	EFlag[Z] clear	= Addr[20] disabled
;===============================================================================
A20Test:
	mov		al, [0]
	mov		ah, al
	xor		al, 0xFF
	xchg	al, [es:10]			; write al at 0x00000 or 0x10000
	cmp		ah, [0]				; this sets/clears EFlags[Z]
	mov		[es:10], al
	ret
	

;===[ InitPIC ]=================================================================
; Initialize Programmable Interrupt Controller. Set external interrupt vectors
; to IRQ0-IRQ15 = vector0x20-vector0x2F. Mask and disable all interrupts. Etc.
;===============================================================================
InitPIC:
	cli

	; ICW1
	mov		al, 0x11			; cascaded PIC, edge triggered, will send ICW4
	out		0x20, al
	out		0xA0, al
	; ICW2
	mov		al, IRQ_BASE		; PIC1 vectors = 32-39
	out		0x21, al
	mov		al, IRQ_BASE+8		; PIC2 vectors = 40-47
	out		0xA1, al
	; ICW3
	mov		al, 0x04			; PIC1 = IRQ2 connected to slave
	out		0x21, al
	mov		al, 0x02			; PIC2 = slave ID 2
	out		0xA1, al
	; ICW4
	mov		al, 0x01			; not specially fully nested mode, 8086 mode,
	out		0x21, al			; non-buffered mode, normal EOI
	out		0xA1, al

	; OCW1 - mask all interrupts
	mov		al, 0xFF
	out		0x21, al
	out		0xA1, al

	ret


;===[ Halt16 ]==================================================================
Halt16:
	jmp		$


	BITS 32
;===[ Halt32 ]==================================================================
Halt32:
	jmp		$



%include "gdt.asm"
