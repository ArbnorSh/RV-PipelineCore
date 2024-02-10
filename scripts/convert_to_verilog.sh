
PATH_TO_RTL=../rtl
PATH_TO_VERILOG_FOLDER=../vidbo/verilog

mkdir -p build
mkdir -p verilog

ghdl -i --std=08 --work=processor --workdir=build -Pbuild -fsynopsys \
  "$PATH_TO_RTL"/core/*.vhd \
  "$PATH_TO_RTL"/core/common/*.vhd \
  "$PATH_TO_RTL"/core/control/*.vhd \
  "$PATH_TO_RTL"/core/datapath/*.vhd \
  "$PATH_TO_RTL"/core/hazard_unit/*.vhd \
  "$PATH_TO_RTL"/wishbone_memory/*.vhd \

ghdl -m --std=08 --work=processor --workdir=build -fsynopsys processor
ghdl -m --std=08 --work=processor --workdir=build -fsynopsys rom_wb
ghdl -m --std=08 --work=processor --workdir=build -fsynopsys ram_wb

ghdl synth --std=08 -fsynopsys --latches --work=processor --workdir=build -Pbuild --out=verilog processor > "$PATH_TO_VERILOG_FOLDER"/processor.v
ghdl synth --std=08 -fsynopsys --work=processor --workdir=build -Pbuild --out=verilog rom_wb > "$PATH_TO_VERILOG_FOLDER"/rom_wb.v
ghdl synth --std=08 -fsynopsys --work=processor --workdir=build -Pbuild --out=verilog ram_wb > "$PATH_TO_VERILOG_FOLDER"/ram_wb.v
