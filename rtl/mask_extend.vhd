library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mask_extend is
    Port ( in_data : in STD_LOGIC_VECTOR (31 downto 0);
           address : in STD_LOGIC_VECTOR (1 downto 0);
           control : in STD_LOGIC_VECTOR (2 downto 0);
           is_load : in STD_LOGIC;
           out_data : out STD_LOGIC_VECTOR (31 downto 0);
           load_misaligned : out STD_LOGIC);
end mask_extend;

architecture Behavioral of mask_extend is
    signal masked_output: std_logic_vector(31 downto 0);
begin

    process(all)
    begin
    
        if is_load = '1' then
            -- check for alignment
            case control(1 downto 0) is
              when "00"   => load_misaligned <= '0';                        -- byte
              when "01"   => load_misaligned <= address(0);                 -- half-word
              when others => load_misaligned <= address(1) or address(0);   -- word
            end case;        
        end if;
    
    end process;
    
    process(in_data, control, address)
    begin
    
        case control(1 downto 0) is
            -- lb
            when "00" =>
                case address is
                    -- byte 0
                    when "00" => 
                        out_data(7 downto 0) <= in_data(7 downto 0);
                        out_data(31 downto 8) <= (others => ( (not control(2)) and in_data(7) ));
                    -- byte 1
                    when "01" => 
                        out_data(7 downto 0) <= in_data(15 downto 8);
                        out_data(31 downto 8) <= (others => ( (not control(2)) and in_data(15) ));
                    -- byte 2
                    when "10" => 
                        out_data(7 downto 0) <= in_data(23 downto 16);
                        out_data(31 downto 8) <= (others => ( (not control(2)) and in_data(23) ));
                    -- byte 3
                    when others => 
                        out_data(7 downto 0) <= in_data(31 downto 24);
                        out_data(31 downto 8) <= (others => ( (not control(2)) and in_data(31) ));
                end case;
            -- lh
            when "01" =>
                -- low half-word
                if address(1) = '0' then 
                    out_data(15 downto 0) <= in_data(15 downto 0);
                    out_data(31 downto 16) <= (others => ( (not control(2)) and in_data(15) ));
                else
                    out_data(15 downto 0) <= in_data(31 downto 16);
                    out_data(31 downto 16) <= (others => ( (not control(2)) and in_data(31) ));
                end if; 
            when others =>
                out_data <= in_data;
        end case;
    
    end process;


end Behavioral;
