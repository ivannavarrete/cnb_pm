
%define BOOTSEG 0x07C0
%define INITSEG 0x9000
%define VIDEOSEG 0xB800

%define STAGE0 0x0430
%define STAGE1 0x0431
%define STAGE2 0x0432
%define STAGE3 0x0433
%define STAGE4 0x0434
%define STAGE5 0x0435
%define STAGE6 0x0436
%define STAGE7 0x0437
%define STAGE8 0x0438			; 8 - halted in pmode
%define STAGE9 0x0439			; 9 - halted in real mode


;-------------------------------------------
; macro for creating segment descriptors
;-------------------------------------------
; usage:  desc limit, base, flags
;-------------------------------------------
;%macro desc 3
;	dw	%1
;	dw	%2
;	db	%2 >> 16
;	db	%3
;	db	(%3 >> 8) + (%1 >> 16)
;	db	%2 >> 24
;%endm

%macro desc 4
	dw	%1
	dw	%2
	db	%2 >> 16
	db	%3
	db	%4
	db	%2 >> 24
%endm
