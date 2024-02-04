library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.all;
use IEEE.NUMERIC_STD_UNSIGNED.all;
use ieee.std_logic_textio.all;

library xil_defaultlib;
use xil_defaultlib.executable_image.all;

entity rom_wb is
    generic(
    GEN_FROM_HEX_FILE: std_logic := '0';
    -- power of two
    SIZE_MEM    : natural := 1024
    );
    Port ( wb_clk : in STD_LOGIC;
           wb_rst : in STD_LOGIC;
           wb_adr : in STD_LOGIC_VECTOR (31 downto 0);
           wb_data : out STD_LOGIC_VECTOR (31 downto 0);
           wb_stb : in STD_LOGIC;
           wb_ack : out STD_LOGIC);
end rom_wb;

architecture Behavioral of rom_wb is
    type rom_mem_t is array(0 to SIZE_MEM/4-1) of std_logic_vector(31 downto 0);
    
    impure function init_rom_hex return rom_mem_t is
        file text_file: text open read_mode is "interrupt_test_01.mem";
        variable text_line: line;
        variable rom_content: rom_mem_t;
        variable i, j: integer := 0;
        
        begin
            for i in 0 to 127 loop
                rom_content(i) := (others => '0');
            end loop;
            
            while_loop: while not endfile(text_file) loop
                readline(text_file, text_line);
                if text_line(1) = '#' then
                    next while_loop;
                end if;
                hread(text_line, rom_content(j));
                j := j + 1;
            end loop;
            
            return rom_content;
        end function;
   
   impure function init_rom return rom_mem_t is
        variable rom_content: rom_mem_t;
      begin
        rom_content := (others => (others => '0'));
        -- initialize only in range of source data array
        for i in 0 to exe_init_image'length-1 loop
          rom_content(i) := exe_init_image(i);
        end loop;
        return rom_content;

   end function;
        
    signal rom: rom_mem_t := init_rom;
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
        
            wb_data <= rom(to_integer(read_address));
            
        end if;
        
    end process;
    


end Behavioral;
