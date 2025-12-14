#include <kernel/types.h>
#include <kernel/vga.h>
#include <kernel/serial.h>
#include <kernel/string.h>

void kernel_main(uint64_t multiboot_info, uint64_t magic) {
    /* Initialize drivers */
    vga_init();
    serial_init(COM1);

    /* Set colors */
    vga_set_color(VGA_COLOR_LIGHT_GREEN, VGA_COLOR_BLACK);

    /* Display welcome message */
    vga_puts("HyperOS v0.1 - Hello World!\n");
    vga_puts("========================\n\n");

    vga_set_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    vga_puts("Bootloader: GRUB Multiboot2\n");
    vga_puts("Architecture: x86_64\n");
    vga_puts("Status: Running in 64-bit Long Mode\n\n");

    /* Send to serial port as well */
    serial_puts(COM1, "HyperOS v0.1 - Hello World!\r\n");
    serial_puts(COM1, "Bootloader: GRUB Multiboot2\r\n");
    serial_puts(COM1, "Architecture: x86_64\r\n");
    serial_puts(COM1, "Status: Running in 64-bit Long Mode\r\n");

    /* Display Multiboot2 info */
    vga_set_color(VGA_COLOR_LIGHT_CYAN, VGA_COLOR_BLACK);
    vga_puts("Multiboot2 magic: ");

    /* Simple hex printer */
    char hex[] = "0x00000000";
    for (int i = 9; i >= 2; i--) {
        uint8_t nibble = (magic >> ((9 - i) * 4)) & 0xF;
        hex[i] = nibble < 10 ? '0' + nibble : 'A' + nibble - 10;
    }
    vga_puts(hex);
    vga_puts("\n");

    vga_puts("Multiboot2 info: ");
    for (int i = 9; i >= 2; i--) {
        uint8_t nibble = (multiboot_info >> ((9 - i) * 4)) & 0xF;
        hex[i] = nibble < 10 ? '0' + nibble : 'A' + nibble - 10;
    }
    vga_puts(hex);
    vga_puts("\n\n");

    vga_set_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    vga_puts("Kernel initialization complete.\n");
    vga_puts("System ready.\n");

    /* Halt */
    while (1) {
        __asm__ volatile("hlt");
    }
}
