
---[ Simple Pmode Kernel ]
   [ 2003.01.13 05.14    ]
   [ Ivan Navarrete      ]---



---[ Intro ]---

Small kernel for an intel processor. Currently it does boot into kernel
and does some initialization. There is basic interrupt handling, basic
console output, and a broken task scheduler.

This text assumes a fair knowledge of intel processor architecture and
protected mode.



---[ Requirements ]---

This is the development platform I use:

Intel P4
Gentoo Linux distribution (kernel 2.4.19)
GNU Make 3.80
gcc 3.2
ld 2.13.90.0.16
nasm 0.98.34



---[ Description ]---

Let's begin by describing the different parts of the kernel. This is just
an overview. For more details read the source. It is commented and not
that big.


[boot/bootsector.asm]
  Load kernel setup code from floppy (sectors 2-16).
  Pass control to kernel setup code.


[boot/setup.asm boot/gdt.asm]
  Load the kernel into memory.
  Enable address line 20.
  Initialize Programmable Interrupt Controllers.
  Initialize Global Descriptor Table.
  Enter protected mode.
  Pass control to kernel init code.


[kernel/init/init.asm]
  Initialize console.
  Initialize Interrupt Descriptor Table.
  Initialize Memory Manager.
  Initialize Task Scheduler.
  Enter kernel idle loop.


[kernel/mm/*]
  Memory manager is not yet implemented. Should probably at least have all
  the descriptor building and allocating code. For instance, irq.asm builds
  and allocates it's own descriptors which is probably a bad idea. Move
  that code here.


[kernel/sched/*]
  Task Scheduler is currently broken. The initialization code programs the
  clock to generate interrupts at 100Hz and installs the scheduler as a
  handler for the clock interrupt. The scheduler does indeed execute when
  an interrupt occurs but it generates a General Protection Exception when
  reaching the 'iret' instruction. The strange thing is that the handler
  returns properly if called by an 'int 0' instruction.


[kernel/lib/*]
  Help routines used in kernel. Currently consists only of Printk.c for
  console output. All output to console in the kernel should be through
  this module (except for the console driver and debug macros which are
  allowed direct access to video memory).


[kernel/hw/*]
  The files in this directory handle the hardware (console/irq/dma, stuff
  like that).

[kernel/hw/idt.asm]
  This file contains the default interrupt/exception handlers and also code
  to setup a default Interrupt Descriptor Table. Most handlers just display
  some data and then hang the system.

[kernel/hw/irq.asm]
  IRQ management. Contains code to enable/disable IRQs in the PIC and also
  code for allocating/deallocating IRQ lines. We can't allow other parts
  of the kernel to install handlers freely. It should always be done
  from here.

[kernel/hw/dma.c]
  DMA channel management. Incomplete and untested.

[kernel/hw/io.c]
  IO-port region management. Incomplete and untested.

[kernel/hw/console.asm]
  Basic console driver.


Most of the code is written in asm, but there are proper C interface to
many functions. The calling convention is to place all arguments on stack,
return value is in eax, and it is the called function that is responsible
for popping its arguments from stack upon return.

Building the kernel is done by entering the src root, inserting a floppy
into the floppy drive (contents will be destroyed) and executing:

	NASMENV=-Pinclude/nasm.h
	export NASMENV
	make build_fd0

There is a sample kernel called sample_kernel.img. To copy it to floppy:

	dd if=sample_kernel.img of=/dev/fd0 bs=1b

To run the kernel enable booting from floppy in BIOS, insert floppy into
drive and reboot.



---[ Summary ]---

To sum it up: this kernel sucks. But not as much as this documentation.



---[ References ]---

Protected Mode Software Architecture
Tom Shanley
ISBN: 0-201-55447-X

IA-32 Intel Architecture Software Developer's Manual
Volume 3: System Programming Guide

Linux Kernel Source (mostly early versions)
