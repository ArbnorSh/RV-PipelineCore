`default_nettype none
module rv_soc(
    input wire clk,
    input wire reset,
    input wire [31:0] i_data,
    output wire [31:0] o_data,
    output wire uart_tx,
    output wire [7:0] sev_seg_an,
    output wire [6:0] sev_seg_ca
    );
    
    wire    [31:0]  proc_instr_wb_data_w     = 32'h000000;
    wire    [3:0]   proc_instr_wb_sel        = 4'b1111;
    
    wire wb_clk = clk;
    wire wb_rst = reset;
    
`include "wb_intercon.vh"

   assign wb_ibus_cti = 3'b000;
   assign wb_ibus_bte = 2'b00;
   assign wb_ibus_dat = proc_instr_wb_data_w;
   assign wb_ibus_sel = proc_instr_wb_sel;
   
   assign wb_dbus_cti = 3'b000;
   assign wb_dbus_bte = 2'b00;
   
   wire ext_int;
   wire time_int;
       
    processor core(
        .wb_clk (wb_clk),
        .wb_reset (wb_rst),
        
        .interrupt_external (ext_int),
        .interrupt_timer (time_int),
        
        .instr_wb_adr (wb_ibus_adr),
        .instr_wb_data (wb_ibus_rdt),
        .instr_wb_cyc (wb_ibus_cyc),
        .instr_wb_stb (wb_ibus_stb),
        .instr_wb_ack (wb_ibus_ack),
        
        .d_wb_adr (wb_dbus_adr),
        .d_wb_data_w (wb_dbus_dat),
        .d_wb_data_r (wb_dbus_rdt),
        .d_wb_cyc (wb_dbus_cyc),
        .d_wb_stb (wb_dbus_stb),
        .d_wb_we (wb_dbus_we),
        .d_wb_sel (wb_dbus_sel),
        .d_wb_ack (wb_dbus_ack)
    );
    
    assign wb_rom_we = 0;
    
    rom_wb rom(
        .wb_clk (wb_clk),
        .wb_rst (wb_rst),
        
        .wb_adr (wb_rom_adr),
        .wb_data (wb_rom_rdt),
        .wb_cyc (wb_rom_cyc),
        .wb_stb (wb_rom_stb),
        .wb_ack (wb_rom_ack)
    );
    
    ram_wb ram(
        .wb_clk (wb_clk),
        .wb_rst (wb_rst),
        
        .wb_adr (wb_ram_adr),
        .wb_data_r (wb_ram_rdt),
        .wb_data_w (wb_ram_dat),
        .wb_we (wb_ram_we),
        .wb_sel (wb_ram_sel),
        .wb_cyc (wb_ram_cyc),
        .wb_stb (wb_ram_stb),
        .wb_ack (wb_ram_ack)
    );

    wire en_gpio;
    
    gpio_top gpio_module(
        .wb_clk_i     (wb_clk),
        .wb_rst_i     (wb_rst),
        
        .wb_cyc_i     (wb_gpio_cyc), 
        .wb_adr_i     (wb_gpio_adr),
        .wb_dat_i     (wb_gpio_dat),
        .wb_sel_i     (4'b1111),
        .wb_we_i      (wb_gpio_we), 
        .wb_stb_i     (wb_gpio_stb), 
        .wb_dat_o     (wb_gpio_rdt),
        .wb_ack_o     (wb_gpio_ack),
        .wb_err_o     (wb_gpio_err),
        .wb_inta_o    (ext_int),

        .ext_pad_i     (i_data[31:0]),
        .ext_pad_o     (o_data[31:0]),

        .ext_padoe_o   (en_gpio)
    );

    wire [7:0] uart_rdt;
    assign wb_uart_rdt = {24'd0, uart_rdt};
        
   uart_top uart16550_0(
      .wb_clk_i	(wb_clk),
      .wb_rst_i	(wb_rst),
      
      .wb_adr_i	(wb_uart_adr[4:2]),
      .wb_dat_i	(wb_uart_dat[7:0]),
      .wb_we_i	(wb_uart_we),
      .wb_cyc_i	(wb_uart_cyc),
      .wb_stb_i	(wb_uart_stb),
      .wb_sel_i	(4'b0),
      .wb_dat_o	(uart_rdt),
      .wb_ack_o	(wb_uart_ack),

      // Outputs
      .int_o     (),
      .stx_pad_o (uart_tx),
      .rts_pad_o (),
      .dtr_pad_o (),

      // Inputs
      .srx_pad_i (1'b0),
      .cts_pad_i (1'b0),
      .dsr_pad_i (1'b0),
      .ri_pad_i  (1'b0),
      .dcd_pad_i (1'b0)
   );

   wb_sevenseg sevenseg_controller(
    .i_wb_clk (wb_clk),
    .i_wb_rst (wb_rst),

    .i_wb_dat (wb_sevenseg_dat),
    .i_wb_sel (wb_sevenseg_sel),
    .i_wb_we  (wb_sevenseg_we),
    .i_wb_cyc (wb_sevenseg_cyc),
    .i_wb_stb (wb_sevenseg_stb),
    .o_wb_rdt (wb_sevenseg_rdt),
    .o_wb_ack (wb_sevenseg_ack),

    .o_ca (sev_seg_ca),
    .o_an (sev_seg_an)
   );

   ptc_top ptc(
    .wb_clk_i (wb_clk),
    .wb_rst_i (wb_rst),

    .wb_cyc_i (wb_ptc_cyc),
    .wb_adr_i (wb_ptc_adr),
    .wb_dat_i (wb_ptc_dat),
    .wb_sel_i (wb_ptc_sel),
    .wb_we_i  (wb_ptc_we),
    .wb_stb_i (wb_ptc_stb),
    .wb_dat_o (wb_ptc_rdt),
    .wb_ack_o (wb_ptc_ack),
    .wb_err_o (wb_ptc_err),

    .wb_inta_o (time_int),

    .gate_clk_pad_i (),
    .capt_pad_i (),
    .pwm_pad_o (),
    .oen_padoen_o ()
   );
    
endmodule
