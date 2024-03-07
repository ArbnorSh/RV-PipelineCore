#include "rv_csr.h"

// In GPIO Inputs we have the switches
// In GPIO Outputs we have the LEDs
#define RGPIO_IN        0x80204000
#define RGPIO_OUT       0x80204004
#define RGPIO_OE        0x80204008
#define RGPIO_INTE      0x8020400C
#define RGPIO_PTRIG     0x80204010
#define RGPIO_CTRL      0x80204018
#define RGPIO_INTS      0x8020401C

#define ENABLE_GPIOs    0xFFFF

#define BTN_MIDDLE      0x10
#define BTN_MIDDLE_IDX  20

// Timer
#define PTC_BASE_ADDR 0x80206200
#define RPTC_CNTR (PTC_BASE_ADDR + 0x00)
#define RPTC_HRC  (PTC_BASE_ADDR + 0x04)
#define RPTC_LRC  (PTC_BASE_ADDR + 0x08)
#define RPTC_CTRL (PTC_BASE_ADDR + 0x0C)

#define MS_100_COUNT (0x4C4B40)

// seven segment controller
#define WRITE_DIGITS_REG        0x80006000

#define READ_REG(addr) (*(volatile unsigned int *)addr)
#define WRITE_REG(addr, value) { (*((volatile unsigned int *) (addr)) = (value)); }

volatile unsigned int count_btn_press;
volatile unsigned int count_timer;

__attribute__((interrupt("machine"))) 
void interrupt_handler()
{
    if (READ_REG(RGPIO_INTS) & (1 << BTN_MIDDLE_IDX)) {
        count_btn_press += 1;
        WRITE_REG(RGPIO_OUT, count_btn_press);
        WRITE_REG(RGPIO_INTS, 0x00);
    } else if (READ_REG(RPTC_CTRL) & 0x40) {
        count_timer += 1;
        WRITE_REG(WRITE_DIGITS_REG, count_timer);
        WRITE_REG(RPTC_CNTR, 0x00);
        WRITE_REG(RPTC_CTRL, 0x40);
        WRITE_REG(RPTC_CTRL, 0x31);
    }
}

void cpu_int_init()
{
    // Set trap handler
    csr_write(CSR_MTVEC, (uint32_t)(&interrupt_handler));
    // Enable mie
    csr_write(CSR_MSTATUS, 0x08);
    // Enable meie and mtie
    csr_write(CSR_MIE, 0x880);
}

void gpio_int_init()
{
    WRITE_REG(RGPIO_OE, ENABLE_GPIOs);
    // Start at zero
    WRITE_REG(RGPIO_OUT, 0x00);

    // Enable interrupts
    WRITE_REG(RGPIO_INTE, (1 << BTN_MIDDLE_IDX));
    WRITE_REG(RGPIO_PTRIG, (1 << BTN_MIDDLE_IDX));
    WRITE_REG(RGPIO_INTS, 0x00);
    WRITE_REG(RGPIO_CTRL, 0x01);
}

void timer_int_init()
{
    WRITE_REG(RPTC_LRC, MS_100_COUNT / 2);
    // Max value for HRC
    // so no match happens with HRC
    WRITE_REG(RPTC_HRC, 0xFFFFFFFF);
    WRITE_REG(RPTC_CNTR, 0x00);
    // Clear irq
    WRITE_REG(RPTC_CTRL, 0x40);
    // Enable counter
    WRITE_REG(RPTC_CTRL, 0x31);
}

int main()
{
    gpio_int_init();
    timer_int_init();
    cpu_int_init();

    while (1) ;

    return 0;
}
