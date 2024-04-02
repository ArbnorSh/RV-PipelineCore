#include "uart_common.h"

#define READ_UART_REG(reg_addr) \
(*(volatile unsigned int *)(UART_ADDR + reg_addr))

#define WRITE_UART_REG(reg_addr, value) \
{ (*((volatile unsigned int *) (UART_ADDR + reg_addr)) = (value)); }

void uart_init();
int uart_write_str(const char* string);
void uart_write_char(char c);
