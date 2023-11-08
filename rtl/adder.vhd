library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.all;

entity adder is
    Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           y : out STD_LOGIC_VECTOR (31 downto 0));
end adder;

architecture Behavioral of adder is

begin

    y <= a + b;

end Behavioral;
