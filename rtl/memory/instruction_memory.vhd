library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.all;
use IEEE.NUMERIC_STD_UNSIGNED.all;
use ieee.std_logic_textio.all;

entity instruction_memory is
    Port ( address : in STD_LOGIC_VECTOR (31 downto 0);
           read : out STD_LOGIC_VECTOR (31 downto 0));
end instruction_memory;

architecture Behavioral of instruction_memory is
    type instr_mem_t is array(127 downto 0) of std_logic_vector(31 downto 0);
    
    impure function init_ram_hex return instr_mem_t is
        file text_file: text open read_mode is "riscv_program_04.mem";
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
begin
    
    process(address)
    begin
        
        read <= instr_mem(to_integer(address(31 downto 2)));
        
    end process;

end Behavioral;
