; Global Descriptor Table for 64-bit Long Mode
; In Long Mode, segmentation is mostly ignored, but GDT is still required

section .rodata
align 8
gdt64:
    ; Null descriptor (required)
    dq 0

.code_segment: equ $ - gdt64
    ; Code segment descriptor
    ; Base = 0, Limit = 0, Present = 1, Executable = 1, Long mode = 1
    ; Bits: 43=Executable, 44=S, 47=Present, 53=Long mode
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)

.data_segment: equ $ - gdt64
    ; Data segment descriptor
    ; Base = 0, Limit = 0, Present = 1, Writable = 1
    ; Bits: 41=Writable, 44=S, 47=Present
    dq (1 << 41) | (1 << 44) | (1 << 47)

.pointer:
    dw $ - gdt64 - 1        ; Limit (size - 1)
    dd gdt64                ; Base address (32-bit for lgdt in protected mode)

; Export symbols
global gdt64
global gdt64.code_segment
global gdt64.data_segment
global gdt64.pointer
