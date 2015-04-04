
%ifndef DEBUG_H
%define DEBUG_H


; First argument is the video seg, second is the offset in seg, third is the
; value to be printed.
%macro DEBUG 3.nolist
	mov		bx, (%1)
	mov		es, bx
	mov		bx, (%2)*2
	mov		word [es:bx], 0x0430+(%3)
%endmacro


; print value in al
%macro DEBUG1 3.nolist
	mov		bx, (%1)
	mov		es, bx
	mov		bx, (%2)*2
	mov		ah, 0x07
	mov		[es:bx], ax
%endmacro


%endif
