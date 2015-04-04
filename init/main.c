/* this function is called from the setup code and never returns. */


void kernel_init() {
	asm ("pushw		%ds");
	asm	("movw		$0x20, %ax");
	asm	("mov		%ax, %ds");
	asm ("movw		$0x0436, 0x0C");
	asm ("popw		%ds");
halt:
	goto halt;
}
