-- SPDX-License-Identifier: BSD-3-Clause
-- 
-- Copyright (c) [2024], [Arbnor Shabani]
-- All rights reserved.
-- 
-- This code is licensed under the BSD 3-Clause License.
-- See the LICENSE file for more details.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity branch_misprediction is
    port (
          valid_pc_e, valid_pc_d : in STD_LOGIC;
          branch_instr, take_branch : in STD_LOGIC;
          jump_target_pc, pc_f, pc_d: in std_logic_vector(31 downto 0);
          pc_plus4_e : in STD_LOGIC_VECTOR(31 downto 0);
          -- Did we mispredict an actual taken branch
          is_mispredict_tbranch_e : out STD_LOGIC;
          -- Did we mispredict an actual not taken branch
          is_mispredict_ntbranch_e : out STD_LOGIC
    );
end branch_misprediction;

architecture Behavioral of branch_misprediction is
begin

    process(all)
    begin

        if valid_pc_e = '1' then
            if branch_instr = '1' and take_branch = '1' then
                if valid_pc_d = '0' then
                    -- decode stage is in flushed state
                    is_mispredict_tbranch_e <= '1' when jump_target_pc /= pc_f else '0';
                else
                    is_mispredict_tbranch_e <= '1' when jump_target_pc /= pc_d else '0';
                end if;
                is_mispredict_ntbranch_e <= '0';
            elsif branch_instr = '1' then
                if valid_pc_d = '0' then
                    -- decode stage is in flushed state
                    is_mispredict_ntbranch_e <= '1' when pc_plus4_e /= pc_f else '0';
                else
                    is_mispredict_ntbranch_e <= '1' when pc_plus4_e /= pc_d else '0';
                end if;
                is_mispredict_tbranch_e <= '0';
            else
                is_mispredict_tbranch_e <= '0';
                is_mispredict_ntbranch_e <= '0';
            end if;
        else
            is_mispredict_tbranch_e <= '0';
            is_mispredict_ntbranch_e <= '0';
        end if;

    end process;

end Behavioral;