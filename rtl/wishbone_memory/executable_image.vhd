-- Auto-generated from source file: led_example
-- Size: 152 bytes
-- Built: Sun Feb  4 19:27:29 2024
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
x"80000317",
x"fe830313",
x"09800393",
x"0062fc63",
x"0003ae03",
x"01c2a023",
x"00428293",
x"00438393",
x"fedff06f",
x"80000297",
x"fc428293",
x"80000317",
x"fbc30313",
x"0062f863",
x"0002a023",
x"00428293",
x"ff5ff06f",
x"00000513",
x"00000593",
x"00c000ef",
x"00100073",
x"ffdff06f",
x"00010737",
x"800047b7",
x"fff70713",
x"00e7a423",
x"800047b7",
x"800046b7",
x"00478793",
x"0006a703",
x"00e7a023",
x"ff9ff06f"
);

end executable_image;
