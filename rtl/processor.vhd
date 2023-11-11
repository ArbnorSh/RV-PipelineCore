library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity processor is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           read_data : out STD_LOGIC_VECTOR (31 downto 0);
           mem_write : out STD_LOGIC;
           write_data : out STD_LOGIC_VECTOR (31 downto 0);
           data_address : out STD_LOGIC_VECTOR (31 downto 0));
end processor;

architecture Behavioral of processor is
    component core_riscv is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           pc_f : out STD_LOGIC_VECTOR (31 downto 0);
           instruction_f : in STD_LOGIC_VECTOR (31 downto 0);
           mem_write_m : out STD_LOGIC;
           alu_result_m : out STD_LOGIC_VECTOR (31 downto 0);
           write_data_m : out STD_LOGIC_VECTOR (31 downto 0);
           read_data_m : in STD_LOGIC_VECTOR (31 downto 0));
    end component;

    component data_memory is
        Port ( clk : in STD_LOGIC;
               address : in STD_LOGIC_VECTOR (31 downto 0);
               write_data : in STD_LOGIC_VECTOR (31 downto 0);
               write_enable : in STD_LOGIC;
               bytes_to_write: in STD_LOGIC_VECTOR(3 downto 0);
               read_data : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    component instruction_memory is
        Port ( address : in STD_LOGIC_VECTOR (31 downto 0);
               read : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    
    signal pc_f, instr_f: std_logic_vector(31 downto 0);
begin

    riscv: core_riscv port map(
        clk => clk, 
        reset => reset,
         
        pc_f => pc_f, 
        instruction_f => instr_f,
        
        mem_write_m => mem_write, 
        alu_result_m => data_address,
        write_data_m => write_data,
        
        read_data_m => read_data);
    
    imem: instruction_memory port map(pc_f, instr_f);
    
    dmem: data_memory port map(clk, data_address, write_data, mem_write, "1111", read_data);

end Behavioral;
