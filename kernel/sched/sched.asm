
%include "debug.h"
%include "config.h"
%include "descriptor.h"
%include "sysdef.h"

%include "sched.h"

extern request_irq
extern enable_irq
extern request_desc

extern PrintB
extern PrintW
extern PrintD


global InitSched


	BITS 32

	section .text
InitSched:
	DEBUG	VIDEO_SEL, 22, 2
	sti

	pushfd
	pop		eax
	mov		[task1_tss+tss.eflags], eax
	mov		[task2_tss+tss.eflags], eax
	mov		[bogus_tss+tss.eflags], eax
;	or		eax, 0x4000
	mov		[sched_tss+tss.eflags], eax
	
	push	dword 7
	push	dword D_TSS32 | D_GB | D_DPL0
	push	dword 0x68
	push	dword sched_tss+SYS_ADDR
	call	build_desc
	
	push	dword 8
	push	dword D_TSS32 | D_GB | D_DPL0 ;| D_ST_BTSS
	push	dword 0x68
	push	dword task1_tss+SYS_ADDR
	call	build_desc

	push	dword 9
	push	dword D_TSS32 | D_GB | D_DPL0 ;| D_ST_BTSS
	push	dword 0x68
	push	dword task2_tss+SYS_ADDR
	call	build_desc
	
	push	dword 10
	push	dword D_TSS32 | D_GB | D_DPL0
	push	dword 0x68
	push	dword bogus_tss+SYS_ADDR
	call	build_desc
	
	mov		ax, 10<<3
	ltr		ax

	; program the 8253 PIT chan 0 to 100Hz
	mov		al, 0x34
	out		0x43, al
	mov		al, 0x9B
	out		0x40, al
	mov		al, 0x2E
	out		0x40, al

	; install sheduler at irq0
	push	dword 0
	push	dword scheduler
	push	dword 0
	call	request_irq		; << SWEET JESUS! I need a task gate instead.
	
;	push	dword D_TSGATE | D_DPL0
;	push	dword D_IGATE32 | D_DPL0
;	push	dword scheduler
;	push	dword 7<<3
;	push	dword GATE
;	push	dword IRQ_BASE+0
;	push	dword IDT
;	call	request_desc
	
;	push	ds
;	mov		ax, IDT_SEL
;	mov		ds, ax
;	mov		eax, [(IRQ_BASE<<3)+4]
;	mov		ebx, 80*2*2
;	call	print_d
;	mov		eax, [IRQ_BASE<<3]
;	add		ebx, 16
;	call	print_d
;	pop		ds
	
	; enable irq0
	push	dword 0
	call	enable_irq

;	xor		al, al
;	out		0x21, al
;	out		0xA1, al

	jmp		8<<3:0

	ret


;=== scheduler =================================================================
scheduler:
	DEBUG	VIDEO_SEL, 60, 0
	mov		al, 0x20
	out		0x20, al

	cmp		dword [tmp1], 1
	jne		.10
	mov		dword [tmp1], 0
	call	8<<3:0
.10:
	mov		dword [tmp1], 1
	call	9<<3:0

	iret


;=== build_desc ================================================================
; int build_desc(desc *d, int base, int limit, int flags, int gdt_idx)
;===============================================================================
build_desc:
.base:		equ		0x08
.limit:		equ		0x0C
.flags:		equ		0x10
.gdt_idx:	equ		0x14

	enter	0, 0
	push	eax, esi, edi, es
	
	mov		esi, desc

	; insert base
	mov		eax, [ebp+.base]
	mov		[esi+2], ax
	shr		eax, 16
	mov		[esi+4], al
	mov		[esi+7], ah

	; insert flags & limit
	mov		di, [ebp+.flags]
	and		di, 0xF0FF
	mov		eax, [ebp+.limit]
	mov		[esi], ax
	shr		eax, 8
	and		ax, 0x0F00
	or		ax, di
	mov		[esi+5], ax

	; insert descriptor into gdt
	mov		ax, GDT_SEL
	mov		es, ax
	mov		edi, [ebp+.gdt_idx]
	shl		edi, 3
	movsd
	movsd

	pop		eax, esi, edi, es
	leave
	ret		0x10


;=== task1_code ================================================================
task1_code:
	DEBUG	VIDEO_SEL, 50, 1
	mov		ecx, 0xFFFFF
	loop	$
	DEBUG	VIDEO_SEL, 50, 2
	mov		ecx, 0xFFFFF
	loop	$
	jmp		task1_code


;=== task2_code ================================================================
task2_code:
	DEBUG	VIDEO_SEL, 53, 3
	mov		ecx, 0xFFFFF
	loop	$
	DEBUG	VIDEO_SEL, 54, 4
	mov		ecx, 0xFFFFF
	loop	$
	jmp		task2_code





	section .data
sched_tss:	istruc	tss
	at tss.link,		dd	0
	at tss.esp0,		dd	0x20000
	at tss.ss0,			dd	DATA32_SEL
	at tss.esp1,		dd	0x20000
	at tss.ss1,			dd	DATA32_SEL
	at tss.esp2,		dd	0x20000
	at tss.ss2,			dd	DATA32_SEL
	at tss.cr3,			dd	0
	at tss.eip,			dd	scheduler
	at tss.eflags,		dd	0
	at tss.eax,			dd	0
	at tss.ecx,			dd	0
	at tss.edx,			dd	0
	at tss.ebx,			dd	0
	at tss.esp,			dd	0x20000
	at tss.ebp,			dd	0
	at tss.esi,			dd	0
	at tss.edi,			dd	0
	at tss.es,			dd	DATA32_SEL
	at tss.cs,			dd	CODE32_SEL
	at tss.ss,			dd	DATA32_SEL
	at tss.ds,			dd	DATA32_SEL
	at tss.fs,			dd	DATA32_SEL
	at tss.gs,			dd	DATA32_SEL
	at tss.ldt,			dd	0
	at tss.trap,		dw	0
	at tss.iomap,		dw	0
iend

task1_tss:	istruc	tss
	at tss.link,		dd	0
	at tss.esp0,		dd	0x20000
	at tss.ss0,			dd	DATA32_SEL
	at tss.esp1,		dd	0x20000
	at tss.ss1,			dd	DATA32_SEL
	at tss.esp2,		dd	0x20000
	at tss.ss2,			dd	DATA32_SEL
	at tss.cr3,			dd	0
	at tss.eip,			dd	task1_code
	at tss.eflags,		dd	0
	at tss.eax,			dd	0
	at tss.ecx,			dd	0
	at tss.edx,			dd	0
	at tss.ebx,			dd	0
	at tss.esp,			dd	0x20000
	at tss.ebp,			dd	0
	at tss.esi,			dd	0
	at tss.edi,			dd	0
	at tss.es,			dd	DATA32_SEL
	at tss.cs,			dd	CODE32_SEL
	at tss.ss,			dd	DATA32_SEL
	at tss.ds,			dd	DATA32_SEL
	at tss.fs,			dd	DATA32_SEL
	at tss.gs,			dd	DATA32_SEL
	at tss.ldt,			dd	0
	at tss.trap,		dw	0
	at tss.iomap,		dw	0
iend

task2_tss:	istruc	tss
	at tss.link,		dd	0
	at tss.esp0,		dd	0x20000
	at tss.ss0,			dd	DATA32_SEL
	at tss.esp1,		dd	0x20000
	at tss.ss1,			dd	DATA32_SEL
	at tss.esp2,		dd	0x20000
	at tss.ss2,			dd	DATA32_SEL
	at tss.cr3,			dd	0
	at tss.eip,			dd	task2_code
	at tss.eflags,		dd	0
	at tss.eax,			dd	0
	at tss.ecx,			dd	0
	at tss.edx,			dd	0
	at tss.ebx,			dd	0
	at tss.esp,			dd	0x20000
	at tss.ebp,			dd	0
	at tss.esi,			dd	0
	at tss.edi,			dd	0
	at tss.es,			dd	DATA32_SEL
	at tss.cs,			dd	CODE32_SEL
	at tss.ss,			dd	DATA32_SEL
	at tss.ds,			dd	DATA32_SEL
	at tss.fs,			dd	DATA32_SEL
	at tss.gs,			dd	DATA32_SEL
	at tss.ldt,			dd	0
	at tss.trap,		dw	0
	at tss.iomap,		dw	0
iend

bogus_tss:	istruc	tss
	at tss.link,		dd	0
	at tss.esp0,		dd	0x20000
	at tss.ss0,			dd	DATA32_SEL
	at tss.esp1,		dd	0x20000
	at tss.ss1,			dd	DATA32_SEL
	at tss.esp2,		dd	0x20000
	at tss.ss2,			dd	DATA32_SEL
	at tss.cr3,			dd	0
	at tss.eip,			dd	scheduler
	at tss.eflags,		dd	0
	at tss.eax,			dd	0
	at tss.ecx,			dd	0
	at tss.edx,			dd	0
	at tss.ebx,			dd	0
	at tss.esp,			dd	0x20000
	at tss.ebp,			dd	0
	at tss.esi,			dd	0
	at tss.edi,			dd	0
	at tss.es,			dd	DATA32_SEL
	at tss.cs,			dd	CODE32_SEL
	at tss.ss,			dd	DATA32_SEL
	at tss.ds,			dd	DATA32_SEL
	at tss.fs,			dd	DATA32_SEL
	at tss.gs,			dd	DATA32_SEL
	at tss.ldt,			dd	0
	at tss.trap,		dw	0
	at tss.iomap,		dw	0
iend

desc:			dd		0, 0

tmp1:			dd		0
