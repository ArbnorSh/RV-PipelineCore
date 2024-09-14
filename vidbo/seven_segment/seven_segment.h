// SPDX-License-Identifier: BSD-3-Clause
// 
// Copyright (c) [2024], [Arbnor Shabani]
// All rights reserved.
// 
// This code is licensed under the BSD 3-Clause License.
// See the LICENSE file for more details.

#include <stdint.h>

namespace {
    constexpr uint8_t kNumberOfDigits = 8;
};

class SevenSegment {

public:
    bool sev_seg_tick(uint8_t anode, uint8_t cathode);
    uint32_t get_display_number();

private:
    uint8_t m_digits[kNumberOfDigits];
    int m_last_segment{-1};
    uint8_t m_initial_decoder{};

    uint32_t decoded_value();


};