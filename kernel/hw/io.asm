
; 22/04/2000
;
; IO-port region management.

%define _IO_C
%include "io.h"

%include "descriptor.h"
%include "config.h"


global request_io
global release_io
global check_io


	section .text
;=== request_io ================================================================
; int request_io(int start, int end, const char *dev)
;===============================================================================
request_io:
.start:			equ		0x08
.end:			equ		0x0C
.dev:			equ		0x10

	enter	0, 0
	push	ecx, esi, edi

	; find a free io_region struct in table
.find:
	mov		ecx, MAX_IO_REGIONS
	mov		esi, io_table
	cmp		byte [esi+io_region.lock], 0
	je		.found
	add		esi, IO_REGION_SS
	loop	.find
	jmp		.exitf

	; find where to insert new region in linked list
.found:
	push	dword [ebp+.end]
	push	dword [ebp+.start]
	push	dword io_list
	call	find_gap
	or		eax, eax
	jz		.exitf
	mov		edi, eax

	; insert new region struct into table
	mov		byte [esi+io_region.lock], 1
	mov		eax, [ebp+.start]
	mov		[esi+io_region.start], eax
	mov		eax, [ebp+.end]
	mov		[esi+io_region.end], eax
	mov		eax, [ebp+.dev]
	mov		[esi+io_region.dev], eax
	
	; insert new region struct into list
	mov		eax, [edi+io_region.next]
	mov		[edi+io_region.next], esi
	mov		[esi+io_region.next], eax
	xor		eax, eax
	jmp		.exit

.exitf:
	mov		eax, -1
.exit:
	pop		ecx, esi, edi
	leave
	ret		0x0C


;=== release_io ================================================================
; void release_io(int start, int end)
;===============================================================================
release_io:
.start:			equ		0x08
.end:			equ		0x0C

	enter	0, 0
	push	eax, ebx, esi, edi

	mov		eax, [ebp+.start]
	mov		ebx, [ebp+.end]
	mov		esi, io_list

	; find region in linked list and free it
.find:
	mov		edi, [esi+io_region.next]
	or		edi, edi
	jz		.exit
	cmp		[edi+io_region.start], eax
	jne		.next
	cmp		[edi+io_region.end], ebx
	jne		.next
	mov		byte [edi+io_region.lock], 0		; free io region
	mov		eax, [edi+io_region.next]
	mov		[esi+io_region.next], eax
	
.exit:
	pop		eax, ebx, esi, edi
	leave
	ret		8

.next:
	mov		esi, edi
	jmp		.find
	

;=== check_io ==================================================================
; int check_io(int start, int end)
;===============================================================================
check_io:
.start:			equ		0x08
.end:			equ		0x0C

	enter	0, 0

	push	dword [ebp+.end]
	push	dword [ebp+.start]
	push	dword io_list
	call	find_gap
	or		eax, eax
	jz		.exit
	mov		eax, 1

.exit:
	leave
	ret		8


;=== find_gap ==================================================================
; struct io_region *find_gap(struct io_region *root, int start, int end)
;===============================================================================
find_gap:
.root:			equ		0x08
.start:			equ		0x0C
.end:			equ		0x10

	enter	0, 0
	push	ebx, esi, edi

	mov		esi, [ebp+.root]
	mov		eax, [ebp+.start]
	mov		ebx, [ebp+.end]
.find:
	cmp		esi, [ebp+.root]
	je		.skipfirst
	cmp		eax, [esi+io_region.end]		; cur->end >= start ? bad
	jbe		.exitf
.skipfirst:
	cmp		dword [esi+io_region.next], 0	; last item ? good
	je		.exit
	mov		edi, [esi+io_region.next]
	cmp		[edi+io_region.start], ebx		; next->start > end ? good
	ja		.exit
	mov		esi, [esi+io_region.next]
	jmp		.find

.exitf:
	xor		esi, esi
.exit:
	mov		eax, esi
	pop		ebx, esi, edi
	leave
	ret		0xC



	section .data
; root io region (dummy)
io_list:		istruc io_region
	at io_region.lock,		db 1
	at io_region.start,		dd 0
	at io_region.end,		dd 0
	at io_region.dev,		dd no_name
	at io_region.next,		dd 0
iend:

; io region table
io_table:
%rep MAX_IO_REGIONS
istruc io_region
	at io_region.lock,		db 0
	at io_region.start,		dd 0
	at io_region.end,		dd 0
	at io_region.dev,		dd 0
	at io_region.next,		dd 0
iend
%endrep

no_name:		db	0
