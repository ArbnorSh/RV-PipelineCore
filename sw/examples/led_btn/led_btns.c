// In GPIO Inputs we have the switches (16 switches)
// then from index 16 we have 5 push buttons
// In GPIO Outputs we have the LEDs
#define RGPIO_IN        0x80204000
#define RGPIO_OUT       0x80204004
#define RGPIO_OE        0x80204008

#define ENABLE_GPIOs    0xFFFF

#define BTN_UP          0x01
#define BTN_RIGHT       0x02
#define BTN_DOWN        0x04
#define BTN_LEFT        0x08

#define READ_REG(addr) (*(volatile unsigned int *)addr)
#define WRITE_REG(addr, value) { (*((volatile unsigned int *) (addr)) = (value)); }

enum {
    SHIFT_MODE = 0,
    COUNT_MODE = 1
};

unsigned short g_led_value = 0x01;

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

void shift_mode(volatile unsigned short btns_val)
{
    static int btn_right_clicked, btn_left_clicked;

    if ((btns_val & BTN_RIGHT) && !btn_right_clicked) {
        rotate_right(&g_led_value, 1);
        btn_right_clicked = 1;
    } else if (!(btns_val & BTN_RIGHT)) {
        btn_right_clicked = 0;
    }

    if ((btns_val & BTN_LEFT) && !btn_left_clicked) {
        rotate_left(&g_led_value, 1);
        btn_left_clicked = 1;
    } else if (!(btns_val & BTN_LEFT)) {
        btn_left_clicked = 0;
    }

    return;
}

void count_mode(volatile unsigned short btns_val)
{
    static int btn_up_clicked, btn_down_clicked;

    if ((btns_val & BTN_UP) && !btn_up_clicked) {
        g_led_value += 1;
        btn_up_clicked = 1;
    } else if (!(btns_val & BTN_UP)) {
        btn_up_clicked = 0;
    }

    if ((btns_val & BTN_DOWN) && !btn_down_clicked) {
        g_led_value -= 1;
        btn_down_clicked = 1;
    } else if (!(btns_val & BTN_DOWN)) {
        btn_down_clicked = 0;
    }

    return;
}

int main(void)
{
    volatile unsigned long gpio_in_val, btns_val;
    int current_mode, last_mode;

    WRITE_REG(RGPIO_OE, ENABLE_GPIOs);

    while (1) {
        gpio_in_val = READ_REG(RGPIO_IN);
        btns_val = gpio_in_val >> 16;
        
        if (!(gpio_in_val & 0x01)) {
            shift_mode(btns_val);
            current_mode = SHIFT_MODE;
        } else {
            count_mode(btns_val);
            current_mode = COUNT_MODE;
        }

        if (last_mode != current_mode) {
            g_led_value = 0x01;
        }
        last_mode = current_mode;

        WRITE_REG(RGPIO_OUT, g_led_value);
    }

    return 0;
}
