module rvsocsim(
    input wire i_clk,
    input wire i_reset,
    input wire [15:0] i_sw,
    output wire [15:0] o_led,
    output wire [7:0] uart_tx
    );

    wire [15:0]  gpio_out;
    always @(posedge i_clk) begin
       o_led[15:0] <= gpio_out[15:0];
    end

    rv_soc top(
        .clk (i_clk),
        .reset (i_reset),
        .i_data (i_sw),
        .o_data (gpio_out),
        .uart_tx (uart_tx)
    );
endmodule
