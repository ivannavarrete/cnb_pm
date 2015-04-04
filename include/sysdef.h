
%ifndef SYSDEF_H
%define SYSDEF_H


%define RPL0		0x0000
%define RPL1		0x0001
%define RPL2		0x0002
%define RPL3		0x0003

%define GDT			0
%define LDT			1
%define IDT			2

%define DESC		0
%define GATE		1



;%macro push 2-*.nolist
;%rep %0
;	push	%1
;%rotate 1
;%endrep
;%endmacro


;%macro pop 2-*.nolist
;%rep %0
;%rotate -1
;	pop		%1
;%endrep
;%endmacro


%endif
