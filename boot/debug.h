
;	seg, off, num
%macro DEBUG 3
	push	ax
	push	si
	push	gs
	
	mov		ax, %1
	mov		gs, ax
	mov		ax, %3
	add		ax, 0x0430
	mov		si, %2
	add		si, %2
	mov		word [gs:si], ax

	pop		gs
	pop		si
	pop		ax
%endm
