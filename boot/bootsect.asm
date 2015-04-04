
; bootsector is responsible for loading and passing control to the os setup code

%include "config.h"
	
	bits 16
	org 0x0

	section .text
; move bootsector code to a safe location 
start:
	mov		ax, BOOTSEG
	mov		ds, ax
	mov		ax, INITSEG
	mov		es, ax
	xor		di, di
	xor		si, si
	mov		cx, 0x50
	cld
	rep		movsd
	jmp		INITSEG:safe

; set up stack
safe:
	mov		ds, ax
	cli
	mov		ss, ax
	mov		sp, 0xFFFF
	sti
	
; load os loder into memory
	mov		si, 4				; number of retries
read:
	xor		ah, ah				; reset disk controller
	mov		dl, 0x80			; for both hd and fd
	int		0x13

	mov		ax, 0x0208			; sector read
	mov		cx, 0x0002			; start at sector 2
	xor		dx, dx				; drive 0 (floppy), head 0
	mov		bx, SETUPSEG		; put loader after bootsector (9020:0000)
	mov		es, bx
	xor		bx, bx
	int		0x13
	jnc		ok
	dec		si
	jnz		read
	jmp		halt

; pass control to os setup code
ok:
	jmp		SETUPSEG:0

; halt system, reboot to recover
halt:
.loop:
	jmp		.loop

; zero the rest of the sector
pad:
times 512-$+start	db 0
