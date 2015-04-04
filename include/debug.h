
%ifndef DEBUG_H
%define DEBUG_H


; Print a number between 0 and 9. Beware, the macro changes es and bx.
; (%1) = video segment
; (%2) = offset in video segment
; (%3) = number (0-9) to print
%macro DEBUG 3.nolist
	mov		bx, (%1)
	mov		es, bx
	mov		bx, (%2)*2
	mov		word [es:bx], 0x0430+(%3)
%endmacro


; Print the value in al. Beware, the macro changes es, bx and ah.
; (%1) = video segment
; (%2) = offset in video segment
%macro DEBUG1 3.nolist
	mov		bx, (%1)
	mov		es, bx
	mov		bx, (%2)*2
	mov		ah, 0x07
	mov		[es:bx], ax
%endmacro


%endif
