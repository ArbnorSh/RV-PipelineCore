library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.all;

entity register_file is
    Port ( clk : in STD_LOGIC;
           write_enable : in STD_LOGIC;
           a1 : in STD_LOGIC_VECTOR (4 downto 0);
           a2 : in STD_LOGIC_VECTOR (4 downto 0);
           a3 : in STD_LOGIC_VECTOR (4 downto 0);
           write_data : in STD_LOGIC_VECTOR (31 downto 0);
           rd1 : out STD_LOGIC_VECTOR (31 downto 0);
           rd2 : out STD_LOGIC_VECTOR (31 downto 0));
end register_file;

architecture Behavioral of register_file is
    type reg_mem_t is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    
    signal reg_mem: reg_mem_t;
begin

    process(clk, write_enable)
    begin
        
        if rising_edge(clk) and write_enable = '1' then
            reg_mem(to_integer(a3)) <= write_data;
        end if;
    
    end process;
    
    process(a1, a2)
    begin
    
        if (to_integer(a1) = 0) then
            rd1 <= (others => '0');
        else
            rd1 <= reg_mem(to_integer(a1));
        end if;
        
        if (to_integer(a2) = 0) then
            rd2 <= (others => '0');
        else
            rd2 <= reg_mem(to_integer(a2));
        end if;
    
    
    end process;


end Behavioral;
