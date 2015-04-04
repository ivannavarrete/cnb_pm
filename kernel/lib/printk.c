
/* Routines for kernel output. All output to console in the kernel should be
 * through this module (except for the console 'driver' and debug macros).
 *
 * XXX This is to slow for kernel. Many times we do output in interrupt and
 * exception handlers as well as in time critical kernel sections. There
 * should be an alternative output mechanism for kernel, probably something
 * like the BSD message buffer. */


extern void ConsoleWrite(const char *str);


int Printk(const char *str) {
	ConsoleWrite(str);

	return 0;
}

/* Convert byte to ASCII. Make sure buf is at least 2 bytes. */
char *Hex2Asc(char *buf, int b) {
	buf[0] = ((b >> 4) & 0x0F) + 0x30;
	if (buf[0] > '9') buf[0] += 7;

	buf[1] = (b & 0x0F) + 0x30;
	if (buf[1] > '9') buf[1] += 7;

	return buf;
}


/* Print byte. */
void PrintB(int b) {
	char buf[3];

	buf[2] = 0;
	Printk(Hex2Asc(buf, b));
}


/* Print word. */
void PrintW(int w) {
	PrintB(w>>8);
	PrintB(w);
}


/* Print doubleword. */
void PrintD(int d) {
	PrintW(d>>16);
	PrintW(d);
}
