#ifndef KERNEL_SERIAL_H
#define KERNEL_SERIAL_H

#include <kernel/types.h>

/* Serial port definitions */
#define COM1 0x3F8
#define COM2 0x2F8
#define COM3 0x3E8
#define COM4 0x2E8

/* Serial functions */
void serial_init(uint16_t port);
void serial_putchar(uint16_t port, char c);
void serial_puts(uint16_t port, const char *str);
char serial_getchar(uint16_t port);

#endif /* KERNEL_SERIAL_H */
