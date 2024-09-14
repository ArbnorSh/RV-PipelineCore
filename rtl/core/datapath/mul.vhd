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

entity mul is
    port (
          a, b : in STD_LOGIC_VECTOR(31 downto 0);
          funct3 : in STD_LOGIC_VECTOR(2 downto 0);
          mul_result : out STD_LOGIC_VECTOR(31 downto 0)
          );
end mul;

architecture behavioral of mul is
    signal operand_a, operand_b : std_logic_vector(64 downto 0);
    signal sign_bit_a, sign_bit_b : std_logic;
    signal result : std_logic_vector(129 downto 0);
begin

    sign_bit_a <= a(31) when funct3 = "001" or funct3 = "010" else
                '0';
    operand_a <= (64 downto 32 => sign_bit_a, 31 downto 0 => a);

    sign_bit_b <= b(31) when funct3 = "001" else
                '0';
    operand_b <= (64 downto 32 => sign_bit_b, 31 downto 0 => b);

    result <= operand_a * operand_b;

    mul_result <= result(31 downto 0) when funct3 = "000" else
                  result(63 downto 32);

end;
