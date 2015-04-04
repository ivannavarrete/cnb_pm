
%ifndef DEBUG_H
%define DEBUG_H


; These macros are primarily for use in the early stages of system setup.
; The only assumption is that the video segment is properly setup.


; Print a number between 0 and 9. Beware, the macro changes es and bx.
; To preserve es, set the fourth parameter the desired value.
; (%1) = video segment
; (%2) = offset in video segment
; (%3) = number (0-9) to print
; (%4) = the selector to set es to at the end
%macro DEBUG 4.nolist
	mov		bx, (%1)
	mov		es, bx
	mov		bx, (%2)*2
	mov		word [es:bx], 0x0430+(%3)		; red color

	mov		bx, (%4)
	mov		es, bx
%endmacro


; Print the value in al. Beware, the macro changes es, bx and ah.
; (%1) = video segment
; (%2) = offset in video segment
%macro DEBUG1 2.nolist
	mov		bx, (%1)
	mov		es, bx
	mov		bx, (%2)*2
	mov		ah, 0x07						; white color
	mov		[es:bx], ax
%endmacro


%endif
