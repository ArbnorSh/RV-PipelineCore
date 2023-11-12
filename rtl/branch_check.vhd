library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity branch_check is
    Port ( branch: in STD_LOGIC;
           funct3 : in STD_LOGIC_VECTOR (2 downto 0);
           zero : in STD_LOGIC;
           negative : in STD_LOGIC;
           overflow : in STD_LOGIC;
           take_branch : out STD_LOGIC);
end branch_check;

architecture Behavioral of branch_check is

begin

    process(all)
    begin

        if branch = '1' then

            case funct3 is
                when "000" =>
                    -- beq
                    take_branch <= zero;
                when "001" =>
                    -- bne
                    take_branch <= not zero;
                when "100" =>
                    -- blt
                    take_branch <= negative xor overflow;
                when others =>
                    take_branch <= '0';
            end case;

        else
            take_branch <= '0';
        end if;

    end process;


end Behavioral;
