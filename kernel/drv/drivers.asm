
%define _DRIVER_C
%include "driver.h"


global register_driver
global unregister_driver


	section .text
;=== register_driver ===========================================================
; int register_driver(int major, const char *name, struct ops *ops)
;===============================================================================
register_driver:
.major:			equ	0x08
.name:			equ	0x0C
.ops:			equ	0x10

	enter	0, 0

	; check if major is valid
	mov		eax, [ebp+.major]
	cmp		eax, 0
	je		.exitf
	cmp		eax, MAX_MAJOR
	ja		.exitf

	; find an empty entry in driver table
	mov		ecx, MAX_DRIVERS
.find1:
	mov		esi, driver_table
	cmp		word [esi+driver.major], 0
	je		.found1
	add		esi, DRIVER_SS
	loop	.find1
	jmp		.exitf
.found1:

	; check if an entry already exists with this major and name
	mov		edi, driver_list
	mov		ebx, [ebp+.name]
.find2:
	cmp		[edi+driver.major], eax
	je		.exitf

	cmp		dword [edi+driver.next], 0
	je		.found2
	mov		edi, [edi+driver.next]
	jmp		.find2
.found2:

	; insert driver into table and list
	mov		[esi+driver.major], eax
	; name
	; init
	; cleanup
	mov		eax, [ebp+.ops]
	mov		[esi+driver.ops], eax
	mov		eax, [edi+driver.next]	; insert into list
	mov		[edi+driver.next], esi
	mov		[esi+driver.next], eax

	

.exitf:
	mov		eax, -1
	leave
	ret		0xC


;=== unregister_driver =========================================================
; int unregister_driver(int major, const char *name)
;===============================================================================
unregister_driver:
.major:			equ	0x08
.name:			equ	0x0C

	enter	0, 0



	leave
	ret		8


	section .data
; root driver structure (dummy)
driver_list:	istruc driver
	at driver.major,	dw 0
	at driver.name,		db 0,0,0,0,0,0,0,0,0,0 
	at driver.init,		dd 0
	at driver.cleanup,	dd 0
	at driver.ops,		dd 0
	at driver.next,		dd 0
iend

; table of driver structures
driver_table:
%rep MAX_DRIVERS
istruc driver
	at driver.major,	dw 0
	at driver.name,		db 0,0,0,0,0,0,0,0,0,0 
	at driver.init,		dd 0
	at driver.cleanup,	dd 0
	at driver.ops,		dd 0
	at driver.next,		dd 0
iend
%endrep
