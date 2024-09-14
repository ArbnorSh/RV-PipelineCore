-- SPDX-License-Identifier: BSD-3-Clause
-- 
-- Copyright (c) [2024], [Arbnor Shabani]
-- All rights reserved.
-- 
-- This code is licensed under the BSD 3-Clause License.
-- See the LICENSE file for more details.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity extend_imm is
    Port ( instr : in STD_LOGIC_VECTOR (31 downto 7);
           type_of_imm : in STD_LOGIC_VECTOR (2 downto 0);
           ext_imm : out STD_LOGIC_VECTOR (31 downto 0));
end extend_imm;

architecture Behavioral of extend_imm is

begin

    process(instr, type_of_imm)
    begin
    
        case type_of_imm is
            when "000" =>
                ext_imm <= ( 31 downto 12 => instr(31), 11 downto 0 => instr(31 downto 20));
            when "001" =>
                ext_imm <= ( 31 downto 12 => instr(31), 11 downto 5 => instr(31 downto 25), 4 downto 0 => instr(11 downto 7) );
            when "010" =>
                ext_imm <= ( 31 downto 12 => instr(31), 11 => instr(7), 10 downto 5 => instr(30 downto 25), 
                             4 downto 1 => instr(11 downto 8), 0 => '0' );
            when "011" =>
                ext_imm <= ( 31 downto 20 => instr(31), 19 downto 12 => instr(19 downto 12), 11 => instr(20), 10 downto 1 => instr(30 downto 21), 0 => '0' );
            when "100" =>
                ext_imm <= ( 31 downto 12 => instr(31 downto 12), 11 downto 0 => '0' );
            when "101" =>
                ext_imm <= ( 31 downto 5 => '0', 4 downto 0 => instr(19 downto 15) ) ;
            when others =>
                ext_imm <= (others => '0');
        end case;
    
    end process;


end Behavioral;
