; Here is the dilemma. Ultimately we would want to have access to the console
; through a proper driver handled by the driver subsystem. However, we can't
; set this up since the driver subsystem requires large parts of the kernel
; to be up and running (mem manager, etc.) and we want to be able to
; have simple output in the early stages of kernel init mostly for debugging
; purposes. Oh, and also, we don't have a driver subsystem yet! haha..
; This module is buggy, incomplete and untested. Beware..


%include "config.h"


global InitConsole:function
global ClearScreen:function
global ConsoleWrite:function
global GotoXY:function
global SetMode:function
global ScrollUp:function
global ScrollDown:function


	section .text
;===[ InitConsole ]=============================================================
; int InitConsole(int scr_mode, int attr)
;===============================================================================
; need to implement mode setup
;===============================================================================
InitConsole:
.scr_mode:			equ		0x08
.attr:				equ		0x0C

	enter	0, 0
	push	ebx

	; initialize console variables
	mov		eax, 25
	mov		ebx, 80
	mov		[rows], eax
	mov		[cols], ebx
	mul		bx
	mov		[cells], eax
	mov		eax, [ebp+.attr]
	mov		byte [attr], al

	; set x,y position
	push	dword 2
	push	dword 0
	call	GotoXY

	xor		eax, eax,
	pop		ebx
	leave
	ret		8


;===[ ClearScreen ]=============================================================
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


;===[ ConsoleWrite ]============================================================
; void ConsoleWrite(const char *str)
;===============================================================================
ConsoleWrite:
.str:				equ		0x08

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
	cmp		al, 0x0A				; handle newline
	jne		.10
	mov		eax, [cols]
	sub		al, bl
	shl		eax, 1
	add		edi, eax
	jmp		.49
.10:
	or		al, al					; handle NULL
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


;===[ GotoXY ]==================================================================
; void GotoXY(int x, int y)
;===============================================================================
GotoXY:
.x:					equ		0x08
.y:					equ		0x0C

	enter	0, 0
	push	eax

	mov		eax, [ebp+.x]
	mov		[x], eax
	mov		eax, [ebp+.y]
	mov		[y], eax

	pop		eax
	leave
	ret		8


;===[ SetMode ]=================================================================
; int SetMode(int src_mode, int attr)
;===============================================================================
SetMode:
.src_mode:			equ		0x08
.attr:				equ		0x0C

	enter	0, 0

	mov		eax, [ebp+.attr]
	mov		byte [attr], al

	xor		eax, eax
	leave
	ret		8
	

;===[ ScrollUp ]================================================================
; void ScrollUp(void)
;===============================================================================
; not implemented
ScrollUp:

	ret
	

;===[ ScrollDown ]==============================================================
; void ScrollDown(void)
;===============================================================================
; not implemented
ScrollDown:

	ret



	section .data
; x, y, rows and cols must not exceed 0xFF. They are dwords for easier
; computing when using word only regs (si, di, ...)
x:				dd	0
y:				dd	0

rows:			dd	0
cols:			dd	0
cells:			dd	0

attr:			db	0

