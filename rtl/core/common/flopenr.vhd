library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity flopenr is
    generic(width: integer := 8);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable : in STD_LOGIC;
           d : in STD_LOGIC_VECTOR (width - 1 downto 0);
           q : out STD_LOGIC_VECTOR (width - 1 downto 0));
end flopenr;

architecture Behavioral of flopenr is

begin
    
    process(clk, reset)
    begin
    
        if reset = '1' then
            q <= (others => '0');
        elsif rising_edge(clk) and enable = '1' then
            q <= d;
        end if;
        
    end process;

end Behavioral;