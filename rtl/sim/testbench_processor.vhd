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
    
    component instruction_memory_wb is
        Port ( wb_clk : in STD_LOGIC;
               wb_rst : in STD_LOGIC;
               wb_adr : in STD_LOGIC_VECTOR (31 downto 0);
               wb_data : out STD_LOGIC_VECTOR (31 downto 0);
               wb_stb : in STD_LOGIC;
               wb_ack : out STD_LOGIC);
    end component;
    
    component data_memory_wb is
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
    
    signal clk, reset: std_logic;
    
    signal instr_wb_adr, instr_wb_data : std_logic_vector(31 downto 0);
    signal instr_wb_stb, instr_wb_cyc, instr_wb_ack: std_logic;
    
    signal d_wb_addr, d_wb_data_r, d_wb_data_w : std_logic_vector(31 downto 0);
    signal d_wb_we, d_wb_stb, d_wb_cyc, d_wb_ack: std_logic;
    signal d_wb_sel : std_logic_vector(3 downto 0);
begin
    
    dut: processor port map(
        wb_clk => clk,
        wb_reset => reset,
        
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
    
    instr_mem: instruction_memory_wb port map(
        wb_clk => clk,
        wb_rst => reset,
        
        wb_adr => instr_wb_adr,
        wb_data => instr_wb_data,
        wb_stb => instr_wb_stb and instr_wb_cyc,
        wb_ack => instr_wb_ack        
        );
        
    d_mem: data_memory_wb port map(
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
    
    process(clk) begin
        
        if falling_edge(clk) and d_wb_we = '1' then
            if d_wb_addr = 100 and d_wb_data_w = 25 then
                report "Simulated program successfuly" severity failure;
            end if;
        end if;
        
--         if falling_edge(clk) and d_wb_we = '1' then
--            case to_integer(d_wb_addr) is
--                when 80 =>
--                    -- r
--                    if to_integer(d_wb_data_w) = 16#72# then
--                        risc_string <= risc_string + 1;
--                    end if;
--                when 81 =>
--                    -- i
--                    if to_integer(d_wb_data_w) = 16#69# then
--                        risc_string <= risc_string + 1;
--                    end if;
--                when 82 =>
--                    -- s
--                    if to_integer(d_wb_data_w) = 16#73# then
--                        risc_string <= risc_string + 1;
--                    end if;
--                when 83 =>
--                    -- c
--                    if to_integer(d_wb_data_w) = 16#63# then
--                        risc_string <= risc_string + 1;
--                    end if;
--               when 84 =>
--                    -- v
--                    if to_integer(d_wb_data_w) = 16#76# then
--                        risc_string <= risc_string + 1;
--                    end if;
--               when 85 =>
--                    -- '\0'
--                    if to_integer(d_wb_data_w) = 0 then
--                        risc_string <= risc_string + 1;
--                    end if;
--               when others =>

--            end case;
--        end if;

--        if risc_string = 6 then
--                report "Simulated program successfuly" severity failure;
--        end if;    
        
    end process;


end Behavioral;
