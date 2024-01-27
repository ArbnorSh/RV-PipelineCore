library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux3 is
    generic(width : integer := 8);
    Port ( a : in STD_LOGIC_VECTOR (width - 1 downto 0);
           b : in STD_LOGIC_VECTOR (width - 1 downto 0);
           c : in STD_LOGIC_VECTOR (width - 1 downto 0);
           s : in STD_LOGIC_VECTOR (1 downto 0);
           y : out STD_LOGIC_VECTOR (width - 1 downto 0));
end mux3;

architecture Behavioral of mux3 is

begin

    y <= a when s = "00" else
         b when s = "01" else
         c;

end Behavioral;
