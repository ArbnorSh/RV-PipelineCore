import argparse
import os
import time 
import io

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    
    parser.add_argument("--hex_file", help="input hex file", type=str)
    parser.add_argument("--vhd_file", help="output vhdl file", type=str)
    
    args = parser.parse_args()

    input_file = args.hex_file
    output_file = args.vhd_file
    source_file_name = input_file.split('.')[0]

    gen_out_file = r'''-- Auto-generated from source file: {source_file_name}
-- Size: {size} bytes
-- Built: {date}
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package executable_image is

type mem32_t is array (natural range <>) of std_ulogic_vector(31 downto 0);

constant exe_init_image : mem32_t := (
{hex_content}
);

end executable_image;
'''

    hex_data = []
    with open(input_file) as f:
        raw_file_size = 0
        lines = f.read().splitlines()
        for line in lines:
            data = 'x' + '"' + line + '"' + ','
            hex_data.append(data)
            raw_file_size += 4 # +4 bytes for each instruction

        if raw_file_size == 0:
            print(f"Input File is Empty : {input_file}")
            quit()
        print(f"Raw File Size: {raw_file_size}")
    
    hex_data[-1] = hex_data[-1].replace(',', '')

    current_time = time.ctime(time.time())

    file_content = gen_out_file.format(source_file_name=source_file_name, size=raw_file_size, date=current_time, 
                                       hex_content="\n".join(hex_data))

    with open(output_file, "w") as f:
        f.write(file_content)
