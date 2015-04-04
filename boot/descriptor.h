
;	code descriotor
; +---------------------------------------------------+
; | G |	D |	0 |	AVL| h_size| P |DPL |S |D/C| C |R |	A |
; +---------------------------------------------------+
;
;	data descriptor
; +---------------------------------------------------+
; | G |	B |	0 |	AVL| h_size| P |DPL |S |D/C| E |W |	A |
; +---------------------------------------------------+
;

D_CODE		equ	0000000010011000b
D_DATA		equ	0000000010010000b
D_INT16		equ 1000011000000000b
D_INT32		equ 1000111000000000b

D_CODESEG	equ	0000000000001000b
D_DATASEG	equ	0000000000000000b

D_GRANB		equ	0000000000000000b
D_GRANP		equ	1000000000000000b

D_SYSSEG	equ	0000000000000000b
D_USERSEG	equ	0000000000010000b

D_DPL3		equ	0000000001100000b
D_DPL2		equ	0000000001000000b
D_DPL1		equ	0000000000100000b
D_DPL0		equ	0000000000000000b

D_OP16		equ	0000000000000000b
D_OP32		equ	0100000000000000b

D_CREAD		equ	0000000000000010b		; code segments only
D_DWRITE	equ	0000000000000010b		; data/stack segments only

; macro for creating descriptors
;	desc	limit, base, flags
%macro desc 3
	dw	%1
	dw	%2
	db	(%2) >> 16
	dw	(((%1) >> 16) << 8) + (%3) 
	db	(%2) >> 24
%endm

; macro for creating gate descriptors
;	gate	segselector, offset, flags
%macro gate 3
	dw	%2
	dw	%1
	dw	%3
	dw	(%2) >> 16
%endm
