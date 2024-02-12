#include "uart_lib.h"
#include <string.h>

void uart_init()
{
    // Access divisor latches
    WRITE_UART_REG(UART_LINE_CTRL, 0x80);

    // 50 MHz / 16 x Baud Rate = divisor
    // 27 divisor for 115200 Baud Rate
    WRITE_UART_REG(UART_DLAB_LSB, 27);

    // 8 bits + 1 stop, no parity
    WRITE_UART_REG(UART_LINE_CTRL, UART_DEFAULT_LINE_CTRL);

    // 8 bytes trigger interrupt if enabled
    // clear TX and RX fifo
    WRITE_UART_REG(UART_FIFO_CTRL, UART_FIFO_INT_TRIGGER | UART_FIFO_CLR);

    // Interrupts disabled
    WRITE_UART_REG(UART_INTERRUPT_EN, 0x00);

    return;
}

int uart_write_str(const char* string)
{
    for (int i = 0; i < strlen(string); i++) {
        while (!(READ_UART_REG(UART_LINE_STATUS) & UART_FIFO_TX_EMPTY)) { };
        WRITE_UART_REG(UART_TX_HOLD_REG, string[i]);
    }

    return 0;
}
