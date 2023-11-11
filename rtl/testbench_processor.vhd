library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.all;
use ieee.numeric_std.all;

entity testbench_cpu is
end testbench_cpu;

architecture Behavioral of testbench_cpu is
    component processor is
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               read_data : in STD_LOGIC_VECTOR (31 downto 0);
               mem_write : out STD_LOGIC;
               write_data : out STD_LOGIC_VECTOR (31 downto 0);
               data_address : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    signal mem_write: std_logic;
    signal data_address, read_data, write_data: std_logic_vector(31 downto 0);
    
    signal clk, reset: std_logic;
begin
    
    dut: processor port map(
        clk => clk,
        reset => reset,
        read_data => read_data,
        mem_write => mem_write,
        write_data => write_data,
        data_address => data_address
        );
    
    process begin
        clk <= '1';
        wait for 5 ns;
        
        clk <= '0';
        wait for 5 ns;
    end process;
    
    process begin
        reset <= '1';
        wait for 22 ns;
        
        reset <= '0';
        wait;
    end process;
    
    process(clk) begin
        
        if falling_edge(clk) and mem_write = '1' then
            if to_integer(data_address) = 132 and write_data = x"ABCDE02E" then
                report "Simulated program successfuly" severity failure;
            end if;
        end if;        
        
    end process;


end Behavioral;
