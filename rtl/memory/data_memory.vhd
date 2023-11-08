library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity data_memory is
    Port ( clk : in STD_LOGIC;
           address : in STD_LOGIC_VECTOR (31 downto 0);
           write_data : in STD_LOGIC_VECTOR (31 downto 0);
           write_enable : in STD_LOGIC;
           bytes_to_write: in STD_LOGIC_VECTOR(3 downto 0);
           read_data : out STD_LOGIC_VECTOR (31 downto 0));
end data_memory;

architecture Behavioral of data_memory is
    -- memory with 8-bit entries
    type mem8_t is array (natural range <>) of std_logic_vector(07 downto 0);
    
    signal mem_ram_b0 : mem8_t(0 to 255);
    signal mem_ram_b1 : mem8_t(0 to 255);
    signal mem_ram_b2 : mem8_t(0 to 255);
    signal mem_ram_b3 : mem8_t(0 to 255);
    
    signal mem_ram_b0_rd, mem_ram_b1_rd, mem_ram_b2_rd, mem_ram_b3_rd : std_logic_vector(7 downto 0);

begin

  process(clk)
  begin
    if rising_edge(clk) and write_enable = '1' then
    
        if (bytes_to_write(0) = '1') then -- byte 0
          mem_ram_b0(to_integer(unsigned(address(7 downto 0)))) <= write_data(07 downto 00);
        end if;
        
        if (bytes_to_write(1) = '1') then -- byte 1
          mem_ram_b1(to_integer(unsigned(address(7 downto 0)))) <= write_data(15 downto 08);
        end if;
        
        if (bytes_to_write(2) = '1') then -- byte 2
          mem_ram_b2(to_integer(unsigned(address(7 downto 0)))) <= write_data(23 downto 16);
        end if;
        
        if (bytes_to_write(3) = '1') then -- byte 3
          mem_ram_b3(to_integer(unsigned(address(7 downto 0)))) <= write_data(31 downto 24);
        end if;
    
    end if;
  end process;
  
  mem_ram_b0_rd <= mem_ram_b0(to_integer(unsigned(address(7 downto 0))));
  mem_ram_b1_rd <= mem_ram_b1(to_integer(unsigned(address(7 downto 0))));
  mem_ram_b2_rd <= mem_ram_b2(to_integer(unsigned(address(7 downto 0))));
  mem_ram_b3_rd <= mem_ram_b3(to_integer(unsigned(address(7 downto 0))));
  
  -- pack
  read_data <= mem_ram_b3_rd & mem_ram_b2_rd & mem_ram_b1_rd & mem_ram_b0_rd;


end Behavioral;
