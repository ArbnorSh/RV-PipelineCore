library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mask_extend is
    Port ( in_data : in STD_LOGIC_VECTOR (31 downto 0);
           control : in STD_LOGIC_VECTOR (2 downto 0);
           out_data : out STD_LOGIC_VECTOR (31 downto 0));
end mask_extend;

architecture Behavioral of mask_extend is
    signal masked_output: std_logic_vector(31 downto 0);
begin
    
    process(in_data, control)
    begin
    
        case control is
            -- lb
            when "001" =>
                out_data <= ( 31 downto 8 => in_data(7), 7 downto 0 => in_data(7 downto 0));
            -- lh
            when "010" =>
                out_data <= ( 31 downto 16 => in_data(15), 15 downto 0 => in_data(15 downto 0));
            -- lbu
            when "011" =>
                out_data <= ( 31 downto 8 => '0', 7 downto 0 => in_data(7 downto 0));
            -- lhu
            when "100" =>
                out_data <= ( 31 downto 16 => '0', 15 downto 0 => in_data(15 downto 0));
            when others =>
                out_data <= in_data;
        end case;
    
    end process;


end Behavioral;