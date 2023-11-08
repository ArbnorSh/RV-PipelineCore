library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity floprc is
   generic(width: integer := 8);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           clear : in STD_LOGIC;
           d : in STD_LOGIC_VECTOR (width - 1 downto 0);
           q : out STD_LOGIC_VECTOR (width - 1 downto 0));
end floprc;

architecture Behavioral of floprc is

begin

  process (clk, reset)
  begin
    
    if rising_edge(clk) or rising_edge(reset) then
      if reset = '1' then
        q <= (others => '0');
      else
        if clear = '1' then
          q <= (others => '0');
        else
          q <= d;
        end if;
      end if;
    end if;
  
  end process;

end Behavioral;
