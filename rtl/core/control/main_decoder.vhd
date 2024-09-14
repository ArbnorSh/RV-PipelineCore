-- SPDX-License-Identifier: BSD-3-Clause
-- 
-- Copyright (c) [2024], [Arbnor Shabani]
-- All rights reserved.
-- 
-- This code is licensed under the BSD 3-Clause License.
-- See the LICENSE file for more details.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main_decoder is
    Port ( op : in STD_LOGIC_VECTOR (6 downto 0);
           funct3 : in STD_LOGIC_VECTOR (2 downto 0);
           rs1, rd : in STD_LOGIC_VECTOR(4 downto 0);
           imm_i_type : in STD_LOGIC_VECTOR(11 downto 0);
           is_decode_flush_d : in STD_LOGIC;
           branch : out STD_LOGIC;
           jump : out STD_LOGIC;
           result_src : out STD_LOGIC_VECTOR (1 downto 0);
           mem_write : out STD_LOGIC;
           alu_src_a : out STD_LOGIC;
           alu_src_b : out STD_LOGIC;
           imm_src : out STD_LOGIC_VECTOR (2 downto 0);
           reg_write : out STD_LOGIC;
           alu_op : out STD_LOGIC_VECTOR (1 downto 0);
           load_instr : out STD_LOGIC;
           pc_target_src: out STD_LOGIC;
           load_store : out STD_LOGIC;
           csr_write : out STD_LOGIC;
           mret_instr : out STD_LOGIC;
           illegal_instruction : out STD_LOGIC;
           env_call_instr : out STD_LOGIC);
end main_decoder;

architecture Behavioral of main_decoder is
    
    
    -- out_control = reg_write, imm_src, alu_src_a, alu_src_b, mem_write, 
    -- result_src, branch, alu_op, jump, load_instr, pc_target_src, load_store
    -- csr_write, mret_instr
    signal out_control: std_logic_vector(18 downto 0);
begin

    process(all)
    begin
        illegal_instruction <= '0';
    
        case op is
            -- loads
            when "0000011" =>
                out_control <= b"1_000_0_1_0_01_0_00_0_1_-_1_0_0_0";
            -- sw
            when "0100011" =>
                out_control <= b"0_001_0_1_1_--_0_00_0_0_-_1_0_0_0";
            -- R type
            when "0110011" =>
                out_control <= b"1_---_0_0_0_00_0_10_0_0_-_0_0_0_0";
            -- branches
            when "1100011" =>
                out_control <= b"0_010_0_0_0_--_1_01_0_0_1_0_0_0_0";
            -- I type
            when "0010011" =>
                out_control <= b"1_000_0_1_0_00_0_10_0_0_-_0_0_0_0";
            -- jal
            when "1101111" =>
                out_control <= b"1_011_-_-_0_10_0_--_1_0_1_0_0_0_0";
            -- lui
            when "0110111" =>
                out_control <= b"1_100_1_1_0_00_0_00_0_0_-_0_0_0_0";
            -- jalr
            when "1100111" =>
                out_control <= b"1_000_-_-_0_10_0_--_1_0_0_0_0_0_0";
            -- auipc
            when "0010111" =>
                out_control <= b"1_100_-_-_0_11_0_--_0_0_1_0_0_0_0";
            -- privilege
            when "1110011" =>
                if funct3 = "000" then
                    if rs1 = 5D"00" and rd = 5D"00" then
                        case imm_i_type is
                            -- mret
                            when 12D"770" => out_control <= b"0_---_-_-_0_00_0_--_1_0_-_0_0_1_0";
                            -- ecall
                            when 12D"0" => out_control <= b"0_---_-_-_0_00_0_--_0_0_-_0_0_0_1";
                            -- ebreak
                            when 12D"1" => out_control <= b"0_---_-_-_0_00_0_--_0_0_-_0_0_0_1";
                            when others => illegal_instruction <= '1';
                        end case;
                    else
                        illegal_instruction <= '1';
                    end if;
                else
                    -- csr
                    out_control <= b"1_101_-_-_0_00_0_--_0_0_-_0_1_0_0";
                end if;
            -- fence
            -- no architecture state change
            when "0001111" =>
                out_control <= "0000000000000000000";
            when "0000000" =>
                out_control <= "0000000000000000000";
                if is_decode_flush_d = '0' then
                    illegal_instruction <= '0';
                else
                    illegal_instruction <= '1';
                end if;
            when others =>
                illegal_instruction <= '1';
        end case;
        
    end process;
    
    (reg_write, imm_src(2), imm_src(1), imm_src(0), alu_src_a, alu_src_b, 
     mem_write, result_src(1), result_src(0), branch, alu_op(1), 
     alu_op(0), jump, load_instr, pc_target_src, load_store, csr_write,
     mret_instr, env_call_instr) <= out_control;

end Behavioral;
