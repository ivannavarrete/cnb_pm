
; NOTE: The tss_htable is not a hash table yet. The tss_list is not a list yet,
; it will be when we have dynamic allocation.
;
; NOTE: When switching to a task with a corrupt TSS the CPU freezes instead of
; generating proper exceptions (as is stated in PMSA). The CPU only catches
; errors in a corrupt TSS descriptor.


%include "sched.h"
%include "config.h"
%include "irq.h"
%include "descriptor.h"
%include "debug.h"


extern Printk
extern PrintD
extern Idle
extern Halt

extern DumpIDT
extern DumpGDT
extern DumpTSS

extern FindEntry

extern RequestIRQ
extern EnableIRQ
extern RequestDesc
extern RequestGate

global InitSched



	BITS 32

	section .text
;===[ InitSched ]===============================================================
;
;===============================================================================
InitSched:
	push	eax, ecx, edi
	
	; zero the task hash table
	mov		edi, task_htable
	mov		ecx, MAX_TASKS
	xor		eax, eax
	rep		stosd

	; create the idle task
	push	dword Idle
	call	CreateTask
	cmp		eax, -1
	jne		.5
	jmp		.err

.5:
	; load the Task Register
	shl		eax, 3
	ltr		ax

	; create the scheduler task
	push	dword TaskSched
	call	CreateTask
	mov		ecx, eax			; save for now (better to use a variable)
	cmp		eax, -1
	jne		.10
	jmp		.err
	
.10:
	; clear busy bit
	;push	es
	;mov		di, GDT_SEL
	;mov		es, di
	;mov		edi, TASK_SCHED_GDT_IDX<<3
	;and		byte [es:edi+5], 0xFD
	;pop		es

	; create two test tasks
	push	dword Task1
	call	CreateTask
	cmp		eax, -1
	jne		.20
	jmp		.err

.20:
	push	dword Task2
	call	CreateTask
	cmp		eax, -1
	jne		.30
	jmp		.err

.30:
	; program 8253 PIT chan 0 to 100Hz
	; XXX taken from cnb version 0.0.7.. check for validity
	mov		al, 0x34
	out		0x43, al
	mov		al, 0x9B
	out		0x40, al
	mov		al, 0x2E
	out		0x40, al

	; install a task gate at IRQ0 vector to point to scheduler TSS
	;push	dword D_TSGATE | D_DPL0
	;push	dword 0
	;shl		ecx, 3
	;push	ecx					; restore selector
	;;push	dword TASK_SCHED_GDT_IDX<<3
	push	dword D_IGATE32 | D_DPL0
	push	dword TaskSched
	push	dword CODE32_SEL
	
	push	dword 0
	call	RequestIRQ
	cmp		eax, -1
	je		.err

	push	dword init_sched_str
	call	Printk

	; enable irq0
	push	dword 0
	call	EnableIRQ

	push	dword 12
	push	dword 0
	call	DumpGDT

	jmp		Idle
	
	; break the TSS descriptor in various ways to see whether CPU detects it
	;mov		di, GDT_SEL
	;mov		es, di
	;mov		edi, 0x48
	;and	byte [es:edi+5], 0x7F		; clear present bit: SegNotPresentEx
	;or		byte [es:edi+5], 0x02		; set busy bit: GPException
	;mov	word [es:edi], 0x10			; small size: InvalidTSSEx
	;mov		di, DATA32_SEL
	;mov		es, di

	; break the TSS in various ways to see whether CPU detects it
	;mov		edi, task_list
	;add		edi, TSS_SIZE
	;mov		ecx, TSS_SIZE/4-1
	;mov		eax, 0x55AA
	;rep		stosd

	;jmp		$
	;jmp		TaskSched
	;jmp		0x48:0xFFFFFF

	pop		eax, ecx, edi
	ret

.err:
	push	dword init_sched_err_str
	call	Printk
	jmp		Halt


;===[ CreateTask ]==============================================================
; int CreateTask(void *addr)
;===============================================================================
CreateTask:
.addr:			equ		0x08

	enter	0, 0
	push	ecx, esi, edi, es

	; search for an empty entry in task_htable
	mov		esi, task_htable
	mov		ecx, MAX_TASKS
.search_task_htable:
	cmp		dword [esi], 0
	je		.10
	add		esi, 4
	loop	.search_task_htable
	mov		eax, -1
	jmp		.exit

.10:
	; search for a free TSS in task_list (this is later replaced with dynamic
	; allocation of a TSS)
	mov		edi, task_list
	mov		ecx, MAX_TASKS
.search_task_list:
	cmp		word [edi+tss.cs], 0			; XXX need a better check
	je		.20
	add		edi, TSS_SIZE
	loop	.search_task_list
	mov		eax, -1
	jmp		.exit

.20:
	; allocate entry in task_htable (store addr of TSS in task_htable)
	mov		[esi], edi

	; clear TSS
	mov		ecx, TSS_SIZE/4
	xor		eax, eax
	cld
	rep		stosd

	; init TSS
	mov		edi, [esi]

	call	FindEntry
	mov		[edi+tss.gdtidx], eax
	
	mov		eax, [ebp+.addr]
	mov		dword [edi+tss.eip], eax
	
	mov		eax, 0x0212						; XXX is this a sane flags value?
	mov		dword [edi+tss.eflags], eax
	
	; JESUS CHRIST!! This bug was hard to find. If we leave ss to be 0 the
	; task switch in InitSched just freezes the computer or something. It
	; should generate a stack exception or something.. very weird
	mov		dword [edi+tss.esp], esp		; XXX use a predefined kernel stack
	mov		word [edi+tss.ss], DATA32_SEL

	mov		word [edi+tss.cs], CODE32_SEL
	mov		word [edi+tss.ds], DATA32_SEL
	mov		word [edi+tss.es], DATA32_SEL
	mov		word [edi+tss.fs], DATA32_SEL
	mov		word [edi+tss.gs], DATA32_SEL

	; init a TSS descriptor and place it in the GDT.. the address of the TSS
	; must be the base address which is counted from the start of memory, not
	; the start of the current data seg, so we compensate by adding SYS_ADDR
	push	dword [edi+tss.gdtidx]
	push	dword GDT						; table
	push	dword D_TSS32 | D_GB | D_DPL0	; type/flags
	push	dword TSS_SIZE					; size
	mov		eax, [esi]
	add		eax, SYS_ADDR
	push	eax								; base addr
	call	RequestDesc
	cmp		eax, -1
	je		.exit

	mov		eax, [edi+tss.gdtidx]			; index in the GDT
.exit:
	pop		ecx, esi, edi, es
	leave
	ret		4


;===[ TaskSched ]===============================================================
;
;===============================================================================
	section .data
tmp:		dd	0
	section .text
TaskSched:
	push	esp
	call	PrintD

	; send EOI
	mov		al, 0x20
	out		0x20, al

	iret

.5:
	DEBUG	VIDEO_SEL, 49, 0, DATA32_SEL
	cmp		dword [tmp], 0x2
	ja		.10
	inc		dword [tmp]
	DEBUG	VIDEO_SEL, 60, 0, DATA32_SEL

	mov		ax, 0xff
	mov		ds, ax

	; clear busy bit
	push	es
	mov		di, GDT_SEL
	mov		es, di
	mov		edi, 0x48
	and		byte [es:edi+5], 0xFD
	pop		es
	
	;jmp		0x48:0
	jmp		.5

.10:
	cmp		dword [tmp], 0x4
	ja		.20
	inc		dword [tmp]
	DEBUG	VIDEO_SEL, 60, 1, DATA32_SEL

	; clear busy bit
	push	es
	mov		di, GDT_SEL
	mov		es, di
	mov		edi, 0x50
	and		byte [es:edi+5], 0xFD
	pop		es
	
	;jmp		0x50:0
	jmp		.10

.20:
	mov		dword [tmp], 0
	jmp		.5

	; never reached
	ret


;===[ Task1 ]===================================================================
;
;===============================================================================
Task1:
	sti

	DEBUG	VIDEO_SEL, 50, 4, DATA32_SEL
	mov		ecx, 0x8000000
	loop	$

	DEBUG	VIDEO_SEL, 50, 5, DATA32_SEL
	mov		ecx, 0x8000000
	loop	$

	;jmp		0x50:4000
	jmp		Task1


;===[ Task2 ]===================================================================
;
;===============================================================================
Task2:

	DEBUG	VIDEO_SEL, 53, 6, DATA32_SEL
	mov		ecx, 0x8000000
	loop	$

	DEBUG	VIDEO_SEL, 53, 7, DATA32_SEL
	mov		ecx, 0x8000000
	loop	$

	;jmp		0x48:0xFFFF
	jmp		Task2



	section .data
init_sched_str:		db	'Task Scheduler Initialized', 0x0A, 0
init_sched_err_str:	db	'Error Initializing Task Scheduler', 0xA, 0

current_task:		dd	0

; This table contains the addresses of the TSS
task_htable:		times MAX_TASKS dd	0

; Reserve memory for MAX_TASKS Task State Segments. TSS0 is for OS, the rest
; for user programs.
; XXX Change this to dynamic allocation later, when we have such a thing. This
; should be a linked list or something.
; XXX We use tss.cs to see whether the tss is free or taken. This is a bad
; idea which should disappear when we have dynamic allocation,
task_list:
%rep MAX_TASKS
istruc	tss
	at	tss.link,		dd	0
	at	tss.esp0,		dd	0
	at	tss.ss0,		dd	0 ;DATA32_SEL
	at	tss.esp1,		dd	0
	at	tss.ss1,		dd	0 ;DATA32_SEL
	at	tss.esp2,		dd	0
	at	tss.ss2,		dd	0 ;DATA32_SEL
	at	tss.cr3,		dd	0
	at	tss.eip,		dd	0
	at	tss.eflags,		dd	0
	at	tss.eax,		dd	0
	at	tss.ecx,		dd	0
	at	tss.edx,		dd	0
	at	tss.ebx,		dd	0
	at	tss.esp,		dd	0
	at	tss.ebp,		dd	0
	at	tss.esi,		dd	0
	at	tss.edi,		dd	0
	at	tss.es,			dd	0 ;DATA32_SEL
	at	tss.cs,			dd	0			; must be 0 to mark tss as available
	at	tss.ss,			dd	0 ; DATA32_SEL
	at	tss.ds,			dd	0 ;DATA32_SEL
	at	tss.fs,			dd	0 ;DATA32_SEL
	at	tss.gs,			dd	0 ;DATA32_SEL
	at	tss.ldt,		dd	0
	at	tss.trap,		dw	0
	at	tss.iomap,		dw	0

	at	tss.gdtidx,		dd	0
iend
%endrep
