library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main_decoder is
    Port ( op : in STD_LOGIC_VECTOR (6 downto 0);
           branch : out STD_LOGIC;
           jump : out STD_LOGIC;
           result_src : out STD_LOGIC_VECTOR (1 downto 0);
           mem_write : out STD_LOGIC;
           alu_src_a : out STD_LOGIC;
           alu_src_b : out STD_LOGIC;
           imm_src : out STD_LOGIC_VECTOR (2 downto 0);
           reg_write : out STD_LOGIC;
           alu_op : out STD_LOGIC_VECTOR (1 downto 0));
end main_decoder;

architecture Behavioral of main_decoder is
    
    
    -- out_control = reg_write, imm_src, alu_src_a, alu_src_b, mem_write, result_src, branch, alu_op, jump
    signal out_control: std_logic_vector(13 downto 0);
begin

    process(op)
    begin
    
        case op is
            -- lw
            when "0000011" =>
                out_control <= b"1_000_0_1_0_01_0_00_0";
            -- sw
            when "0100011" =>
                out_control <= b"0_001_0_1_1_--_0_00_0";
            -- R type
            when "0110011" =>
                out_control <= b"1_---_0_0_0_00_0_10_0";
            -- branches
            when "1100011" =>
                out_control <= b"0_010_0_0_0_--_1_01_0";
            -- I type
            when "0010011" =>
                out_control <= b"1_000_0_1_0_00_0_10_0";
            -- jal
            when "1101111" =>
                out_control <= b"1_011_-_-_0_10_0_--_1";
            -- lui
            when "0110111" =>
                out_control <= b"1_100_1_1_0_00_0_00_0";
            when others =>
                out_control <= "0000000000000000";
        end case;
        
    end process;
    
    (reg_write, imm_src(2), imm_src(1), imm_src(0), alu_src_a, alu_src_b, 
     mem_write, result_src(1), result_src(0), branch, alu_op(1), 
     alu_op(0), jump) <= out_control;


end Behavioral;
