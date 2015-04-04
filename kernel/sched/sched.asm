
%include "sched.h"
%include "config.h"
%include "debug.h"


extern RequestIRQ
extern EnableIRQ
extern Printk
global InitSched


	BITS 32

	section .text
;=== InitSched =================================================================
;
;===============================================================================
InitSched:
	; initialize first entry in tss_table to point to TaskSched
	mov		dword [tss_table+tss.esp0], 0x20000	; these are random values..
	mov		dword [tss_table+tss.esp1], 0x21000	; not very good..
	mov		dword [tss_table+tss.esp2], 0x22000
	mov		dword [tss_table+tss.eip], TaskSched
	pushfd
	pop		eax
	mov		[tss_table+tss.eflags], eax

	; program 8253 PIT chan 0 to 100Hz
	mov		al, 0x34
	out		0x43, al
	mov		al, 0x9B
	out		0x40, al
	mov		al, 0x2E
	out		0x40, al

	; install sheduler at irq0
	push	dword 0
	push	dword TaskSched
	push	dword 0
	call	RequestIRQ				; probably need a task gate instead of TRG

	or		eax, eax
	jz		.10
	push	dword init_sched_err
	call	Printk

.10:
	; enable irq0
	push	dword 0
	call	EnableIRQ
	
	push	dword init_sched_str
	call	Printk

	ret


;=== TaskSched =================================================================
; Task scheduler, installed as handler for irq0 (timer). Currently uses
; timeslicing and rotates through all tasks. Nothing fancy.
;===============================================================================
TaskSched:
	;push	eax

	; EOI
	DEBUG	VIDEO_SEL, 60, 0
	mov		al, 0x20
	out		0x20, al

	; go to next task in task list
	;inc		byte [current_task]
	;cmp		byte [current_task], MAX_TASKS
	;jb		.run_task
	;mov		byte [current_task], 1

.run_task:
	;mov		eax, [current_task]
	;call	8<<3:0

	;pop		eax
	iret


;=== Task1 =====================================================================
; Program for testing task switching.
;===============================================================================
Task1:
	DEBUG	VIDEO_SEL, 50, 1
	mov		ecx, 0xFFFFF
	loop	$

	DEBUG	VIDEO_SEL, 50, 2
	mov		ecx, 0xFFFFF
	loop	$

	jmp		Task1


;=== Task2 =====================================================================
; Program for testing task switching.
;===============================================================================
Task2:
	DEBUG	VIDEO_SEL, 53, 3
	mov		ecx, 0xFFFFF
	loop	$

	DEBUG	VIDEO_SEL, 53, 4
	mov		ecx, 0xFFFFF
	loop	$

	jmp		Task2



	section .data
init_sched_str:		db	'Task Scheduler initialized', 0x0A, 0
init_sched_err:		db	'Error initializing Task Scheduler', 0x0A, 0

current_task:		db	0

; Reserve memory for MAX_TASKS Task State Segments. TSS0 is for OS, the rest
; for user programs.
tss_table:
%rep MAX_TASKS
istruc	tss
	at tss.link,	dd	0
	at tss.esp0,	dd	0
	at tss.ss0,		dd	DATA32_SEL
	at tss.esp1,	dd	0
	at tss.ss1,		dd	DATA32_SEL
	at tss.esp2,	dd	0
	at tss.ss2,		dd	DATA32_SEL
	at tss.cr3,		dd	0
	at tss.eip,		dd	0
	at tss.eflags,	dd	0
	at tss.eax,		dd	0
	at tss.ecx,		dd	0
	at tss.edx,		dd	0
	at tss.ebx,		dd	0
	at tss.esp,		dd	0
	at tss.ebp,		dd	0
	at tss.esi,		dd	0
	at tss.edi,		dd	0
	at tss.es,		dd	DATA32_SEL
	at tss.cs,		dd	CODE32_SEL
	at tss.ss,		dd	DATA32_SEL
	at tss.ds,		dd	DATA32_SEL
	at tss.fs,		dd	DATA32_SEL
	at tss.gs,		dd	DATA32_SEL
	at tss.ldt,		dd	0
	at tss.trap,	dw	0
	at tss.iomap,	dw	0
iend
%endrep
