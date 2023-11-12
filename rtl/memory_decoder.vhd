library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory_decoder is
    Port ( mem_write : in STD_LOGIC;
           funct3 : in STD_LOGIC_VECTOR (2 downto 0);
           mem_control : out STD_LOGIC_VECTOR (3 downto 0));
end memory_decoder;

architecture Behavioral of memory_decoder is

begin

    process(mem_write, funct3)
    begin
    
        if mem_write = '1' then 
            case funct3 is
                when "000" =>
                    mem_control <= "0001";
                when "001" =>
                    mem_control <= "0011";
                when others =>
                    mem_control <= "1111";
            end case;
        else
            mem_control <= b"----";
        end if;
    
    end process;


end Behavioral;