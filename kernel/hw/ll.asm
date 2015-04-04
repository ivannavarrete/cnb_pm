
; Some lowlevel help routines.


%include "config.h"
%include "debug.h"


extern Printk
extern PrintD
extern PrintW

global DumpRegs
global DumpIDT
global DumpGDT
global DumpTSS


	BITS 32

	section .text
;===[ DumpRegs ]================================================================
;
;===============================================================================
DumpRegs:


	ret


;===[ DumpIDT ]=================================================================
; void DumpIDT(int start, int n)
;===============================================================================
DumpIDT:
.start:		equ 0x08
.n:			equ 0x0C

	enter	0, 0
	push	eax, ecx, edi, fs

	push	dword idt_hdr_str
	call	Printk

	sidt	[dtr]
	xor		eax, eax
	mov		ax, [dtr+4]
	push	eax
	call	PrintW
	mov		eax, [dtr]
	push	eax
	call	PrintD

	push	dword hdr_end_str
	call	Printk

	mov		ax, IDT_SEL
	mov		fs, ax
	mov		edi, [ebp+.start]
	shl		edi, 3
	mov		ecx, [ebp+.n]

.dump:
	push	dword [fs:edi+4]
	call	PrintD
	push	dword space
	call	Printk
	push	dword [fs:edi]
	call	PrintD
	push	dword nl
	call	Printk

	add		edi, 8
	loop	.dump

	pop		eax, ecx, edi, fs
	leave
	ret		0x08


;===[ DumpGDT ]=================================================================
; void DumpGDT(int start, int n)
;===============================================================================
DumpGDT:
.start:			equ 0x08
.n:				equ 0x0C

	enter	0, 0
	push	eax, ecx, edi, fs

	; display header including the gdtr
	push	dword gdt_hdr_str
	call	Printk

	sgdt	[dtr]
	xor		eax, eax
	mov		ax, [dtr+4]
	push	eax
	call	PrintW
	mov		eax, [dtr]
	push	eax
	call	PrintD

	push	dword hdr_end_str
	call	Printk

	mov		ax, GDT_SEL
	mov		fs, ax
	;xor		edi, edi
	mov		edi, [ebp+.start]	; fs:edi points to start descriptor to dump
	shl		edi, 3
	mov		ecx, [ebp+.n]		; dump only a few descriptors

.dump:
	push	dword [fs:edi+4]
	call	PrintD
	push	dword space
	call	Printk
	push	dword [fs:edi]
	call	PrintD
	push	dword nl
	call	Printk

	add		edi, 8
	loop	.dump
	
	pop		eax, ecx, edi, fs
	leave
	ret		0x08


;===[ DumpTSS ]=================================================================
; void DumpTSS(void *addr)
;===============================================================================
DumpTSS:
.addr:		equ	0x08

	enter	0, 0
	push	ecx, esi

	mov		ecx, 104/8				; XXX don't use a hardcoded size
	;sub		ecx, 7
	
	mov		esi, [ebp+.addr]
	add		esi, 104-4				; XXX -- " --
	;add		esi, 104-7*4		; XXX don't use a hardcoded size

.dump:
	push	dword [esi]
	call	PrintD
	push	dword space
	call	Printk
	push	dword [esi-4]
	call	PrintD
	push	dword nl
	call	Printk

	sub		esi, 8
	;add		esi, 4
	loop	.dump

	pop		ecx, esi
	leave
	ret		4


	section .data
idt_hdr_str:		db	0x0A, '===[ IDT ]===[ idtr: ', 0
gdt_hdr_str:		db	0xA, 0x0A, '===[ GDT ]===[ gdtr: ', 0
hdr_end_str:		db	' ]===', 0xA, 0

nl:					db	0xA, 0
space:				db	' ', 0

dtr:				dw	0, 0, 0
