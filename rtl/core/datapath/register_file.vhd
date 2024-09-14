-- SPDX-License-Identifier: BSD-3-Clause
-- 
-- Copyright (c) [2024], [Arbnor Shabani]
-- All rights reserved.
-- 
-- This code is licensed under the BSD 3-Clause License.
-- See the LICENSE file for more details.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.all;

entity register_file is
    Port ( clk : in STD_LOGIC;
           write_enable : in STD_LOGIC;
           a1 : in STD_LOGIC_VECTOR (4 downto 0);
           a2 : in STD_LOGIC_VECTOR (4 downto 0);
           a3 : in STD_LOGIC_VECTOR (4 downto 0);
           write_data : in STD_LOGIC_VECTOR (31 downto 0);
           rd1 : out STD_LOGIC_VECTOR (31 downto 0);
           rd2 : out STD_LOGIC_VECTOR (31 downto 0));
end register_file;

architecture Behavioral of register_file is
    type reg_mem_t is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    
    signal reg_mem: reg_mem_t;
begin

    process(clk)
    begin
        if falling_edge(clk) then
            if write_enable = '1' then
                reg_mem(to_integer(a3)) <= write_data;
            end if;
    
        end if;
    end process;
    
    rd1 <= reg_mem(to_integer(a1)) when to_integer(a1) /= 0 else (others => '0');
    rd2 <= reg_mem(to_integer(a2)) when to_integer(a2) /= 0 else (others => '0');

end Behavioral;
