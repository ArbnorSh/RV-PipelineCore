wire [31:0] wb_ibus_adr;
wire [31:0] wb_ibus_dat;
wire  [3:0] wb_ibus_sel;
wire        wb_ibus_we;
wire        wb_ibus_cyc;
wire        wb_ibus_stb;
wire  [2:0] wb_ibus_cti;
wire  [1:0] wb_ibus_bte;
wire [31:0] wb_ibus_rdt;
wire        wb_ibus_ack;
wire        wb_ibus_err;
wire        wb_ibus_rty;
wire [31:0] wb_dbus_adr;
wire [31:0] wb_dbus_dat;
wire  [3:0] wb_dbus_sel;
wire        wb_dbus_we;
wire        wb_dbus_cyc;
wire        wb_dbus_stb;
wire  [2:0] wb_dbus_cti;
wire  [1:0] wb_dbus_bte;
wire [31:0] wb_dbus_rdt;
wire        wb_dbus_ack;
wire        wb_dbus_err;
wire        wb_dbus_rty;
wire [31:0] wb_rom_adr;
wire [31:0] wb_rom_dat;
wire  [3:0] wb_rom_sel;
wire        wb_rom_we;
wire        wb_rom_cyc;
wire        wb_rom_stb;
wire  [2:0] wb_rom_cti;
wire  [1:0] wb_rom_bte;
wire [31:0] wb_rom_rdt;
wire        wb_rom_ack;
wire        wb_rom_err;
wire        wb_rom_rty;
wire [31:0] wb_ram_adr;
wire [31:0] wb_ram_dat;
wire  [3:0] wb_ram_sel;
wire        wb_ram_we;
wire        wb_ram_cyc;
wire        wb_ram_stb;
wire  [2:0] wb_ram_cti;
wire  [1:0] wb_ram_bte;
wire [31:0] wb_ram_rdt;
wire        wb_ram_ack;
wire        wb_ram_err;
wire        wb_ram_rty;
wire [31:0] wb_gpio_adr;
wire [31:0] wb_gpio_dat;
wire  [3:0] wb_gpio_sel;
wire        wb_gpio_we;
wire        wb_gpio_cyc;
wire        wb_gpio_stb;
wire  [2:0] wb_gpio_cti;
wire  [1:0] wb_gpio_bte;
wire [31:0] wb_gpio_rdt;
wire        wb_gpio_ack;
wire        wb_gpio_err;
wire        wb_gpio_rty;
wire [31:0] wb_uart_adr;
wire [31:0] wb_uart_dat;
wire  [3:0] wb_uart_sel;
wire        wb_uart_we;
wire        wb_uart_cyc;
wire        wb_uart_stb;
wire  [2:0] wb_uart_cti;
wire  [1:0] wb_uart_bte;
wire [31:0] wb_uart_rdt;
wire        wb_uart_ack;
wire        wb_uart_err;
wire        wb_uart_rty;

wb_intercon wb_intercon0
   (.wb_clk_i      (wb_clk),
    .wb_rst_i      (wb_rst),
    .wb_ibus_adr_i (wb_ibus_adr),
    .wb_ibus_dat_i (wb_ibus_dat),
    .wb_ibus_sel_i (wb_ibus_sel),
    .wb_ibus_we_i  (wb_ibus_we),
    .wb_ibus_cyc_i (wb_ibus_cyc),
    .wb_ibus_stb_i (wb_ibus_stb),
    .wb_ibus_cti_i (wb_ibus_cti),
    .wb_ibus_bte_i (wb_ibus_bte),
    .wb_ibus_rdt_o (wb_ibus_rdt),
    .wb_ibus_ack_o (wb_ibus_ack),
    .wb_ibus_err_o (wb_ibus_err),
    .wb_ibus_rty_o (wb_ibus_rty),
    .wb_dbus_adr_i (wb_dbus_adr),
    .wb_dbus_dat_i (wb_dbus_dat),
    .wb_dbus_sel_i (wb_dbus_sel),
    .wb_dbus_we_i  (wb_dbus_we),
    .wb_dbus_cyc_i (wb_dbus_cyc),
    .wb_dbus_stb_i (wb_dbus_stb),
    .wb_dbus_cti_i (wb_dbus_cti),
    .wb_dbus_bte_i (wb_dbus_bte),
    .wb_dbus_rdt_o (wb_dbus_rdt),
    .wb_dbus_ack_o (wb_dbus_ack),
    .wb_dbus_err_o (wb_dbus_err),
    .wb_dbus_rty_o (wb_dbus_rty),
    .wb_rom_adr_o  (wb_rom_adr),
    .wb_rom_dat_o  (wb_rom_dat),
    .wb_rom_sel_o  (wb_rom_sel),
    .wb_rom_we_o   (wb_rom_we),
    .wb_rom_cyc_o  (wb_rom_cyc),
    .wb_rom_stb_o  (wb_rom_stb),
    .wb_rom_cti_o  (wb_rom_cti),
    .wb_rom_bte_o  (wb_rom_bte),
    .wb_rom_rdt_i  (wb_rom_rdt),
    .wb_rom_ack_i  (wb_rom_ack),
    .wb_rom_err_i  (wb_rom_err),
    .wb_rom_rty_i  (wb_rom_rty),
    .wb_ram_adr_o  (wb_ram_adr),
    .wb_ram_dat_o  (wb_ram_dat),
    .wb_ram_sel_o  (wb_ram_sel),
    .wb_ram_we_o   (wb_ram_we),
    .wb_ram_cyc_o  (wb_ram_cyc),
    .wb_ram_stb_o  (wb_ram_stb),
    .wb_ram_cti_o  (wb_ram_cti),
    .wb_ram_bte_o  (wb_ram_bte),
    .wb_ram_rdt_i  (wb_ram_rdt),
    .wb_ram_ack_i  (wb_ram_ack),
    .wb_ram_err_i  (wb_ram_err),
    .wb_ram_rty_i  (wb_ram_rty),
    .wb_gpio_adr_o (wb_gpio_adr),
    .wb_gpio_dat_o (wb_gpio_dat),
    .wb_gpio_sel_o (wb_gpio_sel),
    .wb_gpio_we_o  (wb_gpio_we),
    .wb_gpio_cyc_o (wb_gpio_cyc),
    .wb_gpio_stb_o (wb_gpio_stb),
    .wb_gpio_cti_o (wb_gpio_cti),
    .wb_gpio_bte_o (wb_gpio_bte),
    .wb_gpio_rdt_i (wb_gpio_rdt),
    .wb_gpio_ack_i (wb_gpio_ack),
    .wb_gpio_err_i (wb_gpio_err),
    .wb_gpio_rty_i (wb_gpio_rty),
    .wb_uart_adr_o (wb_uart_adr),
    .wb_uart_dat_o (wb_uart_dat),
    .wb_uart_sel_o (wb_uart_sel),
    .wb_uart_we_o  (wb_uart_we),
    .wb_uart_cyc_o (wb_uart_cyc),
    .wb_uart_stb_o (wb_uart_stb),
    .wb_uart_cti_o (wb_uart_cti),
    .wb_uart_bte_o (wb_uart_bte),
    .wb_uart_rdt_i (wb_uart_rdt),
    .wb_uart_ack_i (wb_uart_ack),
    .wb_uart_err_i (wb_uart_err),
    .wb_uart_rty_i (wb_uart_rty));

