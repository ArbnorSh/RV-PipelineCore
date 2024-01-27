-- Auto-generated from source file: interrupts_01/interrupt_ex
-- Size: 56 bytes
-- Built: Sat Jan 27 20:46:30 2024
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package executable_image is

type mem32_t is array (natural range <>) of std_ulogic_vector(31 downto 0);

constant exe_init_image : mem32_t := (
x"08000413",
x"02400293",
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
