library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is
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
           stall_m : in STD_LOGIC;
           mem_write_m : in STD_LOGIC;
           write_data_m : out STD_LOGIC_VECTOR (31 downto 0);
           alu_result_m : out STD_LOGIC_VECTOR (31 downto 0);
           read_data_m : in STD_LOGIC_VECTOR (31 downto 0);
           mask_src_m : in STD_LOGIC_VECTOR (2 downto 0);
           flush_w : in STD_LOGIC;
           reg_write_w : in STD_LOGIC;
           result_src_w : in STD_LOGIC_VECTOR (1 downto 0);
           rs1_d, rs2_d, rs1_e, rs2_e : out STD_LOGIC_VECTOR (4 downto 0);
           rd_e, rd_m, rd_w : out STD_LOGIC_VECTOR(4 downto 0));
end datapath;

architecture Behavioral of datapath is
    component mux2 is
        generic(width : integer := 8);
        Port ( a : in STD_LOGIC_VECTOR (width - 1 downto 0);
               b : in STD_LOGIC_VECTOR (width - 1 downto 0);
               s : in STD_LOGIC;
               y : out STD_LOGIC_VECTOR (width - 1 downto 0));
    end component;
    
    component flopenr is
        generic(width: integer := 8);
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               enable : in STD_LOGIC;
               d : in STD_LOGIC_VECTOR (width - 1 downto 0);
               q : out STD_LOGIC_VECTOR (width - 1 downto 0));
    end component;
    
    component adder is
        Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
               b : in STD_LOGIC_VECTOR (31 downto 0);
               y : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component flopenrc is
        generic(width: integer := 8);
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               clear: in STD_LOGIC;
               enable : in STD_LOGIC;
               d : in STD_LOGIC_VECTOR (width - 1 downto 0);
               q : out STD_LOGIC_VECTOR (width - 1 downto 0));
    end component;
    
    component register_file is
        Port ( clk : in STD_LOGIC;
               write_enable : in STD_LOGIC;
               a1 : in STD_LOGIC_VECTOR (4 downto 0);
               a2 : in STD_LOGIC_VECTOR (4 downto 0);
               a3 : in STD_LOGIC_VECTOR (4 downto 0);
               write_data : in STD_LOGIC_VECTOR (31 downto 0);
               rd1 : out STD_LOGIC_VECTOR (31 downto 0);
               rd2 : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component extend_imm is
        Port ( instr : in STD_LOGIC_VECTOR (31 downto 7);
               type_of_imm : in STD_LOGIC_VECTOR (2 downto 0);
               ext_imm : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component floprc is
       generic(width: integer := 8);
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               clear : in STD_LOGIC;
               d : in STD_LOGIC_VECTOR (width - 1 downto 0);
               q : out STD_LOGIC_VECTOR (width - 1 downto 0));
    end component;
    
    component mux3 is
        generic(width : integer := 8);
        Port ( a : in STD_LOGIC_VECTOR (width - 1 downto 0);
               b : in STD_LOGIC_VECTOR (width - 1 downto 0);
               c : in STD_LOGIC_VECTOR (width - 1 downto 0);
               s : in STD_LOGIC_VECTOR (1 downto 0);
               y : out STD_LOGIC_VECTOR (width - 1 downto 0));
    end component;
    
    component alu is
        port (
              a, b: in std_logic_vector(31 downto 0);
              alucontrol: in std_logic_vector(3 downto 0);
              result: out std_logic_vector(31 downto 0);
              zero, negative: out std_logic;
              carry, overflow: out std_logic
              );
    end component;
    
    component flopr is
        generic(width: integer := 8);
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               d : in STD_LOGIC_VECTOR (width - 1 downto 0);
               q : out STD_LOGIC_VECTOR (width - 1 downto 0));
    end component;
    
    component mask_extend is
        Port ( in_data : in STD_LOGIC_VECTOR (31 downto 0);
               control : in STD_LOGIC_VECTOR (2 downto 0);
               out_data : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component mux4 is
    generic(width : integer := 8);
        Port ( a : in STD_LOGIC_VECTOR (width - 1 downto 0);
               b : in STD_LOGIC_VECTOR (width - 1 downto 0);
               c : in STD_LOGIC_VECTOR (width - 1 downto 0);
               d : in STD_LOGIC_VECTOR (width - 1 downto 0);
               s : in STD_LOGIC_VECTOR (1 downto 0);
               y : out STD_LOGIC_VECTOR (width - 1 downto 0));
    end component;
    
   component memory_store is
        Port ( write_data : in STD_LOGIC_VECTOR (31 downto 0);
               funct3 : in STD_LOGIC_VECTOR (2 downto 0);
               addr : in STD_LOGIC_VECTOR(1 downto 0);
               mem_write : in STD_LOGIC;
               write_data_output : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component csr_exec is
        generic(
          VENDOR_ID : std_logic_vector(31 downto 0) := (others => '0');
          ARCHITECTURE_ID : std_logic_vector(31 downto 0) := (others => '0');
          IMPLEMENTATION_ID : std_logic_vector(31 downto 0) := (others => '0');
          HART_ID : std_logic_vector(31 downto 0) := (others => '0')
        );
        Port ( clk, reset : in STD_LOGIC;
               csr_address_read : in STD_LOGIC_VECTOR (11 downto 0);
               csr_address_write : in STD_LOGIC_VECTOR (11 downto 0);
               write_enable : in STD_LOGIC;
               write_value : in STD_LOGIC_VECTOR(31 downto 0);
               rd1 : in STD_LOGIC_VECTOR (31 downto 0);
               imm_ext : in STD_LOGIC_VECTOR (31 downto 0);
               funct3 : in STD_LOGIC_VECTOR (2 downto 0);
               out_write_reg : out STD_LOGIC_VECTOR(31 downto 0);
               out_write_csr : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    signal pc_next_f, pc_plus4_f, read_data_ext_m, pc_src_a_e: std_logic_vector(31 downto 0);
    signal instr_d, pc_d, pc_plus4_d, rd1_d, rd2_d, imm_ext_d: std_logic_vector(31 downto 0);
    signal rd_d: std_logic_vector(4 downto 0);
    signal rd1_e, rd2_e, pc_e, imm_ext_e, src_a_e, src_b_e, src_a_forward_e: std_logic_vector(31 downto 0);
    signal alu_result_e, write_data_e, pc_plus4_e, pc_target_e, pc_target_w: std_logic_vector(31 downto 0);
    signal pc_plus4_m, alu_result_w, read_data_w, pc_plus4_w, result_w, pc_target_m: std_logic_vector(31 downto 0);
    signal output_from_d_reg: std_logic_vector(95 downto 0);
    signal output_from_e_reg: std_logic_vector(210 downto 0);
    signal output_from_m_reg: std_logic_vector(200 downto 0);
    signal output_from_w_reg: std_logic_vector(197 downto 0);
    signal funct3_e, funct3_m : std_logic_vector(2 downto 0);
    signal pre_write_data_m : std_logic_vector(31 downto 0);
    signal data_output_from_execute : std_logic_vector(31 downto 0);
    
    -- csr
    signal csr_address_e, out_write_csr_e, out_write_reg_e: std_logic_vector(31 downto 0);
    signal csr_write_e, csr_write_m, csr_write_w: std_logic;
    signal csr_address_m, out_write_csr_m, out_write_csr_w, csr_address_w : std_logic_vector(31 downto 0);

begin

    next_pc: mux2 generic map(32) port map(
        a => pc_plus4_f, 
        b => pc_target_e,
        s => pc_src_e, 
        y => pc_next_f);
    
    pc_register: flopenr generic map(32) port map(
        clk => clk,
        reset => reset,
        enable => (not stall_f) or pc_src_e,
        d => pc_next_f,
        q => pc_f
        );
        
    pc_add_4: adder port map(
        a => pc_f,
        b => 32X"04",
        y => pc_plus4_f
        );
    
    register_decode: flopenrc generic map(96) port map(
        clk => clk, 
        reset => reset,
        clear => flush_d,
        enable => (not stall_d),
        d => (instr_f & pc_f & pc_plus4_f),
        q => output_from_d_reg
        );
    
    (instr_d, pc_d, pc_plus4_d) <= output_from_d_reg;
    
    op_d <= instr_d(6 downto 0);
    funct3_d <= instr_d(14 downto 12);
    funct7_b5_d <= instr_d(30);
    rs1_d <= instr_d(19 downto 15);
    rs2_d <= instr_d(24 downto 20);
    rd_d <= instr_d(11 downto 7);
    
    reg_file: register_file port map(
        clk => clk,
        write_enable => reg_write_w,
        a1 => rs1_d,
        a2 => rs2_d,
        a3 => rd_w,
        write_data => result_w,
        rd1 => rd1_d,
        rd2 => rd2_d
        );
        
    extend_immediate: extend_imm port map(
        instr => instr_d(31 downto 7),
        type_of_imm => imm_src_d,
        ext_imm => imm_ext_d
        );
    
    register_execute: flopenrc generic map(211) port map(
        clk => clk,
        reset => reset,
        clear => flush_e,
        enable => (not stall_e),
        d => (rd1_d & rd2_d & pc_d & rs1_d & rs2_d & rd_d & imm_ext_d & pc_plus4_d
              & funct3_d & instr_d(31 downto 20) & csr_write_d),
        q => output_from_e_reg
        );
    
    (rd1_e, rd2_e, pc_e, rs1_e, rs2_e, rd_e, imm_ext_e, pc_plus4_e,
     funct3_e, csr_address_e, csr_write_e) <= output_from_e_reg;
    
    pc_target_src_select: mux2 generic map(32) port map(
        a => rd1_e,
        b => pc_e,
        s => pc_target_src_e,
        y => pc_src_a_e
        );
    
    forward_a_mux_e: mux3 generic map(32) port map(
        a => rd1_e,
        b => result_w,
        c => alu_result_m,
        s => forward_a_e,
        y => src_a_forward_e
        );
        
    src_a_mux_e: mux2 generic map(32) port map(
        a => src_a_forward_e,
        b => 32X"0",
        s => alu_src_a_e,
        y => src_a_e
        );
        
   forward_b_mux_e: mux3 generic map(32) port map(
        a => rd2_e,
        b => result_w,
        c => alu_result_m,
        s => forward_b_e,
        y => write_data_e
        );
        
    src_b_mux_e: mux2 generic map(32) port map(
        a => write_data_e,
        b => imm_ext_e,
        s => alu_src_b_e,
        y => src_b_e
        );
        
    alu_block: alu port map(
        a => src_a_e,
        b => src_b_e,
        alucontrol => alu_control_e,
        result => alu_result_e,
        zero => zero_e,
        negative => negative_e,
        carry => carry_e,
        overflow => overflow_e
        );
        
    branch_add: adder port map(
        a => pc_src_a_e,
        b => imm_ext_e,
        y => pc_target_e
        );
    
    csr_unit: csr_exec port map(
        clk => clk,
        reset => reset,
        csr_address_read => csr_address_e,
        csr_address_write => csr_address_w,
        write_enable => csr_write_w,
        write_value => out_write_csr_w,
        rd1 => rd1_e,
        imm_ext => imm_ext_e,
        funct3 => funct3_e,
        out_write_reg => out_write_reg_e,
        out_write_csr => out_write_csr_e
        );
    
    output_from_execute: mux2 generic map(32) port map(
        a => alu_result_e,
        b => out_write_reg_e,
        s => csr_write_e,
        y => data_output_from_execute
        );
        
    register_memory: flopenr generic map(201) port map(
        clk => clk,
        reset => reset,
        enable => (not stall_m),
        d => (data_output_from_execute & write_data_e & rd_e & pc_plus4_e & pc_target_e & funct3_e 
              & csr_address_e & csr_write_e & out_write_csr_e),
        q => output_from_m_reg
        );
        
    (alu_result_m, pre_write_data_m, rd_m, pc_plus4_m, pc_target_m, funct3_m,
     csr_address_m, csr_write_m, out_write_csr_m) <= output_from_m_reg;
    
    mem_s: memory_store port map(
        write_data => pre_write_data_m,
        funct3 => funct3_m,
        addr => alu_result_m(1 downto 0),
        mem_write => mem_write_m,
        write_data_output => write_data_m
        );
    
    mask_block: mask_extend port map(
        in_data => read_data_m, 
        control => mask_src_m,
        out_data => read_data_ext_m
        );
    
    register_writeback: floprc generic map(198) port map(
        clk => clk,
        reset => reset,
        clear => flush_w,
        d => (alu_result_m & read_data_ext_m & rd_m & pc_plus4_m & pc_target_m 
              & csr_address_m & csr_write_m & out_write_csr_m),
        q => output_from_w_reg
        );
        
    (alu_result_w, read_data_w, rd_w, pc_plus4_w, pc_target_w, 
     csr_address_w, csr_write_w, out_write_csr_w) <= output_from_w_reg;
    
    result_mux: mux4 generic map(32) port map(
        a => alu_result_w,
        b => read_data_w,
        c => pc_plus4_w,
        d => pc_target_w,
        s => result_src_w,
        y => result_w
        );

end Behavioral;
