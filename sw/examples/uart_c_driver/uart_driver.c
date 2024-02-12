#include "uart_lib.h"

int main()
{
    uart_init();

    uart_write_str("Hello from C\n");

    uart_write_str("Hello from RISCV Core\n");

    while (1) ;

    return 0;
}