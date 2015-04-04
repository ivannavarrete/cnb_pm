
%include "config.h"
%include "debug.h"


global FindEntry


	BITS 32

	section .text
;===[ FindEntry ]===============================================================
; int FindEntry()
;===============================================================================
; Find a free entry in GDT and return it's index (not selector).
;===============================================================================
FindEntry:
	enter	0, 0
	push	ecx, esi, ds

	mov		ax, GDT_SEL
	mov		ds, ax
	xor		esi, esi
	cld

	mov		ecx, GDT_LIMIT/8

.search:
	cmp		dword [esi], 0
	jne		.10
	cmp		dword [esi+4], 0
	je		.found
.10:
	add		esi, 8
	loop	.search
	
.found:
	mov		eax, GDT_LIMIT/8
	sub		eax, ecx

	pop		ecx, esi, ds
	leave
	ret		0x0
