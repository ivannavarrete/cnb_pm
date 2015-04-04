
; This is the code to setup a default IDT and the default handlers. They are
; replaced later in the different subsystems by the real handlers. All handlers
; assume that the DATA32 seg descriptor is valid and also that the stack is
; properly setup.
; Remember, these are default minimal handlers used for debugging and such,
; and not to repair any problems.
;
; XXX: maybe I should write the real handlers in here directly instead of
; later in the subsystems. Or maybe not.
;
; XXX: should I have saved the timer interrupt handler vector from the
; real mode IVT and set the new irq0 vector to point there? In other
; words reuse the BIOS(?) timer interrupt handler. Come to think of it, why
; not do it with all the BIOS irq handlers?


%include "config.h"
%include "irq.h"
%include "descriptor.h"


extern Halt
extern Printk
extern PrintW
extern PrintD

extern DumpGDT

global InitIDT:function


	section .text

start:							; used for address calculation in gates in IDT

;===[ InitIDT ]=================================================================
; Adjust the IDT gate addresses and copy IDT to final position
;===============================================================================
InitIDT:
	push	eax, ecx, esi, edi, es

	; patch gates to use the right addresses
	mov		eax, start
	mov		ecx, idt_size/8		; ecx = number of entries to patch
	mov		esi, idt_start
.patch:
	add		[esi], ax			; XXX: overflow should never happen, right?
	ror		eax, 16
	add		[esi+6], ax
	ror		eax, 16
	add		esi, 8
	loop	.patch

	; copy IDT to final position IDT_ADDR (currently 0x00000000)
	mov		di, IDT_SEL
	mov		es, di
	xor		edi, edi
	mov		esi, idt_start
	mov		ecx, idt_size/4
	rep		movsd

	; load IDTR and enable interrupts
	lidt	[idtr]
	sti

	push	dword init_idt_str
	call	Printk

	pop		eax, ecx, esi, edi, es
	ret


;===[ DivByZeroEx ]==[ fault ]==================================================
; * Division by 0 when executing div or idiv instructions.
;===============================================================================
	section	.data
div_by_zero_ex_str:		db	'[Divide By Zero Exception]', 0x0A, 0
	section	.text
DivByZeroEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword div_by_zero_ex_str
	call	Printk

	jmp		Halt


;===[ DebugEx ]=================================================================
; * [ fault ]
;
; * [ trap ]
;
; * [ fault ]
;
; * [ trap ]
;
; * [ trap ]
;
;===============================================================================
	section .data
debug_ex_str:			db	'[Debug Exception]', 0
dr_0:					db	0x0A, 'dr0: ', 0
dr_1:					db	0x0A, 'dr1: ', 0
dr_2:					db	0x0A, 'dr2: ', 0
dr_3:					db	0x0A, 'dr3: ', 0
dr_4:					db	0x0A, 'dr4: ', 0
dr_5:					db	0x0A, 'dr5: ', 0
dr_6:					db	0x0A, 'dr6: ', 0
dr_7:					db	0x0A, 'dr7: ', 0
	section	.text
DebugEx:
	mov		ax, DATA32_SEL
	mov		ds, ax

	push	dword debug_ex_str
	call	Printk

	push	dword dr_0
	call	Printk
	mov		eax, dr0
	push	eax
	call	PrintD

	push	dword dr_1
	call	Printk
	mov		eax, dr1
	push	eax
	call	PrintD

	push	dword dr_2
	call	Printk
	mov		eax, dr2
	push	eax
	call	PrintD

	push	dword dr_3
	call	Printk
	mov		eax, dr3
	push	eax
	call	PrintD

	push	dword dr_4
	call	Printk
	mov		eax, dr4
	push	eax
	call	PrintD

	push	dword dr_5
	call	Printk
	mov		eax, dr5
	push	eax
	call	PrintD

	push	dword dr_6
	call	Printk
	mov		eax, dr6
	push	eax
	call	PrintD

	push	dword dr_7
	call	Printk
	mov		eax, dr7
	push	eax
	call	PrintD

	jmp		Halt


;===[ NMI ]==[ trap ]===========================================================
; * NMI input line is detected active. Used to report catastrophic hardware
;	failures.
;===============================================================================
	section .data
nmi_str:				db	'[Non-Maskable Interrupt] - ', 0
nmi_watchdog_str:		db	'watchdog', 0x0A, 0
nmi_mem_parity_err_str:	db	'memory parity error', 0x0A, 0
nmi_io_check_err_str:	db	'io check error', 0x0A, 0
nmi_unknown_err_str:	db	'unknown error', 0x0A, 0
	section .text
NMI:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword nmi_str
	call	Printk

	; XXX: here we should poll the various external hardware that are
	; capable of generating an NMI, and output an appropriate error
	; message. This code is taken from linux traps.c; needs to be
	; examined/rewritten properly.
	in		al, 0x61
	cmp		al, 0xC0
	je		.watchdog
	cmp		al, 0x80
	je		.mem_parity_err
	cmp		al, 0x40
	je		.io_check_err

.unknown:
	push	dword nmi_unknown_err_str
	call	Printk
	jmp		.exit

.watchdog:
	push	dword nmi_watchdog_str
	call	Printk
	jmp		.exit

.mem_parity_err:
	push	dword nmi_mem_parity_err_str
	call	Printk
	jmp		.exit

.io_check_err:
	push	dword nmi_io_check_err_str
	call	Printk

	; XXX: examine whether the halt instruction really halts the CPU
.exit:
	; reassert NMI in case it became active, as it's edge-triggered
	mov		al, 0x8F
	out		0x70, al
	in		al, 0x71			; dummy

	mov		al, 0x0F
	out		0x70, al
	in		al, 0x71			; dummy

	cli							; disable maskable external interrupts
	halt						; stop fetching and executing instructions

	jmp		Halt				; never reached


;===[ Int3Ex ]== [ trap ]=======================================================
; * int3 instruction executed.
;===============================================================================
	section .data
int3_ex_str:			db	'[Int3 Instruction Exception]', 0x0A, 0
	section .text
Int3Ex:
	push	eax, ds

	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword int3_ex_str
	call	Printk

	pop		eax, ds
	iret


;===[ OverflowEx ]==[ trap ]====================================================
; * Execution of into instruction if Eflags[OF]=1.
;===============================================================================
	section .data
overflow_ex_str:		db	'[Overflow Exception]', 0x0A, 0
	section .text
OverflowEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword overflow_ex_str
	call	Printk
	jmp		Halt


;===[ BoundsEx ]==[ fault ]=====================================================
; * Execution of bounds instruction when the specified array idx is not within
;   the bounds of the specified memory array.
;===============================================================================
	section .data
bounds_ex_str:			db	'[Bounds Exception]', 0x0A, 0
	section .text
BoundsEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword bounds_ex_str
	call	Printk
	jmp		Halt


;===[ InvalidOpCodeEx ]==[ fault ]==============================================
; * Invalid opcode.
; * Invalid operand.
;===============================================================================
	section .data
invalid_opcode_ex_str:	db	'[Invalid Opcode Exception]', 0x0A, 0
	section .text
InvalidOpCodeEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword invalid_opcode_ex_str
	call	Printk
	jmp		Halt


;===[ DevNotAvailEx ]==[ fault ]================================================
; * FPU not present (CR0[EM]=1) and FPU instruction encountered (used for FPU
;   emulation).
; * FPU instruction encountered while FPU is present (CR0[MP=1) and a task
;   switch has occurred (CR0[TS]=1). Iow, the FPU is about to execute an
;   instruction associated with another task and a task switch has occurred.
;===============================================================================
	section .data
dev_not_avail_ex_str:	db	'[Device Not Available Exception]', 0x0A, 0
	section .text
DevNotAvailEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword dev_not_avail_ex_str
	call	Printk
	jmp		Halt


;===[ DoubleFaultEx ]==[ abort ]================================================
; * The CPU has encountered a fault while attempting to call an exception
;   handler for a previously encountered fault.
;===============================================================================
	section .data
double_fault_ex_str:	db	'[Double Fault Exception]', 0x0A, 0
	section .text
DoubleFaultEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword double_fault_ex_str
	call	Printk
	jmp		Halt


;===[ CopSegOverrunEx ]==[ abort ]==============================================
; XXX
;===============================================================================
	section .data
cop_seg_ovr_ex_str:		db	'[Coprocessor Segment Overrun Exception]', 0x0A, 0
	section .text
CopSegOverrunEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword cop_seg_ovr_ex_str
	call	Printk
	jmp		Halt


;===[ InvalidTSSEx ]==[ fault ]=================================================
; * Task switch attempted to a task with an invalid TSS.
;===============================================================================
	section .data
invalid_tss_ex_str:		db	'[Invalid TSS Exception]', 0x0A, 0
	section .text
InvalidTSSEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword invalid_tss_ex_str
	call	Printk
	jmp		Halt


;===[ SegNotPresentEx ]==[ fault ]==============================================
; * Selected segment selector (cs, ds, es, fs, gs) has it's present bit
;   cleared in the corresponding descriptor, i.e. segment is not present.
;===============================================================================
	section .data
seg_not_pres_ex_str:	db	'[Segment Not Present Exception]', 0x0A, 0
	section .text
SegNotPresentEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword seg_not_pres_ex_str
	call	Printk
	jmp		Halt


;===[ StackEx ]==[ fault ]======================================================
; * Attempt to load ss with selector for a descriptor marked not present.
; * Stack overflow or underflow.
;===============================================================================
	section .data
stack_ex_str:			db	'[Stack Exception]', 0x0A, 0
	section .text
StackEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword stack_ex_str
	call	Printk
	jmp		Halt


;===[ GeneralProtEx ]==[ fault/trap ]===========================================
; * All protection violations that don't cause another exception cause a GPE.
;===============================================================================
	section .data
general_prot_ex_str:	db	0x0A, '[General Protection Exception]', 0x0A, 0
eax_str:				db	'eax: ', 0
ebx_str:				db	'    ebx: ', 0
ecx_str:				db	'    ecx: ', 0
edx_str:				db	'    edx: ', 0
esi_str:				db	0x0A, 'esi: ', 0
edi_str:				db	'    edi: ', 0
ebp_str:				db	'    ebp: ', 0
esp_str:				db	'    esp: ', 0
cs_str:					db	0x0A, 'cs: ', 0
ds_str:					db	'    ds: ', 0
es_str:					db	'    es: ', 0
fs_str:					db	'    fs: ', 0
gs_str:					db	'    gs: ', 0
ss_str:					db	'    ss: ', 0
eflags_str:				db	0x0A, 'eflags: ', 0

err_code_str:			db	0x0A, 'error code: ', 0
addr_str:				db	0x0A, 'addr: ', 0

idtr_str:				db	0x0A, 0x0A, 'IDTR: ', 0
gdtr_str:				db	0x0A, 0x0A, 'GDTR: ', 0
ldtr_str:				db	'LDTR: ', 0

dtr:					dw	0, 0, 0

nl:						db	0x0A, 0
space:					db	' ', 0
colon:					db	':', 0

eax_reg:				dd	0
ebx_reg:				dd	0
ecx_reg:				dd	0
edx_reg:				dd	0
esi_reg:				dd	0
edi_reg:				dd	0
ebp_reg:				dd	0
esp_reg:				dd	0
cs_reg:					dw	0
ds_reg:					dw	0
es_reg:					dw	0
fs_reg:					dw	0
gs_reg:					dw	0
ss_reg:					dw	0
eflags_reg:				dd	0

err_code:				dd	0

	section .text
GeneralProtEx:
; variables on stack upon enter
.err_code:				equ	0x00
.eip:					equ	0x04
.cs:					equ	0x08
.eflags:				equ	0x0C
.old_esp:				equ	0x10
.old_ss:				equ	0x14

	; first thing to do is to save all registers and such (except for cs, eip
	; and eflags since they are on the stack) so that we don't display false
	; values later.. we have to assume that the stack is valid, if it's not
	; then it's basically game over

	; we have to do some magic when pushing seg registers it seems
	; pushing a seg register causes the esp to decrease by four, popping it
	; into ax causes esp to increase by 2.. this is major weirdness
	push	ax
	push	ds
	push	es					; pushing a seg register decs esp by four
	mov		ax, DATA32_SEL
	mov		ds, ax
	pop		es
	mov		[es_reg], es
	pop		es
	mov		[ds_reg], es
	pop		ax
	
	mov		[eax_reg], eax
	mov		[ebx_reg], ebx
	mov		[ecx_reg], ecx
	mov		[edx_reg], edx
	mov		[esi_reg], esi
	mov		[edi_reg], edi
	mov		[ebp_reg], ebp
	mov		[esp_reg], esp
	mov		[fs_reg], fs
	mov		[gs_reg], gs
	mov		[ss_reg], ss
	
	;pushf
	;pop		eax
	;mov		[eflags_reg], eax		; this is eflags inside the handler

	push	dword general_prot_ex_str
	call	Printk

	; display registers
	push	dword eax_str
	call	Printk
	push	dword [eax_reg]
	call	PrintD

	push	dword ebx_str
	call	Printk
	push	dword [ebx_reg]
	call	PrintD

	push	dword ecx_str
	call	Printk
	push	dword [ecx_reg]
	call	PrintD

	push	dword edx_str
	call	Printk
	push	dword [edx_reg]
	call	PrintD

	push	dword esi_str
	call	Printk
	push	dword [esi_reg]
	call	PrintD

	push	dword edi_str
	call	Printk
	push	dword [edi_reg]
	call	PrintD

	push	dword ebp_str
	call	Printk
	push	dword [ebp_reg]
	call	PrintD

	push	dword esp_str
	call	Printk
	push	dword [esp_reg]
	call	PrintD

	push	dword cs_str
	call	Printk
	push	dword [esp+.cs]
	call	PrintW

	push	dword ds_str
	call	Printk
	push	dword [ds_reg]
	call	PrintW

	push	dword es_str
	call	Printk
	push	dword [es_reg]
	call	PrintW

	push	dword fs_str
	call	Printk
	push	dword [fs_reg]
	call	PrintW

	push	dword gs_str
	call	Printk
	push	dword [gs_reg]
	call	PrintW

	push	dword ss_str
	call	Printk
	push	dword [ss_reg]
	call	PrintW

	push	dword eflags_str
	call	Printk
	push	dword [esp+.eflags]
	call	PrintD
	;push	dword [eflags_reg]
	;call	PrintD

	; display error code
	push	dword err_code_str
	call	Printk
	push	dword [esp+.err_code]
	call	PrintD

	; display addr of the instruction that caused the exception
	push	dword addr_str
	call	Printk
	push	dword [esp+.cs]
	call	PrintW
	push	dword colon
	call	Printk
	push	dword [esp+.eip]
	call	PrintD

	; display IDT


	; display GDT
	push	dword 10
	push	dword 0
	call	DumpGDT

	; force cpu to shutdown by zeroing the IDT and causing an exception
	;mov		ax, IDT_SEL
	;mov		es, ax
	;xor		edi, edi
	;xor		eax, eax
	;mov		ecx, IDT_LIMIT/4
	;rep		stosd

	;mov		ax, 0xFFFF
	;mov		ds, ax
	
	
	jmp		Halt


;===[ PageFaultEx ]==[ fault ]==================================================
; * Page table or page is not present in memory.
; * Current program's CPL has insufficient priviledge to access the page.
;===============================================================================
	section .data
page_fault_ex_str:		db	'[Page Fault Exception]', 0x0A, 0
	section .text
PageFaultEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword page_fault_ex_str
	call	Printk
	jmp		Halt


;===[ FPErrorEx ]==[ fault ]====================================================
; * Error generated by FPU when attempting to exec a FP math instruction.
;   Only occurs when CR0[NE]=1.
;===============================================================================
	section .data
fp_error_ex_str:		db	'[Floating Point Error Exception]', 0x0A, 0
	section .text
FPErrorEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword fp_error_ex_str
	call	Printk
	jmp		Halt


;===[ AlignCheckEx ]==[ fault ]=================================================
; * Occurs when misaligned transfer is attempted and alignment checking is
;   enabled (CR0[AM]=1, EFlags[AC]=1, CPL=3).
;===============================================================================
	section .data
align_check_ex_str:		db	'[Alignment Check Exception]', 0x0A, 0
	section .text
AlignCheckEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword align_check_ex_str
	call	Printk
	jmp		Halt


;===[ MachineCheckEx ]==[ abort ]===============================================
; * May or may not be implemented on a given processor. Cause is processor
;   model specific.
;===============================================================================
	section .data
machine_check_ex_str:	db	'[Machine Check Exception]', 0x0A, 0
	section .text
MachineCheckEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword machine_check_ex_str
	call	Printk
	jmp		Halt


;===[ UnknownEx ]===============================================================
; This exception handler is installed for vectors 19-31. These vectors are
; reserved by intel, presumably for future exceptions.
;===============================================================================
	section .data
unknown_ex_str:			db	'[Unknown Exception]', 0x0A, 0
	section .text
UnknownEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword unknown_ex_str
	call	Printk
	jmp		Halt


;===[ DefInt ]==================================================================
; Default dummy interrupt handler.
;===============================================================================
	section .data
def_int_str:			db	'[Default Interrupt Handler]', 0x0A, 0
	section .text
DefInt:
	push	eax, ds

	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword def_int_str
	call	Printk

	; send EOI
	mov		al, 0x20
	out		0x20, al

.exit:
	pop		eax, ds
	iret



	section .data
init_idt_str:	db	'IDT initialized', 0x0A, 0

;===[ Interrupt Descriptor Table ]===
idtr:			dw	IDT_LIMIT, IDT_ADDR, IDT_ADDR>>16

idt_start:
	; exception handlers
	gate CODE32_SEL, DivByZeroEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, DebugEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, NMI-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, Int3Ex-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, OverflowEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, BoundsEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, InvalidOpCodeEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, DevNotAvailEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, DoubleFaultEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, CopSegOverrunEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, InvalidTSSEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, SegNotPresentEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, StackEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, GeneralProtEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, PageFaultEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, DefInt-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, FPErrorEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, AlignCheckEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, MachineCheckEx-start, D_IGATE32 | D_DPL0
	; The rest, up to 0x1F are reserved by intel.
	%rep IRQ_BASE-19
	gate CODE32_SEL, DefInt-start, D_IGATE32 | D_DPL0
	%endrep
	; hardware interrupt handlers
	%rep MAX_IRQ
	gate CODE32_SEL, DefInt-start, D_IGATE32 | D_DPL0
	%endrep
	; the rest is software interrupt handlers
idt_end:

idt_size	equ idt_end-idt_start
