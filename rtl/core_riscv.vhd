library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity core_riscv is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           pc_f : out STD_LOGIC_VECTOR (31 downto 0);
           instruction_f : in STD_LOGIC_VECTOR (31 downto 0);
           mem_write_m : out STD_LOGIC;
           alu_result_m : out STD_LOGIC_VECTOR (31 downto 0);
           write_data_m : out STD_LOGIC_VECTOR (31 downto 0);
           read_data_m : in STD_LOGIC_VECTOR (31 downto 0));
end core_riscv;

architecture Behavioral of core_riscv is

    component control_unit is
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               opcode : in STD_LOGIC_VECTOR (6 downto 0);
               funct3 : in STD_LOGIC_VECTOR (2 downto 0);
               funct7_b5 : in STD_LOGIC;
               imm_src_d : out STD_LOGIC_VECTOR (2 downto 0);
               flush_e : in STD_LOGIC;
               zero_e : in STD_LOGIC;
               pc_src_e : out STD_LOGIC;
               alu_control_e : out STD_LOGIC_VECTOR (2 downto 0);
               alu_src_a_e : out STD_LOGIC;
               alu_src_b_e : out STD_LOGIC;
               result_src_b0_e : out STD_LOGIC;
               mem_write_m : out STD_LOGIC;
               reg_write_m : out STD_LOGIC;
               reg_write_w : out STD_LOGIC;
               result_src_w : out STD_LOGIC_VECTOR (1 downto 0));
    end component;
begin

    control_unit_block: control_unit port map(
        clk => clk,
        reset => reset,
        
        opcode => op_d,
        funct3 => funct3_d,
        funct7_b5 => funct7_b5_d,
        
        imm_src_d => imm_src_d,
        
        flush_e   => flush_e,
        zero_e    => zero_e,
        pc_src_e  => pc_src_e,
        alu_control_e => alu_control_e,
        alu_src_a_e => alu_src_a_e,
        alu_src_b_e => alu_src_b_e,
        result_src_b0_e => result_src_b0_e,
        
        mem_write_m => mem_write_m,
        reg_write_m => reg_write_m,
        reg_write_w => reg_write_w,
        result_src_w => result_src_w);


end Behavioral;
