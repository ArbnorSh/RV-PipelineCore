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
wire [31:0] wb_irom_adr;
wire [31:0] wb_irom_dat;
wire  [3:0] wb_irom_sel;
wire        wb_irom_we;
wire        wb_irom_cyc;
wire        wb_irom_stb;
wire  [2:0] wb_irom_cti;
wire  [1:0] wb_irom_bte;
wire [31:0] wb_irom_rdt;
wire        wb_irom_ack;
wire        wb_irom_err;
wire        wb_irom_rty;
wire [31:0] wb_drom_adr;
wire [31:0] wb_drom_dat;
wire  [3:0] wb_drom_sel;
wire        wb_drom_we;
wire        wb_drom_cyc;
wire        wb_drom_stb;
wire  [2:0] wb_drom_cti;
wire  [1:0] wb_drom_bte;
wire [31:0] wb_drom_rdt;
wire        wb_drom_ack;
wire        wb_drom_err;
wire        wb_drom_rty;
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
wire [31:0] wb_sevenseg_adr;
wire [31:0] wb_sevenseg_dat;
wire  [3:0] wb_sevenseg_sel;
wire        wb_sevenseg_we;
wire        wb_sevenseg_cyc;
wire        wb_sevenseg_stb;
wire  [2:0] wb_sevenseg_cti;
wire  [1:0] wb_sevenseg_bte;
wire [31:0] wb_sevenseg_rdt;
wire        wb_sevenseg_ack;
wire        wb_sevenseg_err;
wire        wb_sevenseg_rty;
wire [31:0] wb_ptc_adr;
wire [31:0] wb_ptc_dat;
wire  [3:0] wb_ptc_sel;
wire        wb_ptc_we;
wire        wb_ptc_cyc;
wire        wb_ptc_stb;
wire  [2:0] wb_ptc_cti;
wire  [1:0] wb_ptc_bte;
wire [31:0] wb_ptc_rdt;
wire        wb_ptc_ack;
wire        wb_ptc_err;
wire        wb_ptc_rty;

wb_intercon wb_intercon0
   (.wb_clk_i          (wb_clk),
    .wb_rst_i          (wb_rst),
    .wb_ibus_adr_i     (wb_ibus_adr),
    .wb_ibus_dat_i     (wb_ibus_dat),
    .wb_ibus_sel_i     (wb_ibus_sel),
    .wb_ibus_we_i      (wb_ibus_we),
    .wb_ibus_cyc_i     (wb_ibus_cyc),
    .wb_ibus_stb_i     (wb_ibus_stb),
    .wb_ibus_cti_i     (wb_ibus_cti),
    .wb_ibus_bte_i     (wb_ibus_bte),
    .wb_ibus_rdt_o     (wb_ibus_rdt),
    .wb_ibus_ack_o     (wb_ibus_ack),
    .wb_ibus_err_o     (wb_ibus_err),
    .wb_ibus_rty_o     (wb_ibus_rty),
    .wb_dbus_adr_i     (wb_dbus_adr),
    .wb_dbus_dat_i     (wb_dbus_dat),
    .wb_dbus_sel_i     (wb_dbus_sel),
    .wb_dbus_we_i      (wb_dbus_we),
    .wb_dbus_cyc_i     (wb_dbus_cyc),
    .wb_dbus_stb_i     (wb_dbus_stb),
    .wb_dbus_cti_i     (wb_dbus_cti),
    .wb_dbus_bte_i     (wb_dbus_bte),
    .wb_dbus_rdt_o     (wb_dbus_rdt),
    .wb_dbus_ack_o     (wb_dbus_ack),
    .wb_dbus_err_o     (wb_dbus_err),
    .wb_dbus_rty_o     (wb_dbus_rty),
    .wb_irom_adr_o     (wb_irom_adr),
    .wb_irom_dat_o     (wb_irom_dat),
    .wb_irom_sel_o     (wb_irom_sel),
    .wb_irom_we_o      (wb_irom_we),
    .wb_irom_cyc_o     (wb_irom_cyc),
    .wb_irom_stb_o     (wb_irom_stb),
    .wb_irom_cti_o     (wb_irom_cti),
    .wb_irom_bte_o     (wb_irom_bte),
    .wb_irom_rdt_i     (wb_irom_rdt),
    .wb_irom_ack_i     (wb_irom_ack),
    .wb_irom_err_i     (wb_irom_err),
    .wb_irom_rty_i     (wb_irom_rty),
    .wb_drom_adr_o     (wb_drom_adr),
    .wb_drom_dat_o     (wb_drom_dat),
    .wb_drom_sel_o     (wb_drom_sel),
    .wb_drom_we_o      (wb_drom_we),
    .wb_drom_cyc_o     (wb_drom_cyc),
    .wb_drom_stb_o     (wb_drom_stb),
    .wb_drom_cti_o     (wb_drom_cti),
    .wb_drom_bte_o     (wb_drom_bte),
    .wb_drom_rdt_i     (wb_drom_rdt),
    .wb_drom_ack_i     (wb_drom_ack),
    .wb_drom_err_i     (wb_drom_err),
    .wb_drom_rty_i     (wb_drom_rty),
    .wb_ram_adr_o      (wb_ram_adr),
    .wb_ram_dat_o      (wb_ram_dat),
    .wb_ram_sel_o      (wb_ram_sel),
    .wb_ram_we_o       (wb_ram_we),
    .wb_ram_cyc_o      (wb_ram_cyc),
    .wb_ram_stb_o      (wb_ram_stb),
    .wb_ram_cti_o      (wb_ram_cti),
    .wb_ram_bte_o      (wb_ram_bte),
    .wb_ram_rdt_i      (wb_ram_rdt),
    .wb_ram_ack_i      (wb_ram_ack),
    .wb_ram_err_i      (wb_ram_err),
    .wb_ram_rty_i      (wb_ram_rty),
    .wb_gpio_adr_o     (wb_gpio_adr),
    .wb_gpio_dat_o     (wb_gpio_dat),
    .wb_gpio_sel_o     (wb_gpio_sel),
    .wb_gpio_we_o      (wb_gpio_we),
    .wb_gpio_cyc_o     (wb_gpio_cyc),
    .wb_gpio_stb_o     (wb_gpio_stb),
    .wb_gpio_cti_o     (wb_gpio_cti),
    .wb_gpio_bte_o     (wb_gpio_bte),
    .wb_gpio_rdt_i     (wb_gpio_rdt),
    .wb_gpio_ack_i     (wb_gpio_ack),
    .wb_gpio_err_i     (wb_gpio_err),
    .wb_gpio_rty_i     (wb_gpio_rty),
    .wb_uart_adr_o     (wb_uart_adr),
    .wb_uart_dat_o     (wb_uart_dat),
    .wb_uart_sel_o     (wb_uart_sel),
    .wb_uart_we_o      (wb_uart_we),
    .wb_uart_cyc_o     (wb_uart_cyc),
    .wb_uart_stb_o     (wb_uart_stb),
    .wb_uart_cti_o     (wb_uart_cti),
    .wb_uart_bte_o     (wb_uart_bte),
    .wb_uart_rdt_i     (wb_uart_rdt),
    .wb_uart_ack_i     (wb_uart_ack),
    .wb_uart_err_i     (wb_uart_err),
    .wb_uart_rty_i     (wb_uart_rty),
    .wb_sevenseg_adr_o (wb_sevenseg_adr),
    .wb_sevenseg_dat_o (wb_sevenseg_dat),
    .wb_sevenseg_sel_o (wb_sevenseg_sel),
    .wb_sevenseg_we_o  (wb_sevenseg_we),
    .wb_sevenseg_cyc_o (wb_sevenseg_cyc),
    .wb_sevenseg_stb_o (wb_sevenseg_stb),
    .wb_sevenseg_cti_o (wb_sevenseg_cti),
    .wb_sevenseg_bte_o (wb_sevenseg_bte),
    .wb_sevenseg_rdt_i (wb_sevenseg_rdt),
    .wb_sevenseg_ack_i (wb_sevenseg_ack),
    .wb_sevenseg_err_i (wb_sevenseg_err),
    .wb_sevenseg_rty_i (wb_sevenseg_rty),
    .wb_ptc_adr_o      (wb_ptc_adr),
    .wb_ptc_dat_o      (wb_ptc_dat),
    .wb_ptc_sel_o      (wb_ptc_sel),
    .wb_ptc_we_o       (wb_ptc_we),
    .wb_ptc_cyc_o      (wb_ptc_cyc),
    .wb_ptc_stb_o      (wb_ptc_stb),
    .wb_ptc_cti_o      (wb_ptc_cti),
    .wb_ptc_bte_o      (wb_ptc_bte),
    .wb_ptc_rdt_i      (wb_ptc_rdt),
    .wb_ptc_ack_i      (wb_ptc_ack),
    .wb_ptc_err_i      (wb_ptc_err),
    .wb_ptc_rty_i      (wb_ptc_rty));

