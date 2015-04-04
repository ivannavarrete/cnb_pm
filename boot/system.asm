

%include "config.h"
%include "descriptor.h"
%include "debug.h"

	bits 32
	org 0x0

	section .text
system_start:
	DEBUG	4*8, 6, 6
	jmp		$









times 0x100-$+system_start db 0

;== iret fucks up for some reason
def_int:
	DEBUG	4*8, 79, 0 
	jmp		$
	;iret
