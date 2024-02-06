-- Auto-generated from source file: led_example
-- Size: 44 bytes
-- Built: Tue Feb  6 00:20:14 2024
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package executable_image is

type mem32_t is array (natural range <>) of std_ulogic_vector(31 downto 0);

constant exe_init_image : mem32_t := (
x"00010e37",
x"fffe0e13",
x"80004eb7",
x"008e8e93",
x"01cea023",
x"800045b7",
x"0005a283",
x"80004537",
x"00450513",
x"00552023",
x"fe0006e3"
);

end executable_image;
