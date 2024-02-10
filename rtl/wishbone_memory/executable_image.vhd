-- Auto-generated from source file: uart
-- Size: 232 bytes
-- Built: Sat Feb 10 17:55:57 2024
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package executable_image is

type mem32_t is array (natural range <>) of std_ulogic_vector(31 downto 0);

constant exe_init_image : mem32_t := (
x"80002117",
x"00010113",
x"80001197",
x"80818193",
x"80000297",
x"ff028293",
x"80000317",
x"ff830313",
x"0d800393",
x"0062fc63",
x"0003ae03",
x"01c2a023",
x"00428293",
x"00438393",
x"fedff06f",
x"80000297",
x"fd428293",
x"80000317",
x"fcc30313",
x"0062f863",
x"0002a023",
x"00428293",
x"ff5ff06f",
x"00000513",
x"00000593",
x"060000ef",
x"00100073",
x"ffdff06f",
x"800052b7",
x"08000313",
x"00628623",
x"01b00393",
x"00728023",
x"00300e13",
x"01c28623",
x"08600e93",
x"01d28423",
x"00028223",
x"00008067",
x"800052b7",
x"00050303",
x"01428383",
x"0203f393",
x"fe038ce3",
x"00628023",
x"00150513",
x"00050303",
x"fe0314e3",
x"00008067",
x"fadff0ef",
x"80000517",
x"f3850513",
x"fcdff0ef",
x"00000063",
x"6c6c6548",
x"6f57206f",
x"0d646c72",
x"0000000a"
);

end executable_image;
