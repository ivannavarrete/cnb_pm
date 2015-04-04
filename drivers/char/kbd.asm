
; keyboard driver

%include "driver.h"
%include "debug.h"
%include "config.h"
%include "sysdef.h"
%include "descriptor.h"


global driver_init


	section .text

;=== driver_init ===============================================================
driver_init:
	push	dword 0
	push	dword kbd_read
	push	dword 1
	call	request_irq

	push	dword 1
	call	enable_irq
	ret


;=== driver_cleanup ============================================================
driver_cleanup:
	push	dword 0x21
	call	release_irq
	ret


;=== kbd_read ==================================================================
kbd_read:
	pushad
	push	ds, es
	
	mov		bx, DATA32_SEL
	mov		ds, bx
	mov		ebx, scan_codes
	in		al, 0x60
	xlatb

	DEBUG1	VIDEO_SEL, 40, al

	mov		al, 0x20
	out		0x20, al
	
	pop		ds, es
	popad
	iret


	section .data
scan_codes:		db		0x00, 0x1B, "1" , "2" , "3" , "4" , "5" , "6"
				db		"7" , "8" , "9" , "0" , "+" , "'" , 0x7F, 0x09
				db		"q" , "w" , "e" , "r" , "t" , "y" , "u" , "i"
				db		"o" , "p" , "}" , 0x00, 0x0A, 0x00, "a" , "s"
				db		"d" , "f" , "g" , "h" , "j" , "k" , "l" , "|"
				db		"{" , 0x00, 0x00, "'" , "z" , "x" , "c" , "v"
				db		"b" , "n" , "m" , "," , "." , "-" , 0x00, "*"
				db		0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
				db		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
				db		0x00, 0x00, "-" , 0x00, 0x00, 0x00, "+" , 0x00
				db		0x00, 0x00, 0x00, 0x00
