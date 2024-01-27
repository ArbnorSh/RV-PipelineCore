library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.all;
use IEEE.NUMERIC_STD_UNSIGNED.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

entity data_memory_wb is
    generic(
    -- power of two
    SIZE_MEM    : natural := 1024
    );
    Port ( wb_clk : in STD_LOGIC;
           wb_rst : in STD_LOGIC;
           wb_adr : in STD_LOGIC_VECTOR (31 downto 0);
           wb_data_r : out STD_LOGIC_VECTOR (31 downto 0);
           wb_data_w : in STD_LOGIC_VECTOR (31 downto 0);
           wb_we : in STD_LOGIC;
           wb_sel : in  STD_LOGIC_VECTOR(3 downto 0);
           wb_stb : in STD_LOGIC;
           wb_ack : out STD_LOGIC);
end data_memory_wb;

architecture Behavioral of data_memory_wb is
    type mem_array is array (natural range <>) of std_logic_vector(31 downto 0);
    signal mem : mem_array(0 to SIZE_MEM/4-1);
    
    signal address: std_logic_vector(29 downto 0);
    signal write_enable : std_logic_vector(3 downto 0);
    
    signal error : std_logic;
begin

    write_enable <= ( 3 downto 0 => wb_we and wb_stb) and wb_sel;
    address <= wb_adr(31 downto 2);
    
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
    
    -- Read/Write Logic
    process(wb_clk) begin
        
        if rising_edge(wb_clk) then
            
            if write_enable(0) then
                mem(to_integer(unsigned(address)))(7 downto 0) <= wb_data_w(7 downto 0);
            end if;
            
            if write_enable(1) then
                mem(to_integer(unsigned(address)))(15 downto 8) <= wb_data_w(15 downto 8);
            end if;
            
            if write_enable(2) then
                mem(to_integer(unsigned(address)))(23 downto 16) <= wb_data_w(23 downto 16);
            end if;
            
            if write_enable(3) then
                mem(to_integer(unsigned(address)))(31 downto 24) <= wb_data_w(31 downto 24);
            end if;
            
            wb_data_r <= mem(to_integer(unsigned(address)));
        
        end if;     
        
    end process;

    

end Behavioral;