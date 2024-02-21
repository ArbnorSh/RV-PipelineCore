
#define PTC_BASE_ADDR 0x80006200

// from gpio spec
// gpio output - LEDs
#define RGPIO_OUT       0x80004004
#define RGPIO_OE        0x80004008

#define ENABLE_GPIOs    0xFFFF

// from ptc spec
#define RPTC_CNTR (PTC_BASE_ADDR + 0x00)
#define RPTC_HRC  (PTC_BASE_ADDR + 0x04)
#define RPTC_LRC  (PTC_BASE_ADDR + 0x08)
#define RPTC_CTRL (PTC_BASE_ADDR + 0x0C)

#define MS_100_COUNT (0x4C4B40)

.globl main
main:
    li s0, RGPIO_OUT
    li t0, RPTC_CTRL
    li t1, RPTC_LRC
    li t2, 0xC0
    li t3, 0x21

    // Enable Output GPIOs
    li s1, ENABLE_GPIOs
    li s2, RGPIO_OE
    sw s1, 0(s2)

    // Count for 100 milliseconds
    // using 50 MHz clock
    li s1, MS_100_COUNT
    sw s1, 0(t1)
    // HRC Max Value
    li t4, RPTC_HRC
    li s2, 0xFFFFFFFF
    sw s2, 0(t4)

    mv s3, zero
    count_loop:
        sw s3, 0(s0)
        addi s3, s3, 1

        // Clear interrupt requests
        sw t2, 0(t0)
        // Enable Counter
        sw t3, 0(t0)

        check_timer:
            lw t4, 0(t0)
            // Check if pending interrupt
            andi t4, t4, 0x40
            beqz t4, check_timer

        j count_loop

    jr ra
