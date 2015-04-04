
%ifndef MM_H
%define MM_H


%define	PAGE_SIZE 4096
%define PAGE_DIR_SIZE 4096
%define PAGE_TABLE_SIZE 4096


%define PTE_PY		000000000001b			; page dir entry present
%define PTE_PN		000000000000b			; page dir not present

%define PTE_RWY		000000000010b			; read/write
%define PTE_RWN		000000000000b			; read only

%define PTE_U		000000000100b			; user
%define PTE_S		000000000000b			; supervisor

%define PTE_PWT		000000001000b			; page write-through
%define PTE_PWB		000000000000b			; page write-back

%define PTE_PCY		000000000000b			; page cache enable
%define PTE_PCN		000000010000b			; page cache disable

%define PTE_AY		000000100000b			; accessed
%define PTE_AN		000000000000b			; not accessed

%define PTE_DY		000001000000b			; dirty (PTE only)
%define PTE_DN		000000000000b			; not dirty (PTE only)

%define PTE_PSM		000010000000b			; page size - 4Mb
%define PTE_PSP		000000000000b			; page size - 4Kb


%define PTE_ADDR_MASK 0xFFFFF000
%define PTE_ADDR_SHIFT 12

; Macro for easy definition of page directory and page table entries.
; (%1)		page/page table base addr (20-bit)
; (%2)		attributes (12-bit)
%macro page_entry 2
	dd	((%2) & ~PTE_ADDR_MASK) | ((%1) << PTE_ADDR_SHIFT)
%endmacro


%endif
