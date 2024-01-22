library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main_decoder is
    Port ( op : in STD_LOGIC_VECTOR (6 downto 0);
           funct3 : in STD_LOGIC_VECTOR (2 downto 0);
           branch : out STD_LOGIC;
           jump : out STD_LOGIC;
           result_src : out STD_LOGIC_VECTOR (1 downto 0);
           mem_write : out STD_LOGIC;
           alu_src_a : out STD_LOGIC;
           alu_src_b : out STD_LOGIC;
           imm_src : out STD_LOGIC_VECTOR (2 downto 0);
           reg_write : out STD_LOGIC;
           alu_op : out STD_LOGIC_VECTOR (1 downto 0);
           load_instr : out STD_LOGIC;
           pc_target_src: out STD_LOGIC;
           load_store : out STD_LOGIC;
           csr_write : out STD_LOGIC;
           mret_instr : out STD_LOGIC);
end main_decoder;

architecture Behavioral of main_decoder is
    
    
    -- out_control = reg_write, imm_src, alu_src_a, alu_src_b, mem_write, 
    -- result_src, branch, alu_op, jump, load_instr, pc_target_src, load_store
    -- csr_write, mret_instr
    signal out_control: std_logic_vector(17 downto 0);
begin

    process(op)
    begin
    
        case op is
            -- loads
            when "0000011" =>
                out_control <= b"1_000_0_1_0_01_0_00_0_1_-_1_0_0";
            -- sw
            when "0100011" =>
                out_control <= b"0_001_0_1_1_--_0_00_0_0_-_1_0_0";
            -- R type
            when "0110011" =>
                out_control <= b"1_---_0_0_0_00_0_10_0_0_-_0_0_0";
            -- branches
            when "1100011" =>
                out_control <= b"0_010_0_0_0_--_1_01_0_0_1_0_0_0";
            -- I type
            when "0010011" =>
                out_control <= b"1_000_0_1_0_00_0_10_0_0_-_0_0_0";
            -- jal
            when "1101111" =>
                out_control <= b"1_011_-_-_0_10_0_--_1_0_1_0_0_0";
            -- lui
            when "0110111" =>
                out_control <= b"1_100_1_1_0_00_0_00_0_0_-_0_0_0";
            -- jalr
            when "1100111" =>
                out_control <= b"1_000_-_-_0_--_0_--_1_0_0_0_0_0";
            -- auipc
            when "0010111" =>
                out_control <= b"1_100_-_-_0_11_0_--_0_0_1_0_0_0";
            -- csr
            when "1110011" =>
                -- mret : TODO eret??
                if funct3 = "111" then
                    out_control <= b"0_---_-_-_0_00_0_--_1_0_-_0_0_1";
                else
                    out_control <= b"1_101_-_-_0_00_0_--_0_0_-_0_1_0";
                end if;
            when others =>
                out_control <= "000000000000000000";
        end case;
        
    end process;
    
    (reg_write, imm_src(2), imm_src(1), imm_src(0), alu_src_a, alu_src_b, 
     mem_write, result_src(1), result_src(0), branch, alu_op(1), 
     alu_op(0), jump, load_instr, pc_target_src, load_store, csr_write,
     mret_instr) <= out_control;


end Behavioral;
