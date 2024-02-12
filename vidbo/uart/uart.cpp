#include "uart.h"

#ifndef DEBUG
#define ENABLE_VERBOSE_LOG 1
#else
#define ENABLE_VERBOSE_LOG 0
#endif

#define verbose_log(...) \
    do { \
        if (ENABLE_VERBOSE_LOG) { \
            fprintf (stdout, __VA_ARGS__); \
        } \
    } while (0)

UartSim::UartSim(uint32_t baud_rate) {
    m_baud_time = 1000000000 / baud_rate;
};

void UartSim::uart_tick(bool uart_rx, uint64_t main_time)
{
    switch(m_state_machine) {
        case UART_SM::IDLE:
            verbose_log("IDLE\n");
            if (uart_rx) m_state_machine = UART_SM::DETECT_START_BIT;
            break;
        case UART_SM::DETECT_START_BIT:
            if (!uart_rx) {
                verbose_log("DETECT_START_BIT\n");
                m_state_machine = UART_SM::DETECT_MID_START_BIT;
                m_baud_wait = main_time + m_baud_time/2;
            }
            break;
        case UART_SM::DETECT_MID_START_BIT:
            if (main_time > m_baud_wait) {
                verbose_log("DETECT_MID_START_BIT\n");
                m_state_machine = UART_SM::DETECT_MID_DATA_BIT;
                m_baud_wait += m_baud_time;
                m_char = 0;
                m_bit_pos = 0;
            }
            break;
        case UART_SM::DETECT_MID_DATA_BIT:
            if (main_time > m_baud_wait) {
                verbose_log("DETECT_MID_DATA_BIT\n");
                m_baud_wait += m_baud_time;
                m_char |= uart_rx << (m_bit_pos++);
                // 8 bits received 0 through 7
                if (m_bit_pos == 8) m_state_machine = UART_SM::STOP_BIT;
            }
            break;
        case UART_SM::STOP_BIT:
            if (main_time > m_baud_wait) {
                verbose_log("STOP_BIT\n");
                add_char();
                m_baud_wait += m_baud_time;
                m_state_machine = UART_SM::DETECT_START_BIT;
            }
            break;
    }
}

void UartSim::add_char()
{
    m_uart_str += m_char;
    verbose_log("Char Received: %c\n", m_char);
    if (m_char == '\n') {
        verbose_log("C String Received: %s\n", m_uart_str.c_str());
        m_q.push(m_uart_str);
        m_uart_str.clear();
    }
}

[[nodiscard]] std::string UartSim::get_string()
{
    std::string uart_string;
    if (!m_q.empty()) {
        uart_string = m_q.front();
        m_q.pop();
    }

    return uart_string;
}
