; Bootstrap code for HyperOS
; Transitions from 32-bit protected mode to 64-bit long mode

global _start
extern gdt64.pointer
extern gdt64.code_segment
extern gdt64.data_segment
extern kernel_main

; Multiboot2 constants
MULTIBOOT2_MAGIC equ 0x36d76289

section .bss
align 4096
; Page tables (must be 4KB aligned)
p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096

; Kernel stack (16KB)
stack_bottom:
    resb 16384
stack_top:

section .text
bits 32
_start:
    ; Save Multiboot2 info
    ; EAX contains magic number
    ; EBX contains address of Multiboot2 information structure
    mov edi, ebx            ; Save for kernel_main (RDI = first arg in x86_64)
    mov esi, eax            ; Save magic number

    ; Setup stack
    mov esp, stack_top

    ; Verify we were loaded by Multiboot2-compliant bootloader
    cmp eax, MULTIBOOT2_MAGIC
    jne .no_multiboot

    ; Check CPU support
    call check_cpuid
    call check_long_mode

    ; Setup paging
    call setup_page_tables
    call enable_paging

    ; Load 64-bit GDT
    lgdt [gdt64.pointer]

    ; Far jump to 64-bit code
    jmp gdt64.code_segment:long_mode_start

; Error handlers
.no_multiboot:
    mov al, 'M'
    jmp error

check_cpuid:
    ; Check if CPUID is supported by attempting to flip ID bit in FLAGS
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21        ; Flip ID bit
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    cmp eax, ecx
    je .no_cpuid
    ret

.no_cpuid:
    mov al, 'C'
    jmp error

check_long_mode:
    ; Check for extended CPUID
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_long_mode

    ; Check for long mode
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29       ; Long mode bit
    jz .no_long_mode
    ret

.no_long_mode:
    mov al, 'L'
    jmp error

setup_page_tables:
    ; Map P4[0] -> P3
    mov eax, p3_table
    or eax, 0b11            ; Present + Writable
    mov [p4_table], eax

    ; Map P3[0] -> P2
    mov eax, p2_table
    or eax, 0b11
    mov [p3_table], eax

    ; Map P2 entries to 2MB pages (identity mapping for first 1GB)
    mov ecx, 0              ; Counter
.map_p2:
    mov eax, 0x200000       ; 2MB
    mul ecx                 ; Page address
    or eax, 0b10000011      ; Present + Writable + Huge page
    mov [p2_table + ecx * 8], eax

    inc ecx
    cmp ecx, 512            ; 512 entries * 2MB = 1GB
    jne .map_p2

    ret

enable_paging:
    ; Load P4 address into CR3
    mov eax, p4_table
    mov cr3, eax

    ; Enable PAE (Physical Address Extension)
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Set long mode bit in EFER MSR (model specific register)
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8          ; LM bit
    wrmsr

    ; Enable paging in CR0
    mov eax, cr0
    or eax, 1 << 31         ; PG bit
    mov cr0, eax

    ret

error:
    ; Print 'ERR: X' where X is error code in AL
    mov dword [0xb8000], 0x4f524f45  ; 'ER' in red
    mov dword [0xb8004], 0x4f3a4f52  ; 'R:' in red
    mov byte [0xb8008], al
    mov byte [0xb8009], 0x4f          ; Red background
    hlt

; 64-bit long mode starts here
bits 64
long_mode_start:
    ; Clear all data segment registers
    mov ax, gdt64.data_segment
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Setup 64-bit stack
    mov rsp, stack_top

    ; Clear the screen with green text
    mov rax, 0x2f202f202f202f20
    mov rdi, 0xb8000
    mov rcx, 500
    rep stosq

    ; Call kernel main
    ; RDI already contains Multiboot2 info pointer
    ; RSI contains magic number
    call kernel_main

    ; If kernel returns, halt
    cli
.hang:
    hlt
    jmp .hang
