library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hazard_unit is
    Port ( clk, reset : in STD_LOGIC;
           rs1_d, rs2_d, rs1_e, rs2_e, rd_e, rd_m, rd_w : in STD_LOGIC_VECTOR (4 downto 0);
           pc_src_e, load_instr_e : in STD_LOGIC;
           csr_instr_e, csr_instr_w : in STD_LOGIC;
           load_store_m : in STD_LOGIC;
           reg_write_m, reg_write_w : in STD_LOGIC;
           instruction_ack, instruction_valid, data_ack : in STD_LOGIC;
           illegal_instruction_d, illegal_instruction_w : in STD_LOGIC;
           load_misaligned_m, store_misaligned_m : in STD_LOGIC;
           is_instr_exception_e, is_instr_exception_m: in STD_LOGIC;
           is_instr_exception_w, trap_caught : in STD_LOGIC;
           forward_a_e, forward_b_e : out STD_LOGIC_VECTOR (1 downto 0);
           stall_f, stall_d, stall_e, stall_m : out STD_LOGIC; 
           flush_d, flush_e, flush_m, flush_w: out STD_LOGIC;
           div_instr_d, div_completed_e : in STD_LOGIC);
end hazard_unit;

architecture Behavioral of hazard_unit is
    signal lw_stall_d, f_and_d_state, d_and_e_state: std_logic;
    signal ignore_instr_mem_handshake : std_logic := '0';
    signal raw_instr_mem_handshake, instr_mem_handshake, waiting_on_instruction: std_logic;
    signal csr_pending, div_pending : std_logic;
    signal jump_instr, pending_exception_f : std_logic;
    signal pending_exception_m : std_logic;
begin
    
    -- do not jump if jump instruction is invalid
    -- instruction in pipeline before jump has excepted
    jump_instr <= pc_src_e and (not is_instr_exception_e) and (not is_instr_exception_m) and (not is_instr_exception_w);

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
        
        if load_instr_e = '1' then
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
                        if jump_instr or trap_caught then
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
    
    -- Pending CSR instruction
    -- Stall the pipeline until CSR
    -- instruction is retired
    process(clk)
    begin
        
        if rising_edge(clk) then
        
            if reset then
                csr_pending <= '0';
            elsif csr_instr_e = '1' then
                csr_pending <= '1';
            elsif csr_instr_w = '1' then
                csr_pending <= '0';
            end if;
        
        end if;
        
    end process;

    -- Pending div instruction
    -- out-of-pipeline div unit
    process(clk)
    begin
        
        if rising_edge(clk) then
        
            if reset then
                div_pending <= '0';
            elsif div_instr_d = '1' then
                div_pending <= '1';
            elsif div_completed_e = '1' then
                div_pending <= '0';
            end if;
        
        end if;
        
    end process;

    process(clk)
    begin
        
        if rising_edge(clk) then
        
            if reset then
                pending_exception_f <= '0';
            elsif illegal_instruction_d = '1' then
                pending_exception_f <= '1';
            elsif illegal_instruction_w = '1' then
                pending_exception_f <= '0';
            end if;
        
        end if;
        
    end process;
    
    process(clk)
    begin
        
        if rising_edge(clk) then
        
            if reset then
                pending_exception_m <= '0';
            elsif is_instr_exception_m then
                pending_exception_m <= '1';
            elsif is_instr_exception_w then
                pending_exception_m <= '0';
            end if;
        
        end if;
        
    end process;
    
    raw_instr_mem_handshake <= instruction_ack and instruction_valid;    
    instr_mem_handshake <= raw_instr_mem_handshake and (not ignore_instr_mem_handshake);
    waiting_on_instruction <= (not instr_mem_handshake) and instruction_valid;
    
    stall_f <= lw_stall_d or waiting_on_instruction or stall_d or csr_pending or 
               pending_exception_f or pending_exception_m;
    stall_d <= lw_stall_d or stall_e or csr_pending;
    stall_e <= stall_m or div_pending;
    stall_m <= load_store_m and (not data_ack);
    
    flush_d <= jump_instr or (waiting_on_instruction and not stall_d) or (pending_exception_f and not stall_d) or 
               pending_exception_m;
    flush_e <= lw_stall_d or jump_instr or csr_pending or pending_exception_m;
    flush_m <= pending_exception_m or div_pending;
    flush_w <= '0'; --stall_m;

end Behavioral;
