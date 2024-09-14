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
use ieee.std_logic_misc.all;

entity div is
    port (
          clk, reset : in STD_LOGIC;
          a, b : in STD_LOGIC_VECTOR(31 downto 0);
          div_start : in STD_LOGIC;
          funct3 : in STD_LOGIC_VECTOR(2 downto 0);
          div_completed : out STD_LOGIC;
          div_result : out STD_LOGIC_VECTOR(31 downto 0)
          );
end div;

architecture behavioral of div is
    component edge_detector is
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               d : in STD_LOGIC;
               edge_detected : out STD_LOGIC);
    end component;

    type statetype is (IDLE, BUSY, DONE);
    signal state, next_state: statetype;
    signal signed_op, invert_result, sign_differs, div_busy: std_logic; 
    signal is_div_instr_s, is_rem_instr_s, divisor_not_zero: std_logic;
    signal dividend, quotient, mask: std_logic_vector(31 downto 0);
    signal divisor: std_logic_vector(62 downto 0);
    signal start : std_logic;
begin

    -- because of stall logic
    -- start can be kept asserted
    detect_start: edge_detector port map(
        clk => clk,
        reset => reset,
        d => div_start,
        edge_detected => start
        );

    signed_op <= '1' when funct3 = "100" or funct3 = "110" else
                 '0';
    is_div_instr_s <= '1' when funct3 = "100" else
                      '0';
    is_rem_instr_s <= '1' when funct3 = "110" else
                      '0';
    sign_differs <= '1' when a(31) /= b(31) else '0';
    divisor_not_zero <= or b;

    process(clk, reset) begin
        if reset then
            state <= IDLE;
            div_busy <= '0';
        elsif rising_edge(clk) then
            if start then
                div_busy <= '1';
                invert_result <= '1' when (is_div_instr_s and sign_differs and divisor_not_zero) 
                                  or (is_rem_instr_s and a(31)) else '0';
                    
                if (a(31) and signed_op) then
                    dividend <= std_logic_vector(0 - unsigned(a));
                else
                    dividend <= a;
                end if;
                    
                if (b(31) and signed_op) then
                    divisor <= (62 downto 31 => std_logic_vector(0 - unsigned(b)), 30 downto 0 => '0');
                else
                    divisor <= (62 downto 31 => b, others => '0');
                end if;
    
                quotient <= (others => '0');
                mask <= 32X"80000000";
            elsif div_completed then
                div_busy <= '0';
                if funct3 = "100" or funct3 = "101" then
                    div_result <= std_logic_vector(0 - unsigned(quotient)) when invert_result else 
                                  quotient;
                else
                    div_result <= std_logic_vector(0 - unsigned(dividend)) when invert_result else 
                                  dividend;
                end if;
            elsif div_busy then
                if (divisor <= ('0' & dividend(31 downto 0))) then
                    dividend <= dividend - divisor(31 downto 0);
                    quotient <= quotient or mask;
                end if;

                divisor <= '0' & divisor(62 downto 1);
                mask <= '0' & mask(31 downto 1);
            end if;

        end if;
    end process;

    div_completed <= '1' when div_busy = '1' and (not (or mask)) = '1' else
                     '0';

end;
