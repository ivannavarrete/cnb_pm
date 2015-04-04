/*
 * Basic console output. All output to console in the kernel should be through
 * this module (except for the console driver and debug macros of course).
 * PrintB/W/D() are here until correcto formatting conversion is implemented
 * in Printk().
 */

/*#include <stdio.h>*/

extern void ConsoleWrite(const char *str);

int Printk(const char *str);
char *Hex2Asc(char *buf, int b);
void PrintB(int b);
void PrintW(int w);
void PrintD(int d);

/*
int main(void) {
	Printk("test\x0A");
	PrintB(0x55);
	PrintB(0xAA);
	PrintW(0xEE11);
	PrintD(0x11223344);

	return 0;
}
*/


/* This should be a printf equivalent and not just a ConsoleWrite() wrapper. */
int Printk(const char *str) {
	ConsoleWrite(str);
	/*printf(str);*/

	return 0;
}


/* Convert byte to ASCII. */
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
