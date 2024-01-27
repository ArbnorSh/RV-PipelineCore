library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory_decoder is
    Port ( mem_write : in STD_LOGIC;
           funct3 : in STD_LOGIC_VECTOR (2 downto 0);
           read_addr : in STD_LOGIC_VECTOR (1 downto 0);
           mem_control : out STD_LOGIC_VECTOR (3 downto 0));
end memory_decoder;

architecture Behavioral of memory_decoder is

begin

    process(mem_write, funct3, read_addr)
    begin
    
        if mem_write = '1' then 
            case funct3 is
                -- sb
                when "000" =>
                    case read_addr is
                        when "00" =>
                            mem_control <= "0001";                        
                        when "01" =>
                            mem_control <= "0010";  
                        when "10" =>
                            mem_control <= "0100";
                        when "11" =>
                            mem_control <= "1000";
                        when others =>
                            mem_control <= b"----";
                    end case;
                -- sh
                when "001" =>
                    case read_addr(1) is
                        when '0' =>
                            mem_control <= "0011";                        
                        when '1' =>
                            mem_control <= "1100";
                        when others =>
                            mem_control <= b"----";
                    end case;
                -- sw
                when others =>
                    mem_control <= "1111";
            end case;
        else
            mem_control <= b"----";
        end if;
    
    end process;


end Behavioral;