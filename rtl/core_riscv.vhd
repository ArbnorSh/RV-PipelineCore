library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity core_riscv is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           
           -- Instruction Wishbone Port
           instr_adr : out STD_LOGIC_VECTOR(31 downto 0);
           instr_data : in STD_LOGIC_VECTOR(31 downto 0);
           instr_valid : out STD_LOGIC;
           instr_ack : in STD_LOGIC;
           
           -- Data Wishbone Port
           d_adr : out STD_LOGIC_VECTOR(31 downto 0);
           d_data_w : out STD_LOGIC_VECTOR(31 downto 0);
           d_data_r : in STD_LOGIC_VECTOR(31 downto 0);
           d_sel : out STD_LOGIC_VECTOR(3 downto 0);
           d_we : out STD_LOGIC;
           d_valid : out STD_LOGIC;
           d_ack : in STD_LOGIC);
end core_riscv;

architecture Behavioral of core_riscv is

    component control_unit is
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               opcode_d : in STD_LOGIC_VECTOR (6 downto 0);
               funct3_d : in STD_LOGIC_VECTOR (2 downto 0);
               funct7_b5_d : in STD_LOGIC;
               imm_src_d : out STD_LOGIC_VECTOR (2 downto 0);
               csr_write_d : out STD_LOGIC;
               stall_e : in STD_LOGIC;
               flush_e : in STD_LOGIC;
               zero_e : in STD_LOGIC;
               negative_e : in STD_LOGIC;
               overflow_e : in STD_LOGIC;
               carry_e : in STD_LOGIC;
               read_address_m : in STD_LOGIC_VECTOR(1 downto 0);
               pc_src_e : out STD_LOGIC;
               alu_control_e : out STD_LOGIC_VECTOR (3 downto 0);
               alu_src_a_e : out STD_LOGIC;
               alu_src_b_e : out STD_LOGIC;
               result_src_b0_e : out STD_LOGIC;
               pc_target_src_e : out STD_LOGIC;
               load_instr_e : out STD_LOGIC;
               stall_m : in STD_LOGIC;
               mem_write_m : out STD_LOGIC;
               reg_write_m : out STD_LOGIC;
               mem_control_m : out STD_LOGIC_VECTOR (3 downto 0);
               load_store_m : out STD_LOGIC;
               flush_w : in STD_LOGIC;
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
               csr_write_d : in STD_LOGIC;
               stall_e : in STD_LOGIC;
               flush_e : in STD_LOGIC;
               forward_a_e : in STD_LOGIC_VECTOR (1 downto 0);
               forward_b_e : in STD_LOGIC_VECTOR (1 downto 0);
               pc_src_e : in STD_LOGIC;
               alu_control_e : in STD_LOGIC_VECTOR (3 downto 0);
               alu_src_a_e : in STD_LOGIC;
               alu_src_b_e : in STD_LOGIC;
               pc_target_src_e : in STD_LOGIC;
               zero_e : out STD_LOGIC;
               negative_e : out STD_LOGIC;
               overflow_e : out STD_LOGIC;
               carry_e : out STD_LOGIC;
               load_instr_e : in STD_LOGIC;
               stall_m : in STD_LOGIC;
               mem_write_m : in STD_LOGIC;
               write_data_m : out STD_LOGIC_VECTOR (31 downto 0);
               alu_result_m : out STD_LOGIC_VECTOR (31 downto 0);
               read_data_m : in STD_LOGIC_VECTOR (31 downto 0);
               flush_w : in STD_LOGIC;
               reg_write_w : in STD_LOGIC;
               result_src_w : in STD_LOGIC_VECTOR (1 downto 0);
               rs1_d, rs2_d, rs1_e, rs2_e : out STD_LOGIC_VECTOR (4 downto 0);
               rd_e, rd_m, rd_w : out STD_LOGIC_VECTOR(4 downto 0));
    end component;
    
    component hazard_unit is
        Port ( clk, reset : in STD_LOGIC;
               rs1_d, rs2_d, rs1_e, rs2_e, rd_e, rd_m, rd_w : in STD_LOGIC_VECTOR (4 downto 0);
               pc_src_e, load_instr_e : in STD_LOGIC;
               load_store_m : in STD_LOGIC;
               reg_write_m, reg_write_w : in STD_LOGIC;
               instruction_ack, instruction_valid, data_ack : in STD_LOGIC;
               forward_a_e, forward_b_e : out STD_LOGIC_VECTOR (1 downto 0);
               stall_f, stall_d, stall_e, stall_m, flush_d, flush_e, flush_w: out STD_LOGIC);
    end component;
    
    signal op_d : std_logic_vector(6 downto 0);
    signal funct3_d, imm_src_d: std_logic_vector(2 downto 0);
    signal funct_7_b5_d, zero_e, pc_src_e, alu_src_a_e, alu_src_b_e, carry_e: std_logic;
    signal result_src_b0_e, reg_write_m, reg_write_w, negative_e, overflow_e: std_logic;
    signal stall_f, stall_d, stall_e, stall_m, flush_d, flush_e, flush_w, pc_target_src_e: std_logic;
    signal result_src_w, forward_a_e, forward_b_e: std_logic_vector(1 downto 0);
    signal rs1_d, rs2_d, rs1_e, rs2_e, rd_e, rd_m, rd_w: std_logic_vector(4 downto 0);
    signal alu_control_e: std_logic_vector(3 downto 0);
    
    signal is_instruction_valid, load_instr_e : std_logic;
    signal pc_f, instruction_f, alu_result_m : std_logic_vector(31 downto 0);
    signal read_data_m, write_data_m : std_logic_vector(31 downto 0);
    signal mem_write_m, load_store_m : std_logic;
    signal mem_control_m : std_logic_vector(3 downto 0);
    
    signal csr_write_d : std_logic;

begin

    control_unit_block: control_unit port map(
        clk => clk,
        reset => reset,
        
        opcode_d => op_d,
        funct3_d => funct3_d,
        funct7_b5_d => funct_7_b5_d,
        
        imm_src_d => imm_src_d,
        
        stall_e => stall_e,
        flush_e   => flush_e,
        
        zero_e    => zero_e,
        negative_e => negative_e,
        overflow_e => overflow_e,
        carry_e => carry_e,
        
        read_address_m => alu_result_m(1 downto 0),
        
        pc_src_e  => pc_src_e,
        alu_control_e => alu_control_e,
        alu_src_a_e => alu_src_a_e,
        alu_src_b_e => alu_src_b_e,
        result_src_b0_e => result_src_b0_e,
        pc_target_src_e => pc_target_src_e,
        
        stall_m => stall_m,
        
        mem_write_m => mem_write_m,
        reg_write_m => reg_write_m,
        load_instr_e => load_instr_e,
        mem_control_m => mem_control_m,
        load_store_m => load_store_m,
        
        flush_w => flush_w,
        
        reg_write_w => reg_write_w,
        result_src_w => result_src_w);
        
     datapath_block: datapath port map(
        clk => clk,
        reset => reset,
        
        stall_f => stall_f,
        stall_d => stall_d,
        stall_e => stall_e,
        stall_m => stall_m,
        flush_d => flush_d,
        flush_e => flush_e,
        flush_w => flush_w,
        
        pc_f => pc_f,
        instr_f => instruction_f,
        
        op_d => op_d,
        funct3_d => funct3_d,
        funct7_b5_d => funct_7_b5_d,
        imm_src_d => imm_src_d,
        rs1_d => rs1_d,
        rs2_d => rs2_d,
        csr_write_d => csr_write_d,
        
        forward_a_e => forward_a_e,
        forward_b_e => forward_b_e,
        pc_src_e => pc_src_e,
        alu_control_e => alu_control_e,
        alu_src_a_e => alu_src_a_e,
        alu_src_b_e => alu_src_b_e,
        pc_target_src_e => pc_target_src_e,
        
        zero_e => zero_e,
        negative_e => negative_e,
        overflow_e => overflow_e,
        carry_e => carry_e,
        
        rs1_e => rs1_e,
        rs2_e => rs2_e,
        rd_e => rd_e,
        
        mem_write_m => mem_write_m,
        write_data_m => write_data_m,
        alu_result_m => alu_result_m,
        read_data_m => read_data_m,
        rd_m => rd_m,
        load_instr_e => load_instr_e,
        
        reg_write_w => reg_write_w,
        result_src_w => result_src_w,
        rd_w => rd_w);
    
    hazard_block: hazard_unit port map(
        clk => clk,
        reset => reset,
        rs1_d => rs1_d,
        rs2_d => rs2_d,
        rs1_e => rs1_e,
        rs2_e => rs2_e,
        rd_e => rd_e,
        rd_m => rd_m,
        rd_w => rd_w,
        pc_src_e => pc_src_e,
        load_instr_e => load_instr_e,
        load_store_m => load_store_m,
        reg_write_m => reg_write_m,
        reg_write_w => reg_write_w,
        instruction_ack => instr_ack,
        instruction_valid => is_instruction_valid,
        data_ack => d_ack,
        forward_a_e => forward_a_e,
        forward_b_e => forward_b_e,
        stall_f => stall_f,
        stall_d => stall_d,
        stall_e => stall_e,
        stall_m => stall_m,
        flush_d => flush_d,
        flush_e => flush_e,
        flush_w => flush_w
        );
     
     is_instruction_valid <= (not reset);
     
     instr_adr <= pc_f;
     instruction_f <= instr_data;
     instr_valid <= is_instruction_valid;
     
     d_adr <= alu_result_m;
     read_data_m <= d_data_r;
     d_data_w <= write_data_m;
     d_sel <= mem_control_m;
     d_we <= mem_write_m;
     
     d_valid <= load_store_m;
        
end Behavioral;
