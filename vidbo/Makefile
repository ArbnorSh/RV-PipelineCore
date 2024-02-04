TOP_MODULE = rvsocsim
VERILATOR_VC_FILE = rvsocsim_vidbo.vc
VERILATOR_OPTIONS = -Wall

# Generate the executable
V$(TOP_MODULE): V$(TOP_MODULE).mk
	$(MAKE) $(MAKE_OPTIONS) -f $<

# Generate the Makefile
V$(TOP_MODULE).mk:
	$(VERILATOR) -f $(VERILATOR_VC_FILE) $(VERILATOR_OPTIONS)

.PHONY : clean
clean :
	-rm V$(TOP_MODULE)*
	-rm *.o
	-rm *.d
