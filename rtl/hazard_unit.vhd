library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_unit is
    Port ( clk, reset : in STD_LOGIC;
           rs1_d, rs2_d, rs1_e, rs2_e, rd_e, rd_m, rd_w : in STD_LOGIC_VECTOR (4 downto 0);
           pc_src_e, result_src_b0_e : in STD_LOGIC;
           load_store_m : in STD_LOGIC;
           reg_write_m, reg_write_w : in STD_LOGIC;
           instruction_ack, instruction_valid, data_ack : in STD_LOGIC;
           forward_a_e, forward_b_e : out STD_LOGIC_VECTOR (1 downto 0);
           stall_f, stall_d, stall_e, stall_m, flush_d, flush_e, flush_w: out STD_LOGIC);
end hazard_unit;

architecture Behavioral of hazard_unit is
    signal lw_stall_d, f_and_d_state, d_and_e_state: std_logic;
    signal ignore_instr_mem_handshake : std_logic := '0';
    signal raw_instr_mem_handshake, instr_mem_handshake, waiting_on_instruction: std_logic;
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
    
    process(clk)
    begin
        
        if rising_edge(clk) then
        
            if reset then
                ignore_instr_mem_handshake <= '0';
            else
                case ignore_instr_mem_handshake is
                    when '0' => 
                        if pc_src_e then
                            ignore_instr_mem_handshake <= '1';
                        end if;
    
                    when '1' =>  
                        if raw_instr_mem_handshake then
                            ignore_instr_mem_handshake <= '0';
                        end if;
                    when others =>
                        ignore_instr_mem_handshake <= '0';
                end case;
            end if;
        
        end if;
        
    end process;
    
    raw_instr_mem_handshake <= instruction_ack and instruction_valid;    
    instr_mem_handshake <= raw_instr_mem_handshake and (not ignore_instr_mem_handshake);
    waiting_on_instruction <= (not instr_mem_handshake) and instruction_valid;
    
    stall_f <= lw_stall_d or waiting_on_instruction or stall_d;
    stall_d <= lw_stall_d or stall_e;
    stall_e <= stall_m;
    stall_m <= load_store_m and (not data_ack);
    
    flush_d <= pc_src_e or (waiting_on_instruction and not stall_d);
    flush_e <= lw_stall_d or pc_src_e;
    flush_w <= stall_m;
    
--    stall_f <= lw_stall_d or waiting_on_instruction;
--    stall_d <= lw_stall_d or stall_e;
--    stall_e <= stall_m;
--    stall_m <= load_store_m and (not data_ack);
    
--    f_and_d_state <= '0' when stall_d = '1' else stall_f when not lw_stall_d else '0';
--    flush_d <= pc_src_e or f_and_d_state;
    
--    d_and_e_state <= '0' when stall_e = '1' else stall_d;
--    flush_e <= d_and_e_state or pc_src_e;
--    flush_w <= stall_m;


end Behavioral;
