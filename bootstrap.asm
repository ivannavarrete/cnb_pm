
; 18 Jul 2000 (?)

; cnb bootsector
;	responsible for loading and launching the os loader


%include "bootstrap.h"

	bits 16
	org 0x0

	section .text
start:
;====== move code to a safe location ======
	mov		ax, BOOTSEG
	mov		ds, ax
	mov		ax, INITSEG
	mov		es, ax
	xor		si, si
	xor		di, di
	mov		cx, 0x50
	cld
	rep		movsd
	jmp		INITSEG:safe

safe:
;====== set up stack ======
	mov		ds, ax
	cli
	mov		ss, ax
	mov		sp, 0xFFFF
	sti

;====== load os loader ======
	mov		si, 4
read:
	xor		ah, ah					; reset drive
	mov		dl, 0x80				; both hd and fd
	int		0x13

	mov		ax, 0x0200+LOADER_SZ_S	; read os-loader into mem
	mov		cx, 0x0002				; cylinder, sector
	xor		dx, dx					; head, drive
	mov		bx, LOADERSEG			; es:bx - dest
	mov		es, bx
	xor		bx, bx
	int		0x13
	jnc		ok
	dec		si
	jnz		read
	jmp		halt
ok:

;====== pass control to os loader ======
	jmp		LOADERSEG:0


;============================================
; halt system, reboot to recover
;============================================
halt:
.loop:
	jmp		.loop
	
	
