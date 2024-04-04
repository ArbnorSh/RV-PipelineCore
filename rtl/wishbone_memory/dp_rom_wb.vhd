library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.all;
use IEEE.NUMERIC_STD_UNSIGNED.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;

library work;
use work.executable_image.all;

entity dp_rom_wb is
    generic(
    GEN_FROM_HEX_FILE: std_logic := '0';
    -- power of two
    SIZE_MEM    : natural := 1024
    );
    Port ( wb_clk : in STD_LOGIC;
           wb_rst : in STD_LOGIC;

           -- Port A
           a_wb_adr : in STD_LOGIC_VECTOR (31 downto 0);
           a_wb_data : out STD_LOGIC_VECTOR (31 downto 0);
           a_wb_stb : in STD_LOGIC;
           a_wb_cyc : in STD_LOGIC;
           a_wb_ack : out STD_LOGIC;
           
           -- Port B
           b_wb_adr : in STD_LOGIC_VECTOR (31 downto 0);
           b_wb_data : out STD_LOGIC_VECTOR (31 downto 0);
           b_wb_stb : in STD_LOGIC;
           b_wb_cyc : in STD_LOGIC;
           b_wb_ack : out STD_LOGIC
           );
end dp_rom_wb;

architecture Behavioral of dp_rom_wb is
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
        
    constant rom: rom_mem_t := init_rom;
    constant ADDRESS_WIDTH : positive := positive(ceil(log2(real(SIZE_MEM))));
    signal a_read_address, b_read_address : std_logic_vector(ADDRESS_WIDTH - 3 downto 0);
begin
    
    -- PORT A
    a_read_address <= a_wb_adr(ADDRESS_WIDTH - 1 downto 2);
    
    -- Port A - ACK Logic 
    process(wb_clk) begin
        
        if rising_edge(wb_clk) then
        
            if (wb_rst = '1') then
                a_wb_ack <= '0';
            else
                a_wb_ack <= a_wb_stb and a_wb_cyc and (not a_wb_ack);
            end if;
        
        end if;
        
    end process;
    
    -- Port A - Read Logic
    process(wb_clk) begin
    
        if rising_edge(wb_clk) then
        
            a_wb_data <= rom(to_integer(a_read_address));
            
        end if;
        
    end process;

    -- PORT B 
    b_read_address <= b_wb_adr(ADDRESS_WIDTH - 1 downto 2);
    
    -- Port B - ACK Logic 
    process(wb_clk) begin
        
        if rising_edge(wb_clk) then
        
            if (wb_rst = '1') then
                b_wb_ack <= '0';
            else
                b_wb_ack <= b_wb_stb and b_wb_cyc and (not b_wb_ack);
            end if;
        
        end if;
        
    end process;
    
    -- Port B - Read Logic
    process(wb_clk) begin
    
        if rising_edge(wb_clk) then
        
            b_wb_data <= rom(to_integer(b_read_address));
            
        end if;
        
    end process;
    


end Behavioral;
