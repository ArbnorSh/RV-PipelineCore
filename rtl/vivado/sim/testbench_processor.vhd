library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.all;
use ieee.numeric_std.all;

entity testbench_processor is
end testbench_processor;

architecture Behavioral of testbench_processor is
    component processor is
        Port ( wb_clk : in STD_LOGIC;
               wb_reset : in STD_LOGIC;
               
               --Interrupts
               interrupt_external : in STD_LOGIC;
               interrupt_timer : in STD_LOGIC;
               
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
    end component;
    
    component rom_wb is
        generic(
        GEN_FROM_HEX_FILE: std_logic := '0';
        -- power of two
        SIZE_MEM    : natural := 1024
        );
        Port ( wb_clk : in STD_LOGIC;
               wb_rst : in STD_LOGIC;
               wb_adr : in STD_LOGIC_VECTOR (31 downto 0);
               wb_data : out STD_LOGIC_VECTOR (31 downto 0);
               wb_stb : in STD_LOGIC;
               wb_ack : out STD_LOGIC);
    end component;
    
    component ram_wb is
        generic(
        -- power of two
        SIZE_MEM    : natural := 1024
        );
        Port ( wb_clk : in STD_LOGIC;
               wb_rst : in STD_LOGIC;
               wb_adr : in STD_LOGIC_VECTOR (31 downto 0);
               wb_data_r : out STD_LOGIC_VECTOR (31 downto 0);
               wb_data_w : in STD_LOGIC_VECTOR (31 downto 0);
               wb_we : in STD_LOGIC;
               wb_sel : in  STD_LOGIC_VECTOR(3 downto 0);
               wb_stb : in STD_LOGIC;
               wb_ack : out STD_LOGIC);
    end component;
    
    signal risc_string: integer := 0;
    signal risc_csr: integer := 0;
    signal risc_except_1, risc_except_2 : integer := 0;
    
    signal clk, reset: std_logic;
    
    signal instr_wb_adr, instr_wb_data : std_logic_vector(31 downto 0);
    signal instr_wb_stb, instr_wb_cyc, instr_wb_ack: std_logic;
    
    signal d_wb_addr, d_wb_data_r, d_wb_data_w : std_logic_vector(31 downto 0);
    signal d_wb_we, d_wb_stb, d_wb_cyc, d_wb_ack: std_logic;
    signal d_wb_sel : std_logic_vector(3 downto 0);
    
    signal intr_ext, intr_timer : std_logic := '0';
begin
    
    dut: processor port map(
        wb_clk => clk,
        wb_reset => reset,
        
        interrupt_external => intr_ext,
        interrupt_timer => intr_timer,        
        
        instr_wb_adr => instr_wb_adr,
        instr_wb_data => instr_wb_data,
        instr_wb_cyc => instr_wb_stb,
        instr_wb_stb => instr_wb_cyc,
        instr_wb_ack => instr_wb_ack,
        
        d_wb_adr => d_wb_addr,
        d_wb_data_w => d_wb_data_w,
        d_wb_data_r => d_wb_data_r,
        d_wb_cyc => d_wb_cyc,
        d_wb_stb => d_wb_stb,
        d_wb_we => d_wb_we,
        d_wb_sel => d_wb_sel,
        d_wb_ack => d_wb_ack
        
        );
    
    instr_mem: rom_wb generic map(
        SIZE_MEM => 8 * 1024
    )
    port map(
        wb_clk => clk,
        wb_rst => reset,
        
        wb_adr => instr_wb_adr,
        wb_data => instr_wb_data,
        wb_stb => instr_wb_stb and instr_wb_cyc,
        wb_ack => instr_wb_ack        
        );
        
    d_mem: ram_wb generic map(
        SIZE_MEM => 8 * 1024
    )
    port map(
        wb_clk => clk,
        wb_rst => reset,
        
        wb_adr => d_wb_addr,
        wb_data_r => d_wb_data_r,
        wb_data_w => d_wb_data_w,
        wb_we => d_wb_we,
        wb_sel => d_wb_sel,
        wb_stb => d_wb_stb and d_wb_cyc,
        wb_ack => d_wb_ack
        );
        
    process begin
        clk <= '1';
        wait for 10 ns;
        
        clk <= '0';
        wait for 10 ns;
    end process;
    
    process begin
        reset <= '1';
        wait for 22 ns;
        
        reset <= '0';
        wait;
    end process;
    
    -- Interrupt Trigger
    process begin
        wait for 1000ns;
        intr_ext <= '1';
        
        wait for 1000ns;
        intr_ext <= '0';
        
        wait for 1000ns;
        intr_ext <= '1';
        
        wait for 1000ns;
        intr_ext <= '0';
    end process;
    
    process(clk) begin
        
        if falling_edge(clk) and d_wb_we = '1' then
            if d_wb_addr = X"80" and d_wb_data_w = X"8000000B" then
                risc_except_1 <= 1;
            end if;
        end if;
                
        if risc_except_1 = 1 then
                report "Simulated program successfuly" severity failure;
        end if;  
        
    end process;


end Behavioral;
