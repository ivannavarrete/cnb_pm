
; Include this file in all drivers. The drivers subsystem in the kernel provides
; these functions and data variables for registering the driver with the kernel.


%ifndef _DRIVER_H
%define _DRIVER_H


%ifndef _DRIVER_C
extern request_irq
extern release_irq
extern enable_irq
extern disable_irq
extern request_io
extern release_io
%endif


%define MAX_DRIVERS		0x20
%define MAX_MAJOR		0xFFFF

%define DRIVER_SS		0x18
struc driver
	.major:				resw 1
	.name:				resb 10
	.init:				resd 1
	.cleanup:			resd 1
	.ops:				resd 1
	.next:				resd 1
endstruc


%endif
