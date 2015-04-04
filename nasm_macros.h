
%ifndef NASM_MACROS_H
%define NASM_MACROS_H


%macro push 2-*.nolist
%rep %0
	push	%1
%rotate 1
%endrep
%endmacro


%macro pop 2-*.nolist
%rep %0
%rotate -1
	pop		%1
%endrep
%endmacro


%endif
