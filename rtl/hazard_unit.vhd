library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_unit is
    Port ( rs1_d, rs2_d, rs1_e, rs2_e, rd_e, rd_m, rd_w : in STD_LOGIC_VECTOR (4 downto 0);
           pc_src_e, result_src_b0_e : in STD_LOGIC;
           reg_write_m, reg_write_w : in STD_LOGIC;
           forward_a_e, forward_b_e : out STD_LOGIC_VECTOR (1 downto 0);
           stall_f, stall_d, flush_d, flush_e : out STD_LOGIC);
end hazard_unit;

architecture Behavioral of hazard_unit is
    signal lw_stall_d: std_logic;
begin

    process(all)
    begin
        
        if rs1_e /= 5b"0" then
            if rs1_e = rd_m and reg_write_m = '1' then
                forward_a_e <= "10";
            elsif rs1_e = rd_w and reg_write_w = '1' then
                forward_a_e <= "01";
            else
                forward_a_e <= "00";
            end if;
        else
            forward_a_e <= "00";
        end if;
        
        if rs2_e /= 5b"0" then
            if rs2_e = rd_m and reg_write_m = '1' then
                forward_b_e <= "10";
            elsif rs2_e = rd_w and reg_write_w = '1' then
                forward_b_e <= "01";
            else
                forward_b_e <= "00";
            end if;
        else
            forward_b_e <= "00";
        end if;
        
        if result_src_b0_e = '1' then
            if rd_e = rs1_d or rd_e = rs2_d then
                lw_stall_d <= '1';
            else
                lw_stall_d <= '0';
            end if;
        else
            lw_stall_d <= '0';
        end if;
        
    end process;
    
    stall_d <= lw_stall_d;
    stall_f <= lw_stall_d;
    flush_d <= pc_src_e;
    flush_e <= lw_stall_d or pc_src_e;


end Behavioral;
