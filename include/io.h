
%ifndef _IO_H
%define _IO_H


%ifndef _IO_C
extern request_io
extern release_io
extern check_io
%endif


%define MAX_IO_PORT		0xFFFF
%define MAX_IO_REGIONS	127

%define IO_REGION_SS	0x10
struc io_region
	.lock:		resb 1
	.start:		resd 1
	.end:		resd 1
	.dev:		resd 1
	.next:		resd 1
endstruc


%endif
