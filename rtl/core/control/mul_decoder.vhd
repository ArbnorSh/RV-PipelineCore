library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mul_decoder is
    Port ( op : in STD_LOGIC_VECTOR(6 downto 0);
           funct3 : in STD_LOGIC_VECTOR (2 downto 0);
           funct7_0 : in STD_LOGIC;
           mul_instr : out STD_LOGIC);
end mul_decoder;

architecture Behavioral of mul_decoder is

begin

    process(all)
    begin

        if op = "0110011" and funct7_0 = '1' and (funct3 = "000" or 
           funct3 = "001" or funct3 = "010" or funct3 = "011") then
            mul_instr <= '1';
        else
            mul_instr <= '0';
        end if;
    
    end process;


end Behavioral;
