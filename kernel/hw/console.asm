
; This module is buggy, incomplete and untested. Beware..


%include "config.h"


global InitConsole
global ClearScreen
global ConsoleWrite
global GotoXY
global SetMode
global ScrollUp
global ScrollDown


	section .text
;=== InitConsole ===============================================================
; int InitConsole(int scr_mode, int attr)
;===============================================================================
; need to implement mode setup
InitConsole:
.scr_mode:			equ		0x08
.attr:				equ		0x0C

	enter	0, 0
	push	eax, ebx

	mov		ax, 25
	mov		bx, 80
	mov		[rows], eax
	mov		[cols], ebx
	mul		bx
	mov		[cells], eax
	mov		eax, [ebp+.attr]
	mov		byte [attr], al
	xor		eax, eax

	pop		eax, ebx
	leave
	ret		8


;=== ClearScreen ===============================================================
; void ClearScreen(void)
;===============================================================================
ClearScreen:
	push	eax, ecx, edi, es
	
	mov		ax, VIDEO_SEL
	mov		es, ax
	xor		edi, edi
	mov		ecx, [cells]
	xor		ax, ax
	rep		stosw

	pop		eax, ecx, edi, es
	ret


;=== ConsoleWrite ==============================================================
; void ConsoleWrite(const char *str)
;===============================================================================
ConsoleWrite:
.str:			equ		0x08

	enter	0, 0
	push	eax, ebx, edx, esi, edi, es

	; esi=src string, edi=console
	mov		ax, VIDEO_SEL
	mov		es, ax
	mov		eax, [y]
	mul		word [cols]
	mov		edi, eax
	mov		eax, [x]
	add		edi, eax
	shl		edi, 1
	mov		esi, [ebp+.str]

	mov		bl, [x]
	mov		bh, [y]
	cld

.write:
	lodsb
	cmp		al, 0xA				; handle newline
	jne		.10
	mov		eax, [cols]
	sub		al, bl
	shl		eax, 1
	add		edi, eax
	jmp		.49
.10:
	or		al, al				; handle null
	je		.exit
	
	mov		ah, [attr]
	stosw
	inc		bl
	cmp		bl, [cols]
	jb		.50
.49:
	xor		bl, bl
	inc		bh
	cmp		bh, [rows]
	jb		.50
	call	ScrollDown
	mov		bl, [x]
	mov		bh, [y]
.50:
	mov		[x], bl
	mov		[y], bh
	jmp		.write

	; update console coordinates and exit
.exit:
	mov		[x], bl
	mov		[y], bh

	pop		eax, ebx, edx, esi, edi, es
	leave
	ret		4


;=== GotoXY ====================================================================
; void GotoXY(int x, int y)
;===============================================================================
GotoXY:
.x:				equ		0x08
.y:				equ		0x0C

	enter	0, 0
	push	eax

	mov		eax, [ebp+.x]
	mov		[x], eax
	mov		eax, [ebp+.y]
	mov		[y], eax

	pop		eax
	leave
	ret		8


;=== SetMode ===================================================================
; int SetMode(int scr_mode, int attr)
;===============================================================================
; not implemented
SetMode:
.scr_mode:			equ		0x08
.attr:				equ		0x0C

	enter	0, 0

	mov		eax, -1

	leave
	ret		8


;=== ScrollUp ==================================================================
; void ScrollUp(void)
;===============================================================================
ScrollUp:
	push	eax, ebx, ecx, esi, edi, es
	push	ds

	; esi=next to last row, edi=last row
	mov		edi, [cells]
	mov		esi, edi
	sub		si, [cols]
	
	; cl=num cols to move/row, al=num rows to move
	mov		ecx, [cols]
	mov		eax, -1
	add		ax, [rows]
	mov		ah, cl				; for fast cols access

	mov		bx, VIDEO_SEL
	mov		ds, bx
	mov		es, bx
	; scroll screen
	std
.scroll:
	rep		movsw
	dec		al
	jz		.scroll_done
	mov		cl, ah
	jmp		.scroll

	; update current position
.scroll_done:
	pop		ds
	mov		dword [x], 0
	mov		dword [y], 0

	pop		eax, ebx, ecx, esi, edi, es
	ret


;=== ScrollDown ================================================================
; void ScrollDown(void)
;===============================================================================
; doesn't work (GPF)
ScrollDown:
	push	eax, ebx, ecx, esi, edi, es
	push	ds

	; number of rows to move
	mov		eax, -1
	add		ax, [rows]

	; esi=row2, edi=row1
	xor		edi, edi
	mov		ecx, [cols]
	mov		esi, ecx
	mov		ah, cl				; save cols in register for fast access

	mov		bx, VIDEO_SEL
	mov		ds, bx
	mov		es, bx
	; scroll screen
	cld
.scroll:
	rep		movsw
	dec		al
	jz		.scroll_done
	mov		cl, ah
	jmp		.scroll

	; update current position
.scroll_done:
	pop		ds
	mov		eax, [rows]
	dec		eax
	mov		[y], eax
	mov		dword [x], 0

	pop		eax, ebx, ecx, esi, edi, es
	ret


	section .data
; x, y, rows, and cols *must not* exceed 0xFF. They're dwords for easier
; computing when using word-only regs (si, di, ...)
x:				dd	0
y:				dd	0

rows:			dd	0
cols:			dd	0
cells:			dd	0

attr:			db	0
