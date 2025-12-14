/* Linker script for HyperOS kernel */

ENTRY(_start)

SECTIONS
{
    /* Kernel loaded at 1MB physical address */
    . = 1M;

    /* Multiboot2 header must be in first 8KB */
    .multiboot_header ALIGN(8) : {
        KEEP(*(.multiboot_header))
    }

    /* Bootstrap code (32-bit) */
    .boot ALIGN(4K) : {
        *(.text.boot)
        *(.text)
    }

    /* Read-only data */
    .rodata ALIGN(4K) : {
        *(.rodata*)
    }

    /* Read-write data */
    .data ALIGN(4K) : {
        *(.data*)
    }

    /* BSS (uninitialized data) */
    .bss ALIGN(4K) : {
        *(COMMON)
        *(.bss*)
    }

    /* Kernel end marker */
    _kernel_end = .;
}
