-- Auto-generated from source file: ext_interrupt_test
-- Size: 60 bytes
-- Built: Sat Jan 27 23:09:39 2024
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package executable_image is

type mem32_t is array (natural range <>) of std_ulogic_vector(31 downto 0);

constant exe_init_image : mem32_t := (
x"08000413",
x"00000297",
x"02428293",
x"30529073",
x"00800313",
x"30031073",
x"00001337",
x"80030313",
x"30431073",
x"00000063",
x"340292f3",
x"342022f3",
x"00542023",
x"340292f3",
x"30200073"
);

end executable_image;
