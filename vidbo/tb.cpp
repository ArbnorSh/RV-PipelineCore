// SPDX-License-Identifier: Apache-2.0
// Copyright 2021 Olof Kindgren
// Copyright 2024 [Arbnor Shabani]
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <stdint.h>
#include <signal.h>
#include <memory>

#include "vidbo/vidbo.h"
#include <verilated_vcd_c.h>

#include "Vrvsocsim.h"

#include "uart/uart.h"

using namespace std;

static bool done;

vluint64_t main_time = 0;

double sc_time_stamp()
{
  return main_time;
}

void INThandler(int signal)
{
  printf("\nCaught ctrl-c\n");
  done = true;
}

int main(int argc, char **argv, char **env)
{
  vidbo_context_t vidbo_context;

  const char *const inputs[] = {
      "gpio.SW0",
      "gpio.SW1",
      "gpio.SW2",
      "gpio.SW3",
      "gpio.SW4",
      "gpio.SW5",
      "gpio.SW6",
      "gpio.SW7",
      "gpio.SW8",
      "gpio.SW9",
      "gpio.SW10",
      "gpio.SW11",
      "gpio.SW12",
      "gpio.SW13",
      "gpio.SW14",
      "gpio.SW15",
      "gpio.BTNU",
      "gpio.BTNR",
      "gpio.BTND",
      "gpio.BTNL",
      "gpio.BTNC",
  };
  int num_inputs = sizeof(inputs) / sizeof(inputs[0]);

  int *input_vals = (int *)calloc(num_inputs, sizeof(int));

  vidbo_init(&vidbo_context, 8081);

  vidbo_register_inputs(&vidbo_context, inputs, num_inputs);

  Verilated::commandArgs(argc, argv);
  std::unique_ptr<VerilatedVcdC> m_trace;

  std::unique_ptr<Vrvsocsim> m_top = std::make_unique<Vrvsocsim>();
  Verilated::commandArgs(argc, argv);

  const char* trace_arg = Verilated::commandArgsPlusMatch("trace");
  if (std::string(trace_arg) == "+trace") {
    Verilated::traceEverOn(true);
    m_trace = std::make_unique<VerilatedVcdC>();
    m_top->trace(m_trace.get(), 99);
    m_trace->open("sim_waveform.vcd");
  }

  signal(SIGINT, INThandler);

  int check_vidbo = 0;

  m_top->i_clk = 1;
  m_top->i_reset = 1;
  int last_leds = m_top->o_led;
  std::string uart_str;

  constexpr int baud_rate = 115200;
  std::unique_ptr<UartSim> m_uart = std::make_unique<UartSim>(baud_rate);

  while (!(done || Verilated::gotFinish())) {
    if (main_time == 100) {
      m_top->i_reset = 0;
    }

    m_top->eval();

    if (m_trace) {
      m_trace->dump(main_time);
    }

    m_uart->uart_tick(m_top->uart_tx, main_time);

    /* To improve performance, only poll websockets connection every 10000 sim cycles */
    check_vidbo++;
    if (!(check_vidbo % 10000)) {

      /* Send out all GPIO status
       TODO: Only send changed pins.
      */
      char item[5] = {0}; // Space for LD??\0
      if (last_leds != m_top->o_led) {
        for (int i = 0; i < 16; i++) {
          snprintf(item, 5, "LD%d", i);
          vidbo_send(&vidbo_context, main_time, "gpio", item, (m_top->o_led >> i) & 0x1);
        }
        last_leds = m_top->o_led;
      }

      /* Check for input updates. If vidbo_recv returns 1, we have inputs to update */
      if (vidbo_recv(&vidbo_context, input_vals)) {
        /* Update the GPIO inputs from the received frame */
        m_top->i_sw = 0;
        for (int i = 0; i < 16; i++) {
          if (input_vals[i]) {
            m_top->i_sw |= (1 << i);
          }
        }
        m_top->i_btn = 0;
        for (int i = 16; i < 21; i++) {
          if (input_vals[i]) {
            m_top->i_btn |= (1 << (i - 16));
          }
        }
      }
    }

    /* Write character to UART */
    if (!(check_vidbo % 1000000) && is_board_connected()) {
      std::string uart_string = m_uart->get_string();
      int idx = 0;
      std::string group_string = "uart";
      std::string send_str;

      for (const char& ch : uart_string) {
        send_str = group_string + std::to_string(idx);
        vidbo_send(&vidbo_context, main_time, "serial", send_str.c_str(), ch);
        idx++;
      }
    }

    m_top->i_clk = !m_top->i_clk;
    main_time += 10;
  }

  if (m_trace) {
    m_trace->close();
  }

  exit(0);
}
