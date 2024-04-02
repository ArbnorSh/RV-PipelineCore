`default_nettype none
module rv_nexys(
    input wire sys_clk,
    input wire reset_n,
    input wire [20:0] i_data,
    output wire [15:0] o_data,
    output wire uart_tx,
    output wire [7:0] sev_seg_an,
    output wire [6:0] sev_seg_ca
    );
    
    wire wb_clk;
    wire wb_rst = ~reset_n;

    clk_wiz_0 system_clk(
        .clk_out1(wb_clk),
        .reset (wb_rst),
        .locked (),
        .clk_in1(sys_clk)
    );

    rv_soc top(
        .clk (wb_clk),
        .reset (wb_rst),
        .i_data (i_data),
        .o_data (gpio_out),
        .uart_tx (uart_tx),
        .sev_seg_an (sev_seg_an),
        .sev_seg_ca (sev_seg_ca)
    );

endmodule
