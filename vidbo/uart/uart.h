// SPDX-License-Identifier: BSD-3-Clause
// 
// Copyright (c) [2024], [Arbnor Shabani]
// All rights reserved.
// 
// This code is licensed under the BSD 3-Clause License.
// See the LICENSE file for more details.

#include <stdint.h>
#include <queue>
#include <string>

enum class UART_SM {
    IDLE=0,
    DETECT_START_BIT,
    DETECT_MID_START_BIT,
    DETECT_MID_DATA_BIT,
    STOP_BIT
};

class UartSim {
public:

    UartSim(uint32_t baud_rate);

    void uart_tick(bool uart_rx, uint64_t main_time);
    [[nodiscard]] std::string get_string();

private:
    uint32_t m_baud_time;
    uint64_t m_baud_wait;
    char m_char;
    uint8_t m_bit_pos;
    UART_SM m_state_machine = UART_SM::IDLE;

    std::string m_uart_str{};

    // q that holds new line strings
    std::queue<std::string> m_q;

    void add_char();
};
