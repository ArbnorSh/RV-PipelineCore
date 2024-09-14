// SPDX-License-Identifier: BSD-3-Clause
// 
// Copyright (c) [2024], [Arbnor Shabani]
// All rights reserved.
// 
// This code is licensed under the BSD 3-Clause License.
// See the LICENSE file for more details.

#include "seven_segment.h"
#include <stdio.h>

bool SevenSegment::sev_seg_tick(uint8_t anode, uint8_t cathode)
{
    int current_segment = -1;
    for (int i = 0; i < kNumberOfDigits; i++) {
        // anode of digit is asserted when low
        // check whitch one of 8 anodes is asserted
        if ((~anode) & (1 << i)) {
            current_segment = i;
        }
    }

    if (current_segment == -1 || m_last_segment == current_segment) {
        return false;
    }
    m_last_segment = current_segment;

    if (cathode == m_digits[current_segment]) {
        return false;
    }

    m_digits[current_segment] = cathode;

    if (m_initial_decoder < 8) {
        m_initial_decoder++;
    }

    return (m_initial_decoder > 7);
}

uint32_t SevenSegment::get_display_number()
{
    return decoded_value();
}

uint32_t SevenSegment::decoded_value()
{
    uint32_t decoded_val = 0;
    uint8_t digit;
    for (int i = 0; i < kNumberOfDigits; i++) {
        switch (m_digits[i]) {
            case 0x40 : digit = 0x0; break;
            case 0x79 : digit = 0x1; break;
            case 0x24 : digit = 0x2; break;
            case 0x30 : digit = 0x3; break;
            case 0x19 : digit = 0x4; break;
            case 0x12 : digit = 0x5; break;
            case 0x02 : digit = 0x6; break;
            case 0x78 : digit = 0x7; break;
            case 0x00 : digit = 0x8; break;
            case 0x18 : digit = 0x9; break;
            case 0x08 : digit = 0xA; break;
            case 0x03 : digit = 0xB; break;
            case 0x46 : digit = 0xC; break;
            case 0x21 : digit = 0xD; break;
            case 0x06 : digit = 0xE; break;
            case 0x0e : digit = 0xF; break;
            default   : digit = 0x0;
        }
        decoded_val |= digit << (i*4);
    }

    return decoded_val;
}
