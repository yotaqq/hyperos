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
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)

.data_segment: equ $ - gdt64
    ; Data segment descriptor
    ; Base = 0, Limit = 0, Present = 1, Writable = 1
    dq (1 << 44) | (1 << 47)

.pointer:
    dw $ - gdt64 - 1        ; Limit (size - 1)
    dq gdt64                ; Base address

; Export symbols
global gdt64
global gdt64.code_segment
global gdt64.data_segment
global gdt64.pointer
