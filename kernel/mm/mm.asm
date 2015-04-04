
%include "config.h"
%include "mm.h"
%include "debug.h"


extern Printk
extern PrintD
extern Idle

global InitMM


	BITS 32

	section .text
;===[ InitMM ]==================================================================
; Init the various parts of the mm, including paging and other stuff.
;===============================================================================
InitMM:
	; set up minimal page directory and page table
;	mov		eax, page_table
	add		eax, 0x10000
	add		eax, PAGE_SIZE
	add		eax, SYS_ADDR
	and		eax, 0xFFFFF000				; XXX shouldn't be needed
	or		eax, PTE_PY
	or		[page_dir], eax 

	push	dword eax
	call	PrintD
	
	mov		eax, SYS_ADDR
	add		eax, 0x10000
	and		eax, 0xFFFFF000				; XXX shouldn't be needed
	or		eax, PTE_PY
	or		[page_table], eax

	mov		ecx, PAGE_TABLE_SIZE/4
	xor		eax, eax
	or		eax, PTE_PY
.fixtab:
	mov		[page_table+ecx*4], eax
	add		eax, PAGE_SIZE
	loop	.fixtab

	push	dword eax
	call	PrintD

;	call	Idle

	mov		ecx, page_tables_size/4
	mov		esi, page_dir
	mov		edi, 0x10000
	rep		movsd

	call	Idle

	; enable paging
	mov		eax, page_dir				; set page dir base addr in cr3
	mov		eax, 0x10000
	shl		eax, 10
	mov		cr3, eax

	mov		eax, cr0					; set paging bit in cr0
	or		eax, 0x80000000
	mov		cr0, eax

	jmp		$

	push	dword init_mm_str
	call	Printk

	ret


	section .data
init_mm_str:	db	'Memory Manager Initialized', 0x0A, 0

;===[ Page directory ]===
; must be 4Kb-aligned

page_dir:
	%rep PAGE_TABLE_SIZE/4
	page_entry	0, PTE_PN |PTE_RWY |PTE_S |PTE_PWB |PTE_PCY |PTE_AN |PTE_PSP
	%endrep

page_table:
	%rep PAGE_TABLE_SIZE/4
	page_entry	0, PTE_PN |PTE_RWY |PTE_S |PTE_PWB |PTE_PCY |PTE_AN |PTE_PSP
	%endrep

page_tables_end:

page_tables_size	equ	page_tables_end-page_dir
