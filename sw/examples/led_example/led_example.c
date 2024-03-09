// In GPIO Inputs we have the switches
// In GPIO Outputs we have the LEDs
#define RGPIO_IN        0x80204000
#define RGPIO_OUT       0x80204004
#define RGPIO_OE        0x80204008

#define ENABLE_GPIOs    0xFFFF

#define READ_REG(addr) (*(volatile unsigned int *)addr)
#define WRITE_REG(addr, value) { (*((volatile unsigned int *) (addr)) = (value)); }

// Proves that .data section is
// properly initialized from startup code
int g_var = ENABLE_GPIOs;

int main(void)
{
    WRITE_REG(RGPIO_OE, g_var);

    while (1) { 
        WRITE_REG(RGPIO_OUT, READ_REG(RGPIO_IN));
    }

    return 0;
}
