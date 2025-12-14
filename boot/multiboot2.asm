; Multiboot2 header for GRUB bootloader
; Must be in the first 8KB of the kernel file

section .multiboot_header
align 8
header_start:
    ; Multiboot2 magic number
    dd 0xE85250D6

    ; Architecture: 0 = i386/x86_64
    dd 0

    ; Header length
    dd header_end - header_start

    ; Checksum
    dd -(0xE85250D6 + 0 + (header_end - header_start))

    ; Tags go here

    ; End tag (required)
    align 8
    dw 0                    ; Type = end tag
    dw 0                    ; Flags
    dd 8                    ; Size
header_end:
