-- Auto-generated from source file: led_example
-- Size: 144 bytes
-- Built: Tue Feb  6 23:36:09 2024
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package executable_image is

type mem32_t is array (natural range <>) of std_ulogic_vector(31 downto 0);

constant exe_init_image : mem32_t := (
x"80002117",
x"00010113",
x"80000197",
x"7f818193",
x"80000297",
x"ff028293",
x"80418313",
x"08c00393",
x"0062fc63",
x"0003ae03",
x"01c2a023",
x"00428293",
x"00438393",
x"fedff06f",
x"80418293",
x"80418313",
x"0062f863",
x"0002a023",
x"00428293",
x"ff5ff06f",
x"00000513",
x"00000593",
x"00c000ef",
x"00100073",
x"ffdff06f",
x"800007b7",
x"0007a703",
x"800047b7",
x"800046b7",
x"00e7a423",
x"800047b7",
x"00478793",
x"0006a703",
x"00e7a023",
x"ff9ff06f",
x"0000ffff"
);

end executable_image;
