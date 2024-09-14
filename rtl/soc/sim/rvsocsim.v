// SPDX-License-Identifier: BSD-3-Clause
// 
// Copyright (c) [2024], [Arbnor Shabani]
// All rights reserved.
// 
// This code is licensed under the BSD 3-Clause License.
// See the LICENSE file for more details.

module rvsocsim(
    input wire i_clk,
    input wire i_reset,
    input wire [15:0] i_sw,
    input wire [4:0] i_btn,
    output wire [15:0] o_led,
    output wire uart_tx,
    output wire [7:0] sev_seg_an,
    output wire [6:0] sev_seg_ca
    );

    wire [15:0]  gpio_out;
    always @(posedge i_clk) begin
       o_led[15:0] <= gpio_out[15:0];
    end

    rv_soc top(
        .clk (i_clk),
        .reset (i_reset),
        .i_data ({i_btn[4:0], i_sw[15:0]}),
        .o_data (gpio_out),
        .uart_tx (uart_tx),
        .sev_seg_an (sev_seg_an),
        .sev_seg_ca (sev_seg_ca)
    );
endmodule
