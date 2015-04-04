
; 23/04/2000
;
; DMA channel management

%define _DMA_C
%include "dma.h"


global request_dma
global release_dma
global enable_dma
global disable_dma
global set_dma_mode
global set_dma_addr
global set_dma_count


	section .text
;=== request_dma ===============================================================
; int request_dma(int chan, const char *dev)
;===============================================================================
request_dma:
.chan:			equ		0x08
.dev:			equ		0x0C

	enter	0, 0
	push	esi

	mov		eax, [ebp+.chan]
	cmp		eax, MAX_DMA_CHAN
	ja		.exitf								; invalid dma channel
	lea		esi, [dma_chans+eax*DMA_CHAN_SS]
	cmp		dword [esi+dma_chan.lock], 1		; dma channel busy
	je		.exitf
	mov		dword [esi+dma_chan.lock], 1		; allocate dma channel
	mov		eax, [ebp+.dev]
	mov		[esi+dma_chan.dev], eax
	xor		eax, eax
	jmp		.exit

.exitf:
	mov		eax, -1
.exit:
	pop		esi
	leave
	ret		8


;=== release_dma ===============================================================
; void release_dma(int chan)
;===============================================================================
release_dma:
.chan:			equ		0x08

	enter	0,0
	push	esi

	mov		eax, [ebp+.chan]
	cmp		eax, MAX_DMA_CHAN
	ja		.exitf								; invalid dma channel
	lea		esi, [dma_chans+eax*DMA_CHAN_SS]
	cmp		dword [esi+dma_chan.lock], 0		; dma channel already free
	je		.exitf
	mov		dword [esi+dma_chan.lock], 0		; free dma channel

.exitf:
	pop		esi
	leave
	ret		4


;=== enable_dma ================================================================
; int enable_dma(int chan)
;===============================================================================
enable_dma:
.chan:			equ		0x08

	enter	0,0
	push	edx

	mov		eax, [ebp+.chan]
	cmp		eax, MAX_DMA_CHAN
	ja		.exitf
	
	mov		dx, [dma_maskreg+eax]		; get mask register for this channel
	and		eax, 0x03
	out		dx, al
	xor		eax, eax
	jmp		.exit

.exitf:
	mov		eax, -1
.exit:
	pop		edx
	leave
	ret		4


;=== disable_dma ===============================================================
; int disable_dma(int chan)
;===============================================================================
disable_dma:
.chan:			equ		0x08

	enter	0,0
	push	edx

	mov		eax, [ebp+.chan]
	cmp		eax, MAX_DMA_CHAN
	ja		.exitf
	
	mov		dx, [dma_maskreg+eax]		; get mask register for this channel
	and		eax, 0x03
	or		eax, 0x04
	out		dx, al
	xor		eax, eax
	jmp		.exit

.exitf:
	mov		eax, -1
.exit:
	pop		edx
	leave
	ret		4


;=== set_dma_mode ==============================================================
; int set_dma_mode(int chan, int mode)
;===============================================================================
set_dma_mode:
.chan:			equ		0x08
.mode:			equ		0x0C

	enter	0,0

	mov		eax, -1

	leave
	ret		8


;=== set_dma_addr ==============================================================
; int set_dma_addr(int chan, int addr)
;===============================================================================
set_dma_addr:
.chan:			equ		0x08
.addr:			equ		0x0C

	enter	0,0
	push	ebx, ecx, edx

	mov		eax, -1
	mov		ebx, [ebp+.chan]
	cmp		ebx, MAX_DMA_CHAN
	ja		.exitf

	mov		ecx, [ebp+.addr]
	cmp		ecx, MAX_DMA_ADDR
	ja		.exitf

	mov		eax, ecx				; set dma page
	shr		eax, 0x10
	mov		dx, [dma_page+ebx]
	out		dx, al

	mov		ax, cx					; set dma addr
	mov		dx, [dma_addr+ebx]
	out		dx, al
	shr		ax, 4
	out		dx, al
	
	xor		eax, eax
.exitf:
	pop		ebx, ecx, edx
	leave
	ret		8


;=== set_dma_count =============================================================
; int set_dma_count(int chan, int count)
;===============================================================================
set_dma_count:
.chan:			equ		0x08
.count:			equ		0x0C

	enter	0,0

	mov		eax, -1

	leave
	ret		8



	section .data
; array of dma channel structures
dma_chans:
%rep 3
istruc dma_chan
	at dma_chan.lock,		db 0
	at dma_chan.dev,		dd 0
iend
%endrep

istruc dma_chan
	at dma_chan.lock,		db 1
	at dma_chan.dev,		dd cascade_str
iend

%rep MAX_DMA_CHAN-3
istruc dma_chan
	at dma_chan.lock,		db 0
	at dma_chan.dev,		dd 0
iend
%endrep

cascade_str:	db	"cascade", 0

; dma channel registers
dma_maskreg:	dw	DMA_1_MASKREG, DMA_1_MASKREG, DMA_1_MASKREG, DMA_1_MASKREG
				dw	DMA_2_MASKREG, DMA_2_MASKREG, DMA_2_MASKREG, DMA_2_MASKREG
dma_page:		dw	DMA_0_PAGE, DMA_1_PAGE, DMA_2_PAGE, DMA_3_PAGE
				dw	DMA_4_PAGE, DMA_5_PAGE, DMA_6_PAGE, DMA_7_PAGE
dma_addr:		dw	DMA_0_ADDR, DMA_1_ADDR, DMA_2_ADDR, DMA_3_ADDR
				dw	DMA_4_ADDR, DMA_5_ADDR, DMA_6_ADDR, DMA_7_ADDR
dma_count:		dw	DMA_0_COUNT, DMA_1_COUNT, DMA_2_COUNT, DMA_3_COUNT
				dw	DMA_4_COUNT, DMA_5_COUNT, DMA_6_COUNT, DMA_7_COUNT
