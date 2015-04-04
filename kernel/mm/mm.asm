
%include "debug.h"
%include "config.h"


global InitMM


	BITS 32

	section .text
InitMM:
	DEBUG	VIDEO_SEL, 21, 1
	ret


	section .data
