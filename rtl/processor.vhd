library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity processor is
    Port ( wb_clk : in STD_LOGIC;
           wb_reset : in STD_LOGIC;
           
           -- Instruction Wishbone Port
           instr_wb_adr : out STD_LOGIC_VECTOR(31 downto 0);
           instr_wb_data : in STD_LOGIC_VECTOR(31 downto 0);
           instr_wb_cyc : out STD_LOGIC;
           instr_wb_stb : out STD_LOGIC;
           instr_wb_ack : in STD_LOGIC;
           
           -- Data Wishbone Port
           d_wb_adr : out STD_LOGIC_VECTOR(31 downto 0);
           d_wb_data_w : out STD_LOGIC_VECTOR(31 downto 0);
           d_wb_data_r : in STD_LOGIC_VECTOR(31 downto 0);
           d_wb_cyc : out STD_LOGIC;
           d_wb_stb : out STD_LOGIC;
           d_wb_we : out STD_LOGIC;
           d_wb_sel : out STD_LOGIC_VECTOR(3 downto 0);
           d_wb_ack : in STD_LOGIC);
end processor;

architecture Behavioral of processor is
    component core_riscv is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           -- Instruction Wishbone Port
           instr_adr : out STD_LOGIC_VECTOR(31 downto 0);
           instr_data : in STD_LOGIC_VECTOR(31 downto 0);
           instr_valid : out STD_LOGIC;
           instr_ack : in STD_LOGIC;
           
           -- Data Wishbone Port
           d_adr : out STD_LOGIC_VECTOR(31 downto 0);
           d_data_w : out STD_LOGIC_VECTOR(31 downto 0);
           d_data_r : in STD_LOGIC_VECTOR(31 downto 0);
           d_sel : out STD_LOGIC_VECTOR(3 downto 0);
           d_we : out STD_LOGIC;
           d_valid : out STD_LOGIC;
           d_ack : in STD_LOGIC);
    end component;
    
    signal instr_adr, instr_data : std_logic_vector(31 downto 0);
    signal instr_valid, instr_ack : std_logic;
    
    signal d_adr, d_data_w, d_data_r: std_logic_vector(31 downto 0);
    signal d_sel: std_logic_vector(3 downto 0);
    signal d_we, d_valid, d_ack : std_logic;
    
    constant WB_IDLE : std_logic := '0';
    constant WB_ACTIVE : std_logic := '1';
    signal instr_port_state : std_logic;
    signal d_port_state : std_logic;
    
begin

    riscv: core_riscv port map(
        clk => wb_clk, 
        reset => wb_reset,
         
        instr_adr => instr_adr, 
        instr_data => instr_data,
        instr_valid => instr_valid,
        instr_ack => instr_ack,
        
        d_adr => d_adr, 
        d_data_w => d_data_w,
        d_data_r => d_data_r,
        d_sel => d_sel,
        d_we => d_we,
        d_valid => d_valid,
        d_ack => d_ack
        );
     
    -- Instruction Port Wishbone
    instr_ack <= instr_wb_ack;
    instr_data <= instr_wb_data;
    
    instr_port_state <= WB_IDLE;
    
    process(wb_clk)
    begin
    
        if wb_reset then
            instr_wb_adr <= (others => '0');
            instr_wb_cyc <= '0';
            instr_wb_stb <= '0';
            instr_port_state <= WB_IDLE;
        else
            case instr_port_state is
                when WB_IDLE =>
                    
                    if instr_valid then
                        instr_wb_adr <= instr_adr;
                        instr_wb_cyc <= '1';
                        instr_wb_stb <= '1';
                        instr_port_state <= WB_ACTIVE;
                    else
                        instr_wb_cyc <= '0';
                        instr_wb_stb <= '0';
                    end if;
                    
                when WB_ACTIVE =>
                    
                    if instr_wb_ack then
                        instr_wb_cyc <= '0';
                        instr_wb_stb <= '0';
                        instr_port_state <= WB_IDLE;
                    end if;
                
                when others =>
                    instr_port_state <= WB_IDLE;
            end case;
        
        end if;
    
    end process;
    
    -- DATA Port Wishbone
    d_ack <= d_wb_ack;
    d_data_r <= d_wb_data_r;
    
    d_port_state <= WB_IDLE;
    
    process(wb_clk)
    begin
    
        if wb_reset then
            d_wb_adr <= (others => '0');
            d_wb_data_w <= (others => '0');
            d_wb_cyc <= '0';
            d_wb_stb <= '0';
            d_wb_we <= '0';
            d_wb_sel <= (others => '0');
            d_port_state <= WB_IDLE;
        else
            case d_port_state is
                when WB_IDLE =>
                    
                    if d_valid then
                        d_wb_adr <= d_adr;
                        d_wb_data_w <= d_data_w;
                        d_wb_we <= d_we;
                        d_wb_sel <= d_sel;
                        d_wb_cyc <= '1';
                        d_wb_stb <= '1';
                        d_port_state <= WB_ACTIVE;
                    else
                        d_wb_cyc <= '0';
                        d_wb_stb <= '0';
                        d_wb_we <= '0';
                    end if;
                    
                when WB_ACTIVE =>
                    
                    if d_wb_ack then
                        d_wb_cyc <= '0';
                        d_wb_stb <= '0';
                        d_wb_we <= '0';
                        d_port_state <= WB_IDLE;
                    end if;
                
                when others =>
                    d_port_state <= WB_IDLE;
            end case;
        
        end if;
    
    end process;

end Behavioral;
