// From index 16 we have the 5 push buttons
#define RGPIO_IN        0x80004000
// Address to write 32 bit value to 
// seven segment controller
#define WRITE_DIGITS_REG        0x80006000

#define BTN_UP          0x01
#define BTN_RIGHT       0x02
#define BTN_DOWN        0x04
#define BTN_LEFT        0x08

#define READ_REG(addr) (*(volatile unsigned int *)addr)
#define WRITE_REG(addr, value) { (*((volatile unsigned int *) (addr)) = (value)); }

unsigned long g_value = 0x00;

void count(volatile unsigned short btns_val)
{
    static int btn_up_clicked, btn_down_clicked;

    if ((btns_val & BTN_UP) && !btn_up_clicked) {
        g_value += 1;
        btn_up_clicked = 1;
    } else if (!(btns_val & BTN_UP)) {
        btn_up_clicked = 0;
    }

    if ((btns_val & BTN_DOWN) && !btn_down_clicked) {
        g_value -= 1;
        btn_down_clicked = 1;
    } else if (!(btns_val & BTN_DOWN)) {
        btn_down_clicked = 0;
    }

    return;
}

void a_thousand(volatile unsigned short btns_val)
{
    static int btn_right_clicked, btn_left_clicked;

    if ((btns_val & BTN_RIGHT) && !btn_right_clicked) {
        g_value += 10000;
        btn_right_clicked = 1;
    } else if (!(btns_val & BTN_RIGHT)) {
        btn_right_clicked = 0;
    }

    if ((btns_val & BTN_LEFT) && !btn_left_clicked) {
        g_value -= 10000;
        btn_left_clicked = 1;
    } else if (!(btns_val & BTN_LEFT)) {
        btn_left_clicked = 0;
    }

    return;
}

int main()
{
    volatile unsigned long gpio_in_val, btns_val;

    while (1) {
        gpio_in_val = READ_REG(RGPIO_IN);
        btns_val = gpio_in_val >> 16;

        count(btns_val);
        a_thousand(btns_val);

        WRITE_REG(WRITE_DIGITS_REG, g_value);
    }

    return 0;
}