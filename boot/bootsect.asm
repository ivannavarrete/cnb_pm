; Bootsector is responsible for loading and passing control to the os setup
; code.

%include "config.h"
%include "debug.h"


	bits 16
	org 0

	section .text
start:
; load os loader into memory
	mov		si, 4
read:
	xor		ah, ah						; reset disc controller
	xor		dl, dl						; floppy only
	int		0x13

	mov		ax, 0x020F					; read 15 sectors
	mov		cx, 0x0002					; start at sector 2
	xor		dx, dx						; drive 0 (floppy) head 0
	mov		bx, SETUP_ADDR>>4
	mov		es, bx
	xor		bx, bx
	int		0x13
	jnc		ok
	dec		si
	jnz		read
	jmp		halt

; pass control to os setup code
ok:
	jmp		SETUP_ADDR>>4:0

; halt system, reboot to recover
halt:
	jmp		$

; zero rest of sector and set bsector mark
end:		times 510-($-$$) db 0
			dw 0xAA55
