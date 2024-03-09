#define UART_ADDR       0x80205000

// alignment to word boundaries
// Write Reg
#define UART_TX_HOLD_REG    (4 * 0x00)
// Read Reg
#define UART_RX_REG         (4 * 0x00)

// Accessible when DLAB bit is set
#define UART_DLAB_LSB       (4 * 0x00)
#define UART_INTERRUPT_EN   (4 * 0x01)
#define UART_FIFO_CTRL      (4 * 0x02)
#define UART_LINE_CTRL      (4 * 0x03)
#define UART_LINE_STATUS    (4 * 0x05)

#define UART_DEFAULT_LINE_CTRL (0x03)
#define UART_FIFO_CLR          (0x06)
#define UART_FIFO_INT_TRIGGER  (0x80)
#define UART_FIFO_TX_EMPTY     (0x20)
