-- SPDX-License-Identifier: BSD-3-Clause
-- 
-- Copyright (c) [2024], [Arbnor Shabani]
-- All rights reserved.
-- 
-- This code is licensed under the BSD 3-Clause License.
-- See the LICENSE file for more details.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_decoder is
    Port ( op_5 : in STD_LOGIC;
           funct3 : in STD_LOGIC_VECTOR (2 downto 0);
           func7_5 : in STD_LOGIC;
           alu_op : in STD_LOGIC_VECTOR (1 downto 0);
           alu_control : out STD_LOGIC_VECTOR (3 downto 0));
end alu_decoder;

architecture Behavioral of alu_decoder is

begin

    process(all)
    begin
    
        case alu_op is
            when "00" =>
                alu_control <= "0000";
            when "01" =>
                alu_control <= "0001";
            when "10" =>
                case funct3 is
                    when "000" =>
                        if op_5 = '1' and func7_5 = '1' then
                            alu_control <= "0001";
                        else
                            alu_control <= "0000";
                        end if;
                   when "001" =>
                        alu_control <= "0110";
                   when "010" =>
                        alu_control <= "0101";
                   when "011" =>
                        alu_control <= "1001";
                   when "100" =>
                        alu_control <= "0100";
                   when "101" =>
                        if func7_5 = '1' then
                            -- sra
                            alu_control <= "1000";
                        else
                            -- srl
                            alu_control <= "0111";
                        end if;
                   when "110" =>
                        alu_control <= "0011";
                   when "111" =>
                        alu_control <= "0010";
                   when others =>
                        alu_control <= "0000";
                end case;
                
            when others =>
                alu_control <= "0000";
                
       end case;
    
    end process;


end Behavioral;
