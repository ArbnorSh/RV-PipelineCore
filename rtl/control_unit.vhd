library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           opcode_d : in STD_LOGIC_VECTOR (6 downto 0);
           funct3_d : in STD_LOGIC_VECTOR (2 downto 0);
           funct7_b5_d : in STD_LOGIC;
           imm_src_d : out STD_LOGIC_VECTOR (2 downto 0);
           flush_e : in STD_LOGIC;
           zero_e : in STD_LOGIC;
           negative_e : in STD_LOGIC;
           overflow_e : in STD_LOGIC;
           carry_e : in STD_LOGIC;
           pc_src_e : out STD_LOGIC;
           alu_control_e : out STD_LOGIC_VECTOR (3 downto 0);
           alu_src_a_e : out STD_LOGIC;
           alu_src_b_e : out STD_LOGIC;
           result_src_b0_e : out STD_LOGIC;
           pc_target_src_e : out STD_LOGIC;
           mem_write_m : out STD_LOGIC;
           reg_write_m : out STD_LOGIC;
           mask_src_m : out STD_LOGIC_VECTOR (2 downto 0);
           mem_control_m : out STD_LOGIC_VECTOR (3 downto 0);
           reg_write_w : out STD_LOGIC;
           result_src_w : out STD_LOGIC_VECTOR (1 downto 0));
end control_unit;

architecture Behavioral of control_unit is
    component main_decoder is
        Port ( op : in STD_LOGIC_VECTOR (6 downto 0);
               branch : out STD_LOGIC;
               jump : out STD_LOGIC;
               result_src : out STD_LOGIC_VECTOR (1 downto 0);
               mem_write : out STD_LOGIC;
               alu_src_a : out STD_LOGIC;
               alu_src_b : out STD_LOGIC;
               imm_src : out STD_LOGIC_VECTOR (2 downto 0);
               reg_write : out STD_LOGIC;
               alu_op : out STD_LOGIC_VECTOR (1 downto 0);
               mask_op : out STD_LOGIC;
               pc_target_src: out STD_LOGIC);
    end component;
    
    component alu_decoder is
        Port ( op_5 : in STD_LOGIC;
               funct3 : in STD_LOGIC_VECTOR (2 downto 0);
               func7_5 : in STD_LOGIC;
               alu_op : in STD_LOGIC_VECTOR (1 downto 0);
               alu_control : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    component floprc is
       generic(width: integer := 8);
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               clear : in STD_LOGIC;
               d : in STD_LOGIC_VECTOR (width - 1 downto 0);
               q : out STD_LOGIC_VECTOR (width - 1 downto 0));
    end component;
    
    component flopr is
        generic(width: integer := 8);
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               d : in STD_LOGIC_VECTOR (width - 1 downto 0);
               q : out STD_LOGIC_VECTOR (width - 1 downto 0));
    end component;
    
    component branch_check is
        Port ( branch: in STD_LOGIC;
               funct3 : in STD_LOGIC_VECTOR (2 downto 0);
               zero : in STD_LOGIC;
               negative : in STD_LOGIC;
               overflow : in STD_LOGIC;
               carry: in STD_LOGIC;
               take_branch : out STD_LOGIC);
    end component;
    
    component mask_decoder is
        Port ( mask_op : in STD_LOGIC;
               funct3 : in STD_LOGIC_VECTOR (2 downto 0);
               mask_src : out STD_LOGIC_VECTOR (2 downto 0));
    end component;
    
    component memory_decoder is
        Port ( mem_write : in STD_LOGIC;
               funct3 : in STD_LOGIC_VECTOR (2 downto 0);
               mem_control : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    signal reg_write_d, reg_write_e: std_logic;
    signal branch_d, branch_e: std_logic;
    signal jump_d, jump_e: std_logic;
    signal result_src_d, result_src_e, result_src_m: std_logic_vector(1 downto 0);
    signal mem_write_d, mem_write_e: std_logic;
    signal alu_op_d: std_logic_vector(1 downto 0);
    signal alu_control_d, mem_control_d, mem_control_e: std_logic_vector(3 downto 0);
    signal alu_src_a_d, alu_src_b_d: std_logic;
    signal output_from_e_floprc: std_logic_vector(22 downto 0);
    signal output_from_m_flopr: std_logic_vector(10 downto 0);
    signal output_from_w_flopr: std_logic_vector(2 downto 0);
    signal funct3_e: std_logic_vector(2 downto 0);
    signal take_branch_e, mask_op_d, mask_op_e, mask_op_m, pc_target_src_d: std_logic;
    signal mask_src_d, mask_src_e: std_logic_vector(2 downto 0);
    
begin
    
    main_dec: main_decoder port map(
        op => opcode_d,
        
        branch => branch_d,
        jump => jump_d,
        
        result_src => result_src_d,
        mem_write => mem_write_d,
        
        alu_src_a => alu_src_a_d,
        alu_src_b => alu_src_b_d,
        
        imm_src => imm_src_d,
        reg_write => reg_write_d,
        alu_op => alu_op_d,
        mask_op => mask_op_d,
        pc_target_src => pc_target_src_d
        );
        
    mask_dec: mask_decoder port map(
        mask_op => mask_op_d,
        funct3 => funct3_d,
        mask_src => mask_src_d
        );
    
    alu_dec: alu_decoder port map(
        op_5 => opcode_d(5),
        funct3 => funct3_d,
        func7_5 => funct7_b5_d,
        alu_op => alu_op_d,
        alu_control => alu_control_d);
    
    mem_dec: memory_decoder port map(
        mem_write => mem_write_d,
        funct3 => funct3_d,
        mem_control => mem_control_d
        );
    
    control_reg_e: floprc generic map(23)
        port map(
            clk => clk, 
            reset => reset, 
            clear => flush_e,
            d => (funct3_d & reg_write_d & result_src_d & mem_write_d & jump_d & branch_d &
             alu_control_d & alu_src_a_d & alu_src_b_d & mask_src_d & pc_target_src_d & mem_control_d),
            q => output_from_e_floprc
        );
    
    (funct3_e, reg_write_e, result_src_e, mem_write_e, jump_e, branch_e,
     alu_control_e, alu_src_a_e, alu_src_b_e, mask_src_e, pc_target_src_e,
     mem_control_e) <= output_from_e_floprc;
    
    branch_block: branch_check port map(
        branch => branch_e,
        funct3 => funct3_e,
        zero => zero_e,
        negative => negative_e,
        overflow => overflow_e,
        carry => carry_e,
        take_branch => take_branch_e
        );
         
    pc_src_e <= take_branch_e or jump_e;
    result_src_b0_e <= result_src_e(0);
    
    control_reg_m: flopr generic map(11)
        port map(
            clk => clk,
            reset => reset,
            d => (reg_write_e & result_src_e & mem_write_e & mask_src_e, mem_control_e),
            q => output_from_m_flopr
        );
        
    (reg_write_m, result_src_m(1), result_src_m(0), mem_write_m,
     mask_src_m, mem_control_m) <= output_from_m_flopr;
    
    control_reg_w: flopr generic map(3)
        port map(
            clk => clk,
            reset => reset,
            d => (reg_write_m & result_src_m),
            q => output_from_w_flopr
        );
        
    (reg_write_w, result_src_w(1), result_src_w(0)) <= output_from_w_flopr;
        

end Behavioral;
