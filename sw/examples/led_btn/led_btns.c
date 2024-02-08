// In GPIO Inputs we have the switches (16 switches)
// then from index 16 we have 5 push buttons
// In GPIO Outputs we have the LEDs
#define RGPIO_IN        0x80004000
#define RGPIO_OUT       0x80004004
#define RGPIO_OE        0x80004008

#define ENABLE_GPIOs    0xFFFF

#define BTN_RIGHT       0x02
#define BTN_LEFT        0x08

#define READ_REG(addr) (*(volatile unsigned int *)addr)
#define WRITE_REG(addr, value) { (*((volatile unsigned int *) (addr)) = (value)); }

void rotate_left(unsigned short* num, int n)
{
    unsigned short value = *num;
    *num = (value << n) | (value >> (16 - n));

    return;
}

void rotate_right(unsigned short* num, int n)
{
    unsigned short value = *num;
    *num = (value >> n) | (value << (16 - n));

    return;
}

int main(void)
{
    int btn_right_clicked = 0, btn_left_clicked = 0;
    volatile unsigned long btns_val; 
    unsigned short led_value = 0x01;

    WRITE_REG(RGPIO_OE, ENABLE_GPIOs);

    while (1) {
        btns_val = READ_REG(RGPIO_IN) >> 16;
        
        if ((btns_val & BTN_RIGHT) && !btn_right_clicked) {
            rotate_right(&led_value, 1);
            btn_right_clicked = 1;
        } else if (!(btns_val & BTN_RIGHT)) {
            btn_right_clicked = 0;
        }

        if ((btns_val & BTN_LEFT) && !btn_left_clicked) {
            rotate_left(&led_value, 1);
            btn_left_clicked = 1;
        } else if (!(btns_val & BTN_LEFT)) {
            btn_left_clicked = 0;
        }

        WRITE_REG(RGPIO_OUT, led_value);
    }

    return 0;
}
