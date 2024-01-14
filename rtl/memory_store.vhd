library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory_store is
    Port ( write_data : in STD_LOGIC_VECTOR (31 downto 0);
           funct3 : in STD_LOGIC_VECTOR (2 downto 0);
           addr : in STD_LOGIC_VECTOR(1 downto 0);
           mem_write: in STD_LOGIC;
           write_data_output : out STD_LOGIC_VECTOR (31 downto 0));
end memory_store;

architecture Behavioral of memory_store is

begin

    process(all)
    begin
    
        if mem_write then 
    
            case funct3(1 downto 0) is
               -- store byte
                when "00" =>
                    
                    case addr is
                        when "00" => write_data_output <= ( 31 downto 8 => '0', 7 downto 0 => write_data(7 downto 0));
                        when "01" => write_data_output <= ( 31 downto 16 => '0', 15 downto 8 => write_data(7 downto 0), 7 downto 0 => '0');
                        when "10" => write_data_output <= ( 31 downto 24 => '0', 23 downto 16 => write_data(7 downto 0), 15 downto 0 => '0');
                        when "11" => write_data_output <= ( 31 downto 24 => write_data(7 downto 0), 23 downto 0 => '0');
                        when others => write_data_output <= (others => '0');
                    end case;
                
                -- store half word
                when "01" =>
                
                    case addr(1) is
                        when '0' => write_data_output <= ( 31 downto 16 => '0', 15 downto 0 => write_data(15 downto 0));
                        when '1' => write_data_output <= ( 31 downto 16 => write_data(15 downto 0), 15 downto 0 => '0');
                        when others => write_data_output <= (others => '0');
                    end case;
                
                when "10" =>
                    write_data_output <= write_data;
                
                when others =>
                    write_data_output <= (others => '0');
            
            end case;
        
        end if;
            
    end process;

end Behavioral;
