
%ifndef CONFIG_H
%define CONFIG_H


; system addresses
%define VIDEO_ADDR	0xB8000
%define SETUP_ADDR	0x90000
%define SYS_ADDR	0x10000	; sacrifice 256 GDT entries (sys not at 0x10800)
%define GDT_ADDR	0x00800
%define IDT_ADDR	0x00000

%define SYSEND		0xA0000

; GDT selectors (if GDT organization is changed change here too)
%define IDT_SEL		0x0008
%define GDT_SEL		0x0010
%define CODE32_SEL	0x0018
%define DATA32_SEL	0x0020
%define VIDEO_SEL	0x0028


%define IRQ_BASE	0x20


%endif
