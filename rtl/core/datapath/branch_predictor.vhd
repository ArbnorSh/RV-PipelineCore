library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity branch_predictor is
    port (
          clk : in STD_LOGIC;
          pc, pc_e : in STD_LOGIC_VECTOR(31 downto 0);
          branch_instr_e: in STD_LOGIC;
          branch_taken_e : in STD_LOGIC;
          jump_address: in std_logic_vector(31 downto 0);
          branch_predicted : out STD_LOGIC;
          predicted_pc : out STD_LOGIC_VECTOR(31 downto 0)
    );
end branch_predictor;

architecture Behavioral of branch_predictor is
    signal pc_index, pc_e_index : std_logic_vector(6 downto 0);
    signal pc_cached, pc_cached_e: std_logic;
    type pc_buffer_type is array (0 to 127) of std_logic_vector(31 downto 0);
    type pc_check_type is array (0 to 127) of std_logic_vector(7 downto 0);
    type pc_predict_type is array (0 to 127) of std_logic_vector(1 downto 0);
    signal pc_buffer : pc_buffer_type := (others=>(others=>'0'));
    signal pc_check : pc_check_type := (others=>(others=>'0'));
    signal pc_predict : pc_predict_type := (others=>(others=>'0'));
begin

    process(all)
    begin

        pc_index <= pc(6 downto 0);
        pc_cached <= '1' when (pc_check(to_integer(unsigned(pc_index))) = pc(14 downto 7)) else '0';

        pc_e_index <= pc_e(6 downto 0);
        pc_cached_e <= '1' when (pc_check(to_integer(unsigned(pc_e_index))) = pc_e(14 downto 7)) else '0';

    end process;

    process(clk)
    begin
        if rising_edge(clk) and branch_instr_e then
            pc_buffer(to_integer(unsigned(pc_e_index))) <= jump_address;
            pc_check(to_integer(unsigned(pc_e_index))) <= pc_e(14 downto 7);
            if branch_taken_e = '1' then
                -- Increase prediction counter
                if pc_cached_e = '1' and pc_predict(to_integer(unsigned(pc_e_index))) = "11" then
                    pc_predict(to_integer(unsigned(pc_e_index))) <= "11";
                elsif pc_cached_e then
                    pc_predict(to_integer(unsigned(pc_e_index))) <= pc_predict(to_integer(unsigned(pc_e_index))) + 1;
                else
                    pc_predict(to_integer(unsigned(pc_e_index))) <= "01";
                end if;
            else
                -- Decrease prediction counter 
                if pc_cached_e = '1' and pc_predict(to_integer(unsigned(pc_e_index))) = "00" then
                    pc_predict(to_integer(unsigned(pc_e_index))) <= "00";
                elsif pc_cached_e then
                    pc_predict(to_integer(unsigned(pc_e_index))) <= pc_predict(to_integer(unsigned(pc_e_index))) - 1;
                else
                    pc_predict(to_integer(unsigned(pc_e_index))) <= "00";
                end if;
            end if;
        end if;
    end process;

    branch_predicted <= pc_cached when pc_predict(to_integer(unsigned(pc_index)))(1) = '1' else '0';
    predicted_pc <= pc_buffer(to_integer(unsigned(pc_index)));

end Behavioral;