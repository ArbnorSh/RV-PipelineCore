library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           interrupt_external, interrupt_timer : in STD_LOGIC;
           stall_f : in STD_LOGIC;
           pc_f : out STD_LOGIC_VECTOR (31 downto 0);
           instr_f : in STD_LOGIC_VECTOR (31 downto 0);
           instr_d : out STD_LOGIC_VECTOR(31 downto 0);
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
           csr_instr_e : out STD_LOGIC;
           stall_m : in STD_LOGIC;
           flush_m : in STD_LOGIC;
           mem_write_m : in STD_LOGIC;
           write_data_m : out STD_LOGIC_VECTOR (31 downto 0);
           alu_result_m : out STD_LOGIC_VECTOR (31 downto 0);
           read_data_m : in STD_LOGIC_VECTOR (31 downto 0);
           csr_instr_w : out STD_LOGIC;
           flush_w : in STD_LOGIC;
           reg_write_w : in STD_LOGIC;
           result_src_w : in STD_LOGIC_VECTOR (1 downto 0);
           rs1_d, rs2_d, rs1_e, rs2_e : out STD_LOGIC_VECTOR (4 downto 0);
           rd_e, rd_m, rd_w : out STD_LOGIC_VECTOR(4 downto 0);
           is_instr_exception_m : out STD_LOGIC;
           is_instr_exception_e : out STD_LOGIC;
           trap_caught_w : out STD_LOGIC;
           mret_instr_e : in STD_LOGIC;
           illegal_instruction_d, load_store_m : in STD_LOGIC; 
           is_instr_exception_w : out STD_LOGIC;
           illegal_instruction_w, load_misaligned_m, store_misaligned_m: out STD_LOGIC;
           branch_e : in STD_LOGIC;
           take_branch_e : in STD_LOGIC;
           is_decode_flush_d : out STD_LOGIC;
           env_call_instr_d : in STD_LOGIC;
           mul_instr_e : in STD_LOGIC;
           div_instr_e : in STD_LOGIC;
           div_completed_e : out STD_LOGIC;
           is_mispredict_tbranch_e, is_mispredict_ntbranch_e : out STD_LOGIC);
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
               address : in STD_LOGIC_VECTOR (1 downto 0);
               control : in STD_LOGIC_VECTOR (2 downto 0);
               is_load : in STD_LOGIC;
               out_data : out STD_LOGIC_VECTOR (31 downto 0);
               load_misaligned : out STD_LOGIC);
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
               mem_write: in STD_LOGIC;
               write_data_output : out STD_LOGIC_VECTOR (31 downto 0);
               store_misaligned : out STD_LOGIC);
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
               env_call_instr : in STD_LOGIC;
               illegal_instruction, instr_addr_misaligned : in STD_LOGIC;
               load_misaligned, store_misaligned : in STD_LOGIC;
               instr_except_pc : in std_logic_vector(31 downto 0);
               addr_except : in STD_LOGIC_VECTOR(31 downto 0);
               interrupt_external, interrupt_timer : in STD_LOGIC;
               interrupt_external_w, interrupt_timer_w : in STD_LOGIC;
               interrupt_external_m, interrupt_timer_m : out STD_LOGIC;
               out_write_reg : out STD_LOGIC_VECTOR(31 downto 0);
               out_write_csr : out STD_LOGIC_VECTOR (31 downto 0);
               out_mepc : out STD_LOGIC_VECTOR(31 downto 0);
               trap_jump_addr : out STD_LOGIC_VECTOR (31 downto 0);
               trap_caught : out std_logic := '0';
               mret_instr : in std_logic;
               pc_e : in std_logic_vector(31 downto 0);
               valid_pc_w : in STD_LOGIC);
    end component;

    component mul is
        port (
              a, b : in STD_LOGIC_VECTOR(31 downto 0);
              funct3 : in STD_LOGIC_VECTOR(2 downto 0);
              mul_result : out STD_LOGIC_VECTOR(31 downto 0)
              );
    end component;
    
    component div is
        port (
              clk, reset : in STD_LOGIC;
              a, b : in STD_LOGIC_VECTOR(31 downto 0);
              div_start : in STD_LOGIC;
              funct3 : in STD_LOGIC_VECTOR(2 downto 0);
              div_completed : out STD_LOGIC;
              div_result : out STD_LOGIC_VECTOR(31 downto 0)
              );
    end component;
    
    component branch_predictor is
        port (
              clk : in STD_LOGIC;
              pc, pc_e : in STD_LOGIC_VECTOR(31 downto 0);
              branch_instr_e: in STD_LOGIC;
              branch_taken_e : in STD_LOGIC;
              jump_address: in std_logic_vector(31 downto 0);
              branch_predicted : out STD_LOGIC;
              predicted_pc : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component branch_misprediction is
        port (
              valid_pc_e, valid_pc_d : in STD_LOGIC;
              branch_instr, take_branch : in STD_LOGIC;
              jump_target_pc, pc_f, pc_d: in std_logic_vector(31 downto 0);
              pc_plus4_e : out STD_LOGIC_VECTOR(31 downto 0);
              -- Did we mispredict an actual taken branch
              is_mispredict_tbranch_e : out STD_LOGIC;
              -- Did we mispredict an actual not taken branch
              is_mispredict_ntbranch_e : out STD_LOGIC
        );
    end component;
    
    
    signal op_d, op_e : std_logic_vector(6 downto 0);
    signal funct3_d : std_logic_vector(2 downto 0);
    signal funct7_b5_d : std_logic; 
    signal pc_next_no_excep, pc_next_f, pc_plus4_f, read_data_ext_m, pc_src_a_e: std_logic_vector(31 downto 0);
    signal pc_d, pc_plus4_d, rd1_d, rd2_d, imm_ext_d, pc_m, pc_w: std_logic_vector(31 downto 0);
    signal rd_d: std_logic_vector(4 downto 0);
    signal rd1_e, rd2_e, pc_e, imm_ext_e, src_a_e, src_b_e, src_a_forward_e, pc_target_calc_e: std_logic_vector(31 downto 0);
    signal alu_result_e, write_data_e, pc_plus4_e, pc_target_e, pc_target_w, jump_pc_target_e: std_logic_vector(31 downto 0);
    signal pc_plus4_m, alu_result_w, read_data_w, pc_plus4_w, result_w, pc_target_m: std_logic_vector(31 downto 0);
    signal output_from_d_reg: std_logic_vector(96 downto 0);
    signal output_from_e_reg: std_logic_vector(200 downto 0);
    signal output_from_m_reg: std_logic_vector(217 downto 0);
    signal output_from_w_reg: std_logic_vector(218 downto 0);
    signal funct3_e, funct3_m : std_logic_vector(2 downto 0);
    signal pre_write_data_m : std_logic_vector(31 downto 0);
    signal data_output_from_execute : std_logic_vector(31 downto 0);
    
    -- csr
    signal csr_address_e, csr_address_m, csr_address_w : std_logic_vector(11 downto 0);
    signal out_write_csr_e, out_write_reg_e, out_mepc: std_logic_vector(31 downto 0);
    signal csr_write_e, csr_write_m, csr_write_w: std_logic;
    signal out_write_csr_m, out_write_csr_w : std_logic_vector(31 downto 0);
    
    -- excpetions
    signal is_instr_exception_d, instr_addr_misaligned_w: std_logic;
    signal instr_addr_misaligned_f, instr_addr_misaligned_e, instr_addr_misaligned_m: std_logic;
    signal illegal_instruction_e, illegal_instruction_m : std_logic;
    signal store_misaligned_w, load_misaligned_w: std_logic;
    signal interrupt_external_e, interrupt_external_w, interrupt_timer_e, interrupt_timer_w : std_logic;
    signal interrupt_external_m, interrupt_timer_m: std_logic;
    signal trap_jump_addr_w : std_logic_vector(31 downto 0);
    signal mret_instr_m, mret_instr_w, misaligned_pc_e: std_logic;
    signal is_decode_flush_f, env_call_instr_e, env_call_instr_m, env_call_instr_w : std_logic;
    signal addr_except_w: std_logic_vector(31 downto 0);
    signal valid_pc_e, valid_pc_m, valid_pc_w : std_logic;

    -- mul, div
    signal alu_or_muldiv_result_e, mul_result_e, div_result_e : std_logic_vector(31 downto 0);
    signal mul_or_div_result_e : std_logic_vector(31 downto 0);

    -- branch prediction
    signal predicted_pc_f, jump_target_e : std_logic_vector(31 downto 0);
    signal branch_predicted_f : std_logic;

begin

    branch_predict: branch_predictor port map(
        clk => clk,
        pc => pc_f,
        pc_e => pc_e,
        branch_instr_e => branch_e,
        branch_taken_e => take_branch_e,
        jump_address => jump_pc_target_e,
        branch_predicted => branch_predicted_f,
        predicted_pc => predicted_pc_f
    );

    jump_target_e <= pc_plus4_e when is_mispredict_ntbranch_e else
                     jump_pc_target_e;

    pc_next_f <= trap_jump_addr_w when trap_caught_w = '1' else 
                 jump_target_e when pc_src_e = '1' else
                 predicted_pc_f when branch_predicted_f = '1' else
                 pc_plus4_f;
    
    pc_register: flopenr generic map(32) port map(
        clk => clk,
        reset => reset,
        enable => (not stall_f) or (pc_src_e and ( (not is_instr_exception_e) and (not (load_misaligned_m or store_misaligned_m) )) ) 
                   or trap_caught_w,
        d => pc_next_f,
        q => pc_f
        );
        
    pc_add_4: adder port map(
        a => pc_f,
        b => 32X"04",
        y => pc_plus4_f
        );
    
    is_decode_flush_f <= '1';
    
    register_decode: flopenrc generic map(97) port map(
        clk => clk, 
        reset => reset,
        clear => flush_d,
        enable => (not stall_d),
        d => (instr_f & pc_f & pc_plus4_f & is_decode_flush_f),
        q => output_from_d_reg
        );
    
    (instr_d, pc_d, pc_plus4_d, is_decode_flush_d) <= output_from_d_reg;
    
    op_d <= instr_d(6 downto 0);
    funct3_d <= instr_d(14 downto 12);
    funct7_b5_d <= instr_d(30);
    rs1_d <= instr_d(19 downto 15);
    rs2_d <= instr_d(24 downto 20);
    rd_d <= instr_d(11 downto 7);
    
    reg_file: register_file port map(
        clk => clk,
        write_enable => reg_write_w and (not is_instr_exception_w),
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
    
    register_execute: flopenrc generic map(201) port map(
        clk => clk,
        reset => reset,
        clear => flush_e,
        enable => (not stall_e),
        d => (rd1_d & rd2_d & pc_d & rs1_d & rs2_d & rd_d & imm_ext_d & pc_plus4_d
              & funct3_d & instr_d(31 downto 20) & csr_write_d & illegal_instruction_d
              & op_d & env_call_instr_d & is_decode_flush_d),
        q => output_from_e_reg
        );
    
    (rd1_e, rd2_e, pc_e, rs1_e, rs2_e, rd_e, imm_ext_e, pc_plus4_e,
     funct3_e, csr_address_e, csr_write_e, illegal_instruction_e, 
     op_e, env_call_instr_e, valid_pc_e) <= output_from_e_reg;
     
     csr_instr_e <= csr_write_e;
    
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

    multiplier: mul port map(
        a => src_a_e,
        b => src_b_e,
        funct3 => funct3_e,
        mul_result => mul_result_e
        );

    division: div port map(
        clk => clk,
        reset => reset or flush_e,
        a => src_a_e,
        b => src_b_e,
        div_start => div_instr_e,
        funct3 => funct3_e,
        div_completed => div_completed_e,
        div_result => div_result_e
    );

    mul_or_div_result: mux2 generic map(32) port map(
        a => mul_result_e,
        b => div_result_e,
        s => div_instr_e,
        y => mul_or_div_result_e
    );
    
    alu_or_mul_result: mux2 generic map(32) port map(
        a => alu_result_e,
        b => mul_or_div_result_e,
        s => mul_instr_e or div_instr_e,
        y => alu_or_muldiv_result_e
    );
        
    branch_add: adder port map(
        a => pc_src_a_e,
        b => imm_ext_e,
        y => pc_target_calc_e
        );
    -- JALR clears the lowest bit of the calculated
    -- jump target address
    pc_target_e <= ( 31 downto 1 => pc_target_calc_e(31 downto 1), 0 => '0') when op_e = "1100111" else
                  pc_target_calc_e;
    
    csr_unit: csr_exec generic map(
        VENDOR_ID => 32D"32"
    )
    port map(
        clk => clk,
        reset => reset,
        
        interrupt_external => interrupt_external,
        interrupt_timer => interrupt_timer,
        interrupt_external_w => interrupt_external_w,
        interrupt_timer_w => interrupt_timer_w,
        interrupt_external_m => interrupt_external_m,
        interrupt_timer_m => interrupt_timer_m,
        
        csr_address_read => csr_address_e,
        csr_address_write => csr_address_w,
        write_enable => csr_write_w,
        write_value => out_write_csr_w,
        rd1 => rd1_e,
        imm_ext => imm_ext_e,
        funct3 => funct3_e,
        
        env_call_instr => env_call_instr_w,
        instr_addr_misaligned => instr_addr_misaligned_w,
        illegal_instruction => illegal_instruction_w,
        load_misaligned => load_misaligned_w,
        store_misaligned => store_misaligned_w,
        instr_except_pc => pc_w,
        addr_except => addr_except_w,
        trap_jump_addr => trap_jump_addr_w,
        trap_caught => trap_caught_w,
        
        out_write_reg => out_write_reg_e,
        out_write_csr => out_write_csr_e,
        out_mepc => out_mepc,

        mret_instr => mret_instr_w,
        pc_e => pc_e,
        valid_pc_w => valid_pc_w
        );        
    
    jump_pc_target_e <= out_mepc when mret_instr_e = '1' else pc_target_e;
    misaligned_pc_e <= '1' when pc_src_e = '1' and jump_pc_target_e(1) = '1' else
                       '0';

    is_instr_exception_e <= illegal_instruction_e or misaligned_pc_e or env_call_instr_e;

    branch_mispredict: branch_misprediction port map(
        valid_pc_e => valid_pc_e,
        valid_pc_d => is_decode_flush_d,
        branch_instr => branch_e,
        take_branch => take_branch_e,
        jump_target_pc => jump_pc_target_e,
        pc_f => pc_f,
        pc_d => pc_d,
        pc_plus4_e => pc_plus4_e,
        is_mispredict_tbranch_e => is_mispredict_tbranch_e,
        is_mispredict_ntbranch_e => is_mispredict_ntbranch_e
        );
    
    output_from_execute: mux2 generic map(32) port map(
        a => alu_or_muldiv_result_e,
        b => out_write_reg_e,
        s => csr_write_e,
        y => data_output_from_execute
        );
        
    register_memory: flopenrc generic map(218) port map(
        clk => clk,
        reset => reset,
        enable => (not stall_m),
        clear => flush_m,
        d => (data_output_from_execute & write_data_e & rd_e & pc_plus4_e & pc_target_e & funct3_e 
              & csr_address_e & csr_write_e & out_write_csr_e & misaligned_pc_e & pc_e
              & illegal_instruction_e & mret_instr_e & env_call_instr_e & valid_pc_e),
        q => output_from_m_reg
        );
        
    (alu_result_m, pre_write_data_m, rd_m, pc_plus4_m, pc_target_m, funct3_m,
     csr_address_m, csr_write_m, out_write_csr_m, instr_addr_misaligned_m,
     pc_m, illegal_instruction_m, mret_instr_m, env_call_instr_m, valid_pc_m) <= output_from_m_reg;
    
    mem_s: memory_store port map(
        write_data => pre_write_data_m,
        funct3 => funct3_m,
        addr => alu_result_m(1 downto 0),
        mem_write => mem_write_m,
        write_data_output => write_data_m,
        store_misaligned => store_misaligned_m
        );
    
    mask_block: mask_extend port map(
        in_data => read_data_m,
        address => alu_result_m(1 downto 0),
        control => funct3_m,
        is_load => load_store_m and (not mem_write_m),
        out_data => read_data_ext_m,
        load_misaligned => load_misaligned_m
        );
   
    is_instr_exception_m <= instr_addr_misaligned_m or illegal_instruction_m or store_misaligned_m or load_misaligned_m or 
                            interrupt_external_m or interrupt_timer_m or env_call_instr_m;
    
    register_writeback: floprc generic map(219) port map(
        clk => clk,
        reset => reset,
        clear => flush_w,
        d => (alu_result_m & read_data_ext_m & rd_m & pc_plus4_m & pc_target_m 
              & csr_address_m & csr_write_m & out_write_csr_m & instr_addr_misaligned_m
              & pc_m & illegal_instruction_m & store_misaligned_m & load_misaligned_m
              & interrupt_external_m & interrupt_timer_m & mret_instr_m & env_call_instr_m
              & valid_pc_m),
        q => output_from_w_reg
        );
        
    (alu_result_w, read_data_w, rd_w, pc_plus4_w, pc_target_w, 
     csr_address_w, csr_write_w, out_write_csr_w, instr_addr_misaligned_w,
     pc_w, illegal_instruction_w, store_misaligned_w, load_misaligned_w,
     interrupt_external_w, interrupt_timer_w, mret_instr_w, env_call_instr_w,
     valid_pc_w) <= output_from_w_reg;
     
     csr_instr_w <= csr_write_w;
     is_instr_exception_w <= instr_addr_misaligned_w or illegal_instruction_w or store_misaligned_w or load_misaligned_w or
                             interrupt_external_w or interrupt_timer_w or env_call_instr_w;
    
    result_mux: mux4 generic map(32) port map(
        a => alu_result_w,
        b => read_data_w,
        c => pc_plus4_w,
        d => pc_target_w,
        s => result_src_w,
        y => result_w
        );
    
    addr_except_w <= pc_target_w when instr_addr_misaligned_w else
                     pc_w when env_call_instr_w else
                     alu_result_w; 

end Behavioral;
