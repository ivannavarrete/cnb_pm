
; This is the code to setup a default IDT and the default handlers. They are
; replaced later in the different subsystems by the real handlers. All handlers
; assume that the DATA32 seg descriptor is valid. Remember, these are default
; minimal handlers used for debugging and such, and not to repair any problems.


%include "config.h"
%include "descriptor.h"


extern Halt
extern Printk
extern PrintW
extern PrintD
global InitIDT


	section .text

start:							; used for address calculation in gates in IDT

;=== InitIDT ===================================================================
;
;===============================================================================
InitIDT:
	push	eax, ecx, esi, edi, es
	
	; patch gates to use right addresses
	mov		eax, start
	mov		ecx, idt_size/8
	mov		esi, idt_start
.patch:
	add		[esi], ax			; overflow should never happen, right?
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
	mov		cx, idt_size/8
	rep		movsd

	; load IDTR and enable interrupts
	lidt	[idtr]
	sti

	push	dword init_idt_str
	call	Printk

	pop		eax, ecx, esi, edi, es
	ret


;=== DivByZeroEx ===============================================================
; * Division by 0 when executing div or idiv instructions.
;===============================================================================
	section .data
div_by_zero_ex_str:		db	'[Divide By Zero Exception]', 0x0A, 0
	section .text
DivByZeroEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword div_by_zero_ex_str
	call	Printk

	jmp		Halt


;=== DebugEx ===================================================================
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
	section .text
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


;=== NMI =======================================================================
; * NMI input line is detected active. Used to report catastrophic hardware
;   failures.
;===============================================================================
	section .data
nmi_str:				db	'[Non-Maskable Interrupt]', 0x0A, 0
	section .text
NMI:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword nmi_str
	call	Printk

	cli							; disable maskable external interrupts
	halt						; stop fetching and executing instructions
	
	jmp		Halt				; never reached


;=== Int3Ex ====================================================================
; * int3 instruction executed.
;===============================================================================
	section .data
int3_ex_str:			db	'[int3 instruction exception]', 0x0A, 0
	section .text
Int3Ex:
	push	eax, ds
	
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword int3_ex_str
	call	Printk
	jmp		Halt

	pop		eax, ds
	iret

	
;=== OverflowEx ================================================================
; * Execution of into instruction if EFlags[OF]=1.
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


;=== BoundsEx ==================================================================
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


;=== InvalidOpCodeEx ===========================================================
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


;=== DevNotAvailEx =============================================================
; * FPU not present (CR0[EM]=1) and FPU instruction detected (used for FPU
;   emulation).
; * 
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


;=== DoubleFaultEx =============================================================
;
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


;=== CopSegOverrunEx ===========================================================
;
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


;=== IvalidTSSFault ============================================================
; * Task switch detected to a task with invalid TSS.
;===============================================================================
	section .data
invalid_tss_fault_str:	db	'[Invalid TSS Fault]', 0x0A, 0
	section .text
InvalidTSSFault:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword invalid_tss_fault_str
	call	Printk
	jmp		Halt


;=== SegNotPresentEx ===========================================================
; * Attempt to load cs, ds, es, fs or gs with selector for a descriptor marked
;   not present (P=0).
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


;=== StackFaultEx ==============================================================
; * Stack overflow or underflow error.
; * Attemt to load ss with selector for a descriptor marked not present (P=0).
;===============================================================================
	section .data
stack_fault_ex_str:		db	'[Stack Fault Exception]', 0x0A, 0
	section .text
StackFaultEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword stack_fault_ex_str
	call	Printk
	jmp		Halt


;=== GeneralProtEx =============================================================
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

idtr_str:				db	0x0A, 0x0A, 'IDTR: ', 0
gdtr_str:				db	0x0A, 0x0A, 'GDTR: ', 0
ldtr_str:				db	'LDTR: ', 0

dtr:					dw	0, 0, 0

nl:						db	0x0A, 0
space:					db	' ', 0

	section .text
GeneralProtEx:
	; first thing to do is to save all registers and such (fetch eip and flags
	; from stack) so that we don't display false values later
	; ...
	; not implemented: the reg values displayed below are not correct
	; ...

	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword general_prot_ex_str
	call	Printk

	; display registers
	push	dword eax_str
	call	Printk
	push	eax
	call	PrintD

	push	dword ebx_str
	call	Printk
	push	ebx
	call	PrintD
	
	push	dword ecx_str
	call	Printk
	push	ecx
	call	PrintD

	push	dword edx_str
	call	Printk
	push	edx
	call	PrintD

	push	dword esi_str
	call	Printk
	push	esi
	call	PrintD

	push	dword edi_str
	call	Printk
	push	edi
	call	PrintD

	push	dword ebp_str
	call	Printk
	push	ebp
	call	PrintD

	push	dword esp_str
	call	Printk
	push	esp
	call	PrintD

	push	dword cs_str
	call	Printk
	push	cs
	call	PrintW

	push	dword ds_str
	call	Printk
	push	ds
	call	PrintW

	push	dword es_str
	call	Printk
	push	es
	call	PrintW
	
	push	dword fs_str
	call	Printk
	push	fs
	call	PrintW

	push	dword gs_str
	call	Printk
	push	gs
	call	PrintW

	push	dword eflags_str
	call	Printk
	pushfd
	call	PrintD

	; display IDT
	push	dword idtr_str
	call	Printk
	sidt	[dtr]
	xor		eax, eax
	mov		ax, [dtr+4]
	push	eax
	call	PrintW
	mov		eax, [dtr]
	push	eax
	call	PrintD

	mov		di, IDT_SEL
	mov		es, di				; can't use ds (and lodsd) because of Print*()
	mov		edi, 32*4			; start descriptor in IDT to dump
	;mov	ecx, idt_size/4		; no space on screen to dump complete IDT
	mov		ecx, 2				; so we dump only a few descriptors
.dump_idt:
	push	dword nl
	call	Printk
	
	; OK. This is fukked up. Somehow PrintD() seems to change ecx although
	; it doesn't look that way from the code listing. Maybe something to do
	; with the fact that Print*() is C code. Or maybe I'm just stupid.
	push	ecx
	push	dword [es:edi+4]
	call	PrintD

	push	dword space
	call	Printk
	
	push	dword [es:edi]
	call	PrintD
	pop		ecx
	
	add		edi, 8
	loop	.dump_idt

	; display GDT
	push	dword gdtr_str
	call	Printk
	sgdt	[dtr]
	xor		eax, eax
	mov		ax, [dtr+4]
	push	eax
	call	PrintW
	mov		eax, [dtr]
	push	eax
	call	PrintD

	mov		di, GDT_SEL
	mov		es, di				; can't use ds (and lodsd) because of Print*()
	xor		edi, edi			; start descriptor in GDT to dump
	;mov	ecx, idt_size/4		; no space on screen to dump complete GDT
	mov		ecx, 8				; so we dump only a few descriptors
.dump_gdt:
	push	dword nl
	call	Printk

	; Same ptoblem with ecx as above
	push	ecx
	push	dword [es:edi+4]
	call	PrintD
	
	push	dword space
	call	Printk
	
	push	dword [es:edi]
	call	PrintD
	pop		ecx

	add		edi, 8
	loop	.dump_gdt

	jmp		Halt


;=== PageFaultEx ===============================================================
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


;=== FPErrorEx =================================================================
; * Attempt to exec FP math instruction when CR0[NE]=1.
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


;=== AlignCheckEx ==============================================================
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


;=== MachineCheckEx ============================================================
; * May or may not be implemented on a given processor. Cause is processor
;   model specific.
;===============================================================================
	section .data
machine_check_ex_str	db	'[Machine Check Exception]', 0x0A, 0
	section .text
MachineCheckEx:
	mov		ax, DATA32_SEL
	mov		ds, ax
	push	dword machine_check_ex_str
	call	Printk
	jmp		Halt


;=== DefInt ====================================================================
;
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

	pop		eax, ds
	iret
	

	section .data
init_idt_str:	db	'IDT initialized', 0x0A, 0

;=== Interrupt Descriptor Table ===
idtr:			dw	idt_size, IDT_ADDR, IDT_ADDR>>16

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
	gate CODE32_SEL, InvalidTSSFault-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, SegNotPresentEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, StackFaultEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, GeneralProtEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, PageFaultEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, DefInt-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, FPErrorEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, AlignCheckEx-start, D_IGATE32 | D_DPL0
	gate CODE32_SEL, MachineCheckEx-start, D_IGATE32 | D_DPL0
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
