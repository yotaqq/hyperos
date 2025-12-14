#include <kernel/serial.h>
#include <asm/io.h>

/* Serial port registers */
#define SERIAL_DATA(port)          (port)
#define SERIAL_INT_ENABLE(port)    (port + 1)
#define SERIAL_FIFO_CTRL(port)     (port + 2)
#define SERIAL_LINE_CTRL(port)     (port + 3)
#define SERIAL_MODEM_CTRL(port)    (port + 4)
#define SERIAL_LINE_STATUS(port)   (port + 5)

/* Line status bits */
#define SERIAL_LSR_DATA_READY      0x01
#define SERIAL_LSR_THR_EMPTY       0x20

void serial_init(uint16_t port) {
    /* Disable interrupts */
    outb(SERIAL_INT_ENABLE(port), 0x00);

    /* Enable DLAB (set baud rate divisor) */
    outb(SERIAL_LINE_CTRL(port), 0x80);

    /* Set divisor to 3 (38400 baud) */
    outb(SERIAL_DATA(port), 0x03);
    outb(SERIAL_INT_ENABLE(port), 0x00);

    /* 8 bits, no parity, one stop bit */
    outb(SERIAL_LINE_CTRL(port), 0x03);

    /* Enable FIFO, clear them, with 14-byte threshold */
    outb(SERIAL_FIFO_CTRL(port), 0xC7);

    /* IRQs enabled, RTS/DSR set */
    outb(SERIAL_MODEM_CTRL(port), 0x0B);

    /* Enable interrupts */
    outb(SERIAL_INT_ENABLE(port), 0x01);
}

static int serial_is_transmit_empty(uint16_t port) {
    return inb(SERIAL_LINE_STATUS(port)) & SERIAL_LSR_THR_EMPTY;
}

void serial_putchar(uint16_t port, char c) {
    /* Wait for transmit buffer to be empty */
    while (!serial_is_transmit_empty(port));

    /* Send character */
    outb(SERIAL_DATA(port), c);
}

void serial_puts(uint16_t port, const char *str) {
    while (*str) {
        serial_putchar(port, *str++);
    }
}

static int serial_received(uint16_t port) {
    return inb(SERIAL_LINE_STATUS(port)) & SERIAL_LSR_DATA_READY;
}

char serial_getchar(uint16_t port) {
    /* Wait for data to be received */
    while (!serial_received(port));

    /* Read character */
    return inb(SERIAL_DATA(port));
}
