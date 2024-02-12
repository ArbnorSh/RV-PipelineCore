.globl uart_init
.globl uart_write_str

#define UART_ADDR       0x80005000

// alignment to word boundaries
#define UART_DLAB_LSB       (4 * 0x00)
#define UART_INTERRUPT_EN   (4 * 0x01)
#define UART_FIFO_CTRL      (4 * 0x02)
#define UART_LINE_CTRL      (4 * 0x03)
#define UART_LINE_STATUS    (4 * 0x05)

#define UART_DEFAULT_LINE_CTRL (0x03)
#define UART_FIFO_CLR          (0x06)
#define UART_FIFO_INT_TRIGGER  (0x80)
#define UART_FIFO_TX_EMPTY     (0x20)

uart_init:
    li t0, UART_ADDR

    // Access divisor latches
    li t1, 0x80
    sb t1, UART_LINE_CTRL(t0)

    // 50 MHz / 16 x Baud Rate = divisor
    // 27 divisor for 115200 Baud Rate
    li t2, 27
    sb t2, UART_DLAB_LSB(t0)

    // 8 bits + 1 stop, no parity
    li t3, UART_DEFAULT_LINE_CTRL
    sb t3, UART_LINE_CTRL(t0)

    // 8 bytes trigger interrupt if enabled
    // clear TX and RX fifo
    li t4, UART_FIFO_INT_TRIGGER | UART_FIFO_CLR 
    sb t4, UART_FIFO_CTRL(t0)

    // Interrupts disabled
    sb zero, UART_INTERRUPT_EN(t0)

    ret

// a0 - start address of string
// write bytes until found \0
uart_write_str:
    li t0, UART_ADDR

    lb t1, 0(a0)

next_char:

    lb t2, UART_LINE_STATUS(t0)
    andi t2, t2, UART_FIFO_TX_EMPTY
    beqz t2, next_char

    // write the char
    sb t1, 0(t0)

    // get the next char
    addi a0, a0, 1
    lb t1, 0(a0)

    // check if current char is \0
    bne t1, zero, next_char

    ret

.end
