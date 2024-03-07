#include "uart_common.h"

.section .text.init
.globl uart_init
.balign 4
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
.section .text
.globl uart_write_str
.balign 4
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

// a0 - the address of hex value
.section .text
.globl uart_send_hex
.balign 4
uart_send_hex:
    lw t0, 0(a0)
    // 8 digits in a word
    li t1, 8
    li t4, UART_ADDR

send_digit:

    lb t5, UART_LINE_STATUS(t4)
    andi t5, t5, UART_FIFO_TX_EMPTY
    beqz t5, send_digit

    // Shift right to get the value
    srli t2, t0, 28
    
    mv t6, ra
    call uart_send_digit
    mv ra, t6

    // Shift left to remove the printed digit
    slli t0, t0, 4
    addi t1, t1, -1
    
    bnez t1, send_digit
    
    ret

uart_send_digit:
    // Mask the digit
    andi t2, t2, 0xF

    li t3, '0'
    li t5, 10
    blt t2, t5, decimal
    
    li t3, 'a'
    addi t2, t2, -10

decimal:
    // Add ASCII code to digit
    add t2, t2, t3
    sw t2, 0(t4)
    ret

// a4 - the byte
.section .text
.globl uart_send_byte
.balign 4
uart_send_byte:
    li t0, UART_ADDR

send_byte:

    lb t1, UART_LINE_STATUS(t0)
    andi t1, t1, UART_FIFO_TX_EMPTY
    beqz t1, send_byte

    sb a4, 0(t0)

    ret

.end
