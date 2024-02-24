#include "rv_csr.h"

// In GPIO Inputs we have the switches
// In GPIO Outputs we have the LEDs
#define RGPIO_IN        0x80004000
#define RGPIO_OUT       0x80004004
#define RGPIO_OE        0x80004008
#define RGPIO_INTE      0x8000400C
#define RGPIO_PTRIG     0x80004010
#define RGPIO_CTRL      0x80004018
#define RGPIO_INTS      0x8000401C

#define ENABLE_GPIOs    0xFFFF

#define BTN_MIDDLE      0x10
#define BTN_MIDDLE_IDX  20

#define READ_REG(addr) (*(volatile unsigned int *)addr)
#define WRITE_REG(addr, value) { (*((volatile unsigned int *) (addr)) = (value)); }

unsigned int count_btn_press;

__attribute__((interrupt("machine"))) 
void interrupt_handler()
{
    count_btn_press += 1;
    WRITE_REG(RGPIO_OUT, count_btn_press); 

    // clear interrupt
    WRITE_REG(RGPIO_INTS, 0x00); 
}

int main()
{
    // Set trap handler
    csr_write(CSR_MTVEC, (uint32_t)(&interrupt_handler));
    // Enable mie
    csr_write(CSR_MSTATUS, 0x08);
    // Enable meie
    csr_write(CSR_MIE, 0x800);

    WRITE_REG(RGPIO_OE, ENABLE_GPIOs);
    // Start at zero
    WRITE_REG(RGPIO_OUT, 0x00);

    // Enable interrupts
    WRITE_REG(RGPIO_INTE, (1 << BTN_MIDDLE_IDX));
    WRITE_REG(RGPIO_PTRIG, (1 << BTN_MIDDLE_IDX));
    WRITE_REG(RGPIO_INTS, 0x00);
    WRITE_REG(RGPIO_CTRL, 0x01);

    while (1) ;

    return 0;
}