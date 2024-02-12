.globl main

main:
    call uart_init

    la a0, hello_str

    call uart_write_str

    la a0, hello_riscv

    call uart_write_str

// infinite loop
done: beqz zero, done 

.section .data
hello_str:
    .string "Hello World\r\n"
hello_riscv:
    .string "Hello RISCV\r\n"

.end