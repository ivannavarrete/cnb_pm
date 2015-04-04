
	bits 32
	org	0x0

	segment .text
	db		'hahahaha hohohoho hihihihi hehehehe'
	db		'random crap in order to find out whether int 13 really works'
	db		' and to find a solution to the intersegment jumps'
kernel_start:
	jmp		kernel_start
