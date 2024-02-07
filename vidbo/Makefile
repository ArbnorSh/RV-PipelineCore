PATH_TO_CONVERT_SCRIPT ?= ../scripts/convert_to_verilog.sh

TOP_MODULE = rvsocsim
VERILATOR_VC_FILE = rvsocsim_vidbo.vc
VERILATOR=verilator

# Generate the executable
V$(TOP_MODULE): V$(TOP_MODULE).mk
	$(MAKE) $(MAKE_OPTIONS) -f $<

# Generate the Makefile
V$(TOP_MODULE).mk:
	@echo "Generating the verilog source"
	@"${PATH_TO_CONVERT_SCRIPT}"
	$(VERILATOR) -f $(VERILATOR_VC_FILE) -Wno-fatal

.PHONY : clean
clean :
	-rm V$(TOP_MODULE)*
	-rm *.o
	-rm *.d
