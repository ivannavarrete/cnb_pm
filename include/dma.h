
%ifndef _DMA_H
%define _DMA_H


%ifndef _DMA_C
extern request_dma
extern release_dma
extern enable_dma
extern disable_dma
extern set_dma_mode
extern set_dma_addr
extern set_dma_count
%endif

; dma controller io registers

%define DMA_1_MASKREG	0x0A		; single channel mask
%define DMA_1_CLEAR_FF	0x0C		; clear flip-flop
%define DMA_2_MASKREG	0xD4		; single channel mask
%define DMA_2_CLEAR_FF	0xD8		; clear flip-flop

; page registers
%define DMA_0_PAGE		0x87
%define DMA_1_PAGE		0x83
%define DMA_2_PAGE		0x81
%define DMA_3_PAGE		0x82
%define DMA_4_PAGE		0x8F
%define DMA_5_PAGE		0x8B
%define DMA_6_PAGE		0x89
%define DMA_7_PAGE		0x8A
; address registers
%define DMA_0_ADDR		0x00
%define DMA_1_ADDR		0x02
%define DMA_2_ADDR		0x04
%define DMA_3_ADDR		0x06
%define DMA_4_ADDR		0xC0
%define DMA_5_ADDR		0xC4
%define DMA_6_ADDR		0xC8
%define DMA_7_ADDR		0xCC
; count registers
%define DMA_0_COUNT		0x01
%define DMA_1_COUNT		0x03
%define DMA_2_COUNT		0x05
%define DMA_3_COUNT		0x07
%define DMA_4_COUNT		0xC2
%define DMA_5_COUNT		0xC6
%define DMA_6_COUNT		0xCA
%define DMA_7_COUNT		0xCE


%define MAX_DMA_CHAN	7
%define MAX_DMA_ADDR	0x1000000

%define DMA_CHAN_SS		5
struc dma_chan
	.lock:			resb 1
	.dev:			resd 1
endstruc


%endif
