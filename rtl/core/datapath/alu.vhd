-- SPDX-License-Identifier: BSD-3-Clause
-- 
-- Copyright (c) [2024], [Arbnor Shabani]
-- All rights reserved.
-- 
-- This code is licensed under the BSD 3-Clause License.
-- See the LICENSE file for more details.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- 0000 - ADD
-- 0001 - SUB
-- 0010 - AND
-- 0011 - OR
-- 0100 - XOR
-- 0101 - SLT
-- 0110 - SLL
-- 0111 - SRL
-- 1000 - SRA
-- 1001 - SLTU

entity alu is
    port (
          a, b: in std_logic_vector(31 downto 0);
          alucontrol: in std_logic_vector(3 downto 0);
          result: out std_logic_vector(31 downto 0);
          zero, negative: out std_logic;
          carry, overflow: out std_logic
          );
end;

architecture behavioral of alu is
    signal bvar: std_logic_vector(31 downto 0);
    signal sum: std_logic_vector(32 downto 0);
    signal slt, sltu: std_logic;
begin
    bvar <= (not b) when alucontrol(0) = '1' else b;
    
    sum <= ("0" & a) + ("0" & bvar) + alucontrol(0);
    carry <= sum(32) and (not alucontrol(1));
    
    overflow <= (not alucontrol(1)) and (a(31) xor sum(31)) and ( not (a(31) xor b(31) ) xor alucontrol(0) );
    
    slt <= sum(31) xor overflow;
    sltu <= not carry;
    
    zero <= nor result;
    
    negative <= sum(31);
    
    process(all) is
    begin

        case alucontrol is
            when "0000" => result <= sum(31 downto 0);
        
            when "0001" => result <= sum(31 downto 0);
        
            when "0010" => result <= a and b;
        
            when "0011" => result <= a or b;
            
            when "0100" => result <= a xor b;
            
            when "0101" => result <= (31 downto 1 => '0', 0 => slt);
            
            when "0110" => result <= a sll to_integer(unsigned(b(4 downto 0)));
            
            when "0111" => result <= a srl to_integer(unsigned(b(4 downto 0)));
            
            when "1000" => result <= std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(4 downto 0)))));
            
            when "1001" => result <= (31 downto 1 => '0', 0 => sltu);
      
            when others => result <= (others => 'X');
        end case;
    end process;

end;
