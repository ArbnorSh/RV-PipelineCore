library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edge_detector is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           d : in STD_LOGIC;
           edge_detected : out STD_LOGIC);
end edge_detector;

architecture Behavioral of edge_detector is
    signal first_reg, second_reg : std_logic;
begin
    
    process(clk)
    begin
       if rising_edge(clk) then
          if reset = '1' then
              first_reg <= '0';
              second_reg <= '0';
          else
              first_reg  <= d;
              second_reg  <= first_reg;
          end if;
      end if;
    end process;
    
    edge_detected <= first_reg and (not second_reg);

end Behavioral;
