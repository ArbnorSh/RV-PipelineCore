-- SPDX-License-Identifier: BSD-3-Clause
-- 
-- Copyright (c) [2024], [Arbnor Shabani]
-- All rights reserved.
-- 
-- This code is licensed under the BSD 3-Clause License.
-- See the LICENSE file for more details.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mask_decoder is
    Port ( mask_op : in STD_LOGIC;
           funct3 : in STD_LOGIC_VECTOR (2 downto 0);
           mask_src : out STD_LOGIC_VECTOR (2 downto 0));
end mask_decoder;

architecture Behavioral of mask_decoder is

begin

    process(mask_op, funct3)
    begin
    
        case mask_op is
            when '1' =>
            
                case funct3 is 
                    when "000" =>
                        -- lb
                        mask_src <= "001";
                    when "001" =>
                        -- lh
                        mask_src <= "010";
                    when "100" =>
                        -- lbu
                        mask_src <= "011";
                    when "101" =>
                        -- lhu
                        mask_src <= "100";
                    when others =>
                        mask_src <= "000";
                 end case;
                 
            when others =>
                mask_src <= "000";
        end case;
    
    end process;

end Behavioral;
