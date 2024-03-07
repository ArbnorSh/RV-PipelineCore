PATH_TO_CONVERT_SCRIPT ?= ../scripts/convert_to_verilog.sh

TOP_MODULE = rvsocsim
VERILATOR_VC_FILE = rvsocsim_vidbo.vc
VERILATOR=verilator

VERILATOR_OPTIONS = -Wno-fatal --trace --timescale 1ns/1ns

# Generate the executable
V$(TOP_MODULE): V$(TOP_MODULE).mk
	$(MAKE) $(MAKE_OPTIONS) -f $<

# Generate the Makefile
V$(TOP_MODULE).mk:
	@echo "Generating the verilog source"
	@bash ${PATH_TO_CONVERT_SCRIPT} ${SIZE_MEM}
	$(VERILATOR) -f $(VERILATOR_VC_FILE) $(VERILATOR_OPTIONS)

.PHONY : clean
clean :
	-rm V$(TOP_MODULE)*
	-rm *.o
	-rm *.d
