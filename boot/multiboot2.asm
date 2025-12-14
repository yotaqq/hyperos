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

    ; Framebuffer tag (optional - for graphics mode)
    align 8
framebuffer_tag_start:
    dw 5                    ; Type = framebuffer
    dw 0                    ; Flags
    dd framebuffer_tag_end - framebuffer_tag_start  ; Size
    dd 1024                 ; Width
    dd 768                  ; Height
    dd 32                   ; Depth (bits per pixel)
framebuffer_tag_end:

    ; End tag (required)
    align 8
    dw 0                    ; Type = end tag
    dw 0                    ; Flags
    dd 8                    ; Size
header_end:
