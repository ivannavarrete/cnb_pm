
%ifndef SCHED_H
%define SCHED_H


%define MAX_TASKS	10


; mandatory part of the Task State Segment
struc tss
	.link		resw	2
	.esp0		resd	1
	.ss0		resw	2
	.esp1		resd	1
	.ss1		resw	2
	.esp2		resd	1
	.ss2		resw	2
	.cr3		resd	1
	.eip		resd	1
	.eflags		resd	1
	.eax		resd	1
	.ecx		resd	1
	.edx		resd	1
	.ebx		resd	1
	.esp		resd	1
	.ebp		resd	1
	.esi		resd	1
	.edi		resd	1
	.es			resw	2
	.cs			resw	2
	.ss			resw	2
	.ds			resw	2
	.fs			resw	2
	.gs			resw	2
	.ldt		resw	2
	.trap		resw	1
	.iomap		resw	1
endstruc


%endif
