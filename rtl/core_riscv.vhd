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
    
    component datapath is
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               stall_f : in STD_LOGIC;
               pc_f : out STD_LOGIC_VECTOR (31 downto 0);
               instr_f : in STD_LOGIC_VECTOR (31 downto 0);
               op_d : out STD_LOGIC_VECTOR (6 downto 0);
               funct3_d : out STD_LOGIC_VECTOR (2 downto 0);
               funct7_b5_d : out STD_LOGIC;
               stall_d : in STD_LOGIC;
               flush_d : in STD_LOGIC;
               imm_src_d : in STD_LOGIC_VECTOR (2 downto 0);
               flush_e : in STD_LOGIC;
               forward_a_e : in STD_LOGIC_VECTOR (1 downto 0);
               forward_b_e : in STD_LOGIC_VECTOR (1 downto 0);
               pc_src_e : in STD_LOGIC;
               alu_control_e : in STD_LOGIC_VECTOR (2 downto 0);
               alu_src_a_e : in STD_LOGIC;
               alu_src_b_e : in STD_LOGIC;
               zero_e : out STD_LOGIC;
               mem_write_m : in STD_LOGIC;
               write_data_m : out STD_LOGIC_VECTOR (31 downto 0);
               alu_result_m : out STD_LOGIC_VECTOR (31 downto 0);
               read_data_m : in STD_LOGIC_VECTOR (31 downto 0);
               reg_write_w : in STD_LOGIC;
               result_src_w : in STD_LOGIC_VECTOR (1 downto 0);
               rs1_d, rs2_d, rs1_e, rs2_e : out STD_LOGIC_VECTOR (4 downto 0);
               rd_e, rd_m, rd_w : out STD_LOGIC_VECTOR(4 downto 0));
    end component;
    
    component hazard_unit is
        Port ( rs1_d, rs2_d, rs1_e, rs2_e, rd_e, rd_m, rd_w : in STD_LOGIC_VECTOR (4 downto 0);
               pc_src_e, result_src_b0_e : in STD_LOGIC;
               reg_write_m, reg_write_w : in STD_LOGIC;
               forward_a_e, forward_b_e : out STD_LOGIC_VECTOR (1 downto 0);
               stall_f, stall_d, flush_d, flush_e : out STD_LOGIC);
    end component;
    
    signal op_d : std_logic_vector(6 downto 0);
    signal funct3_d, imm_src_d, alu_control_e: std_logic_vector(2 downto 0);
    signal funct_7_b5_d, zero_e, pc_src_e, alu_src_a_e, alu_src_b_e: std_logic;
    signal result_src_b0_e, reg_write_m, reg_write_w: std_logic;
    signal stall_f, stall_d, flush_d, flush_e: std_logic;
    signal result_src_w, forward_a_e, forward_b_e: std_logic_vector(1 downto 0);
    signal rs1_d, rs2_d, rs1_e, rs2_e, rd_e, rd_m, rd_w: std_logic_vector(4 downto 0);
begin

    control_unit_block: control_unit port map(
        clk => clk,
        reset => reset,
        
        opcode => op_d,
        funct3 => funct3_d,
        funct7_b5 => funct_7_b5_d,
        
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
        
     datapath_block: datapath port map(
        clk => clk,
        reset => reset,
        
        stall_f => stall_f,
        pc_f => pc_f,
        instr_f => instruction_f,
        
        op_d => op_d,
        funct3_d => funct3_d,
        funct7_b5_d => funct_7_b5_d,
        stall_d => stall_d,
        flush_d => flush_d,
        imm_src_d => imm_src_d,
        rs1_d => rs1_d,
        rs2_d => rs2_d,
        
        flush_e => flush_e,
        forward_a_e => forward_a_e,
        forward_b_e => forward_b_e,
        pc_src_e => pc_src_e,
        alu_control_e => alu_control_e,
        alu_src_a_e => alu_src_a_e,
        alu_src_b_e => alu_src_b_e,
        zero_e => zero_e,
        rs1_e => rs1_e,
        rs2_e => rs2_e,
        rd_e => rd_e,
        
        mem_write_m => mem_write_m,
        write_data_m => write_data_m,
        alu_result_m => alu_result_m,
        read_data_m => read_data_m,
        rd_m => rd_m,
        
        reg_write_w => reg_write_w,
        result_src_w => result_src_w,
        rd_w => rd_w);
    
    hazard_block: hazard_unit port map(
        rs1_d => rs1_d,
        rs2_d => rs2_d,
        rs1_e => rs1_e,
        rs2_e => rs2_e,
        rd_e => rd_e,
        rd_m => rd_m,
        rd_w => rd_w,
        pc_src_e => pc_src_e,
        result_src_b0_e => result_src_b0_e,
        reg_write_m => reg_write_m,
        reg_write_w => reg_write_w,
        forward_a_e => forward_a_e,
        forward_b_e => forward_b_e,
        stall_f => stall_f,
        stall_d => stall_d,
        flush_d => flush_d,
        flush_e => flush_e
        );
        
end Behavioral;
