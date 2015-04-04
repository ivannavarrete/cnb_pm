
; This file contains macros and constants for easier nasm programming.


%ifndef NASM_H
%define NASM_H


; Multi-push macro.
;	push	eax, ebx, ...
%macro push 2-*.nolist
%rep %0
	push	%1
%rotate 1
%endrep
%endmacro


; Multi-pop macro.
;	pop		eax, ebx, ...
%macro pop 2-*.nolist
%rep %0
%rotate -1
	pop		%1
%endrep
%endmacro


%endif
