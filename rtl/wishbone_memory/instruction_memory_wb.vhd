library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.all;
use IEEE.NUMERIC_STD_UNSIGNED.all;
use ieee.std_logic_textio.all;

entity instruction_memory_wb is
    Port ( wb_clk : in STD_LOGIC;
           wb_rst : in STD_LOGIC;
           wb_adr : in STD_LOGIC_VECTOR (31 downto 0);
           wb_data : out STD_LOGIC_VECTOR (31 downto 0);
           wb_stb : in STD_LOGIC;
           wb_ack : out STD_LOGIC);
end instruction_memory_wb;

architecture Behavioral of instruction_memory_wb is
    type instr_mem_t is array(127 downto 0) of std_logic_vector(31 downto 0);
    
    impure function init_ram_hex return instr_mem_t is
        file text_file: text open read_mode is "interrupt_test_01.mem";
        variable text_line: line;
        variable ram_content: instr_mem_t;
        variable i, j: integer := 0;
        
        begin
            for i in 0 to 127 loop
                ram_content(i) := (others => '0');
            end loop;
            
            while_loop: while not endfile(text_file) loop
                readline(text_file, text_line);
                if text_line(1) = '#' then
                    next while_loop;
                end if;
                hread(text_line, ram_content(j));
                j := j + 1;
            end loop;
            
            return ram_content;
        end function;
        
    signal instr_mem: instr_mem_t := init_ram_hex;
    signal read_address : std_logic_vector(29 downto 0);
begin
    
    read_address <= wb_adr(31 downto 2);
    
    -- ACK Logic 
    process(wb_clk) begin
        
        if rising_edge(wb_clk) then
        
            if (wb_rst = '1') then
                wb_ack <= '0';
            else
                wb_ack <= wb_stb and (not wb_ack);
            end if;
        
        end if;
        
    end process;
    
    -- Read Logic
    process(wb_clk) begin
    
        if rising_edge(wb_clk) then
        
            wb_data <= instr_mem(to_integer(read_address));
            
        end if;
        
    end process;
    


end Behavioral;
