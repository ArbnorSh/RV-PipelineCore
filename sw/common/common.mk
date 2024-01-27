USER_SRC ?= $(wildcard ./*.c) $(wildcard ./*.s) $(wildcard ./*.cpp) $(wildcard ./*.S)

USER_INC ?= -I .
ASM_INC ?= -I .

RV_PREFIX ?= riscv64-unknown-elf-

# CPU architecture and ABI
MARCH ?= rv32i_zicsr
MABI  ?= ilp32

# Path to RTL, needed for hex generation
PROCESSOR_HOME ?= ../../..
PROCESSOR_RTL ?= $(PROCESSOR_HOME)/rtl
PROCESSOR_IMAGE_MEM ?= $(PROCESSOR_RTL)/wishbone_memory/executable_image.vhd

PROCESSOR_SCRIPTS = $(PROCESSOR_HOME)/scripts
PROCESSOR_IMAGE_GEN = $(PROCESSOR_SCRIPTS)/bin2hex.py
PROCESSOR_IMAGE_GEN_VHD = $(PROCESSOR_SCRIPTS)/hex2vhdmem.py
PROCESSOR_SW_COMMON_PATH = $(PROCESSOR_HOME)/sw/common

LD_SCRIPT ?= $(PROCESSOR_SW_COMMON_PATH)/processor.ld

EXE_ELF      = app.elf

CC      = $(RISCV_PREFIX)gcc
OBJDUMP = $(RISCV_PREFIX)objdump
OBJCOPY = $(RISCV_PREFIX)objcopy
SIZE    = $(RISCV_PREFIX)size

CFLAGS += -march=$(MARCH) -mabi=$(MABI) -Wall -ffunction-sections 
CFLAGS += -fdata-sections -nostartfiles  -ffreestanding -g -Os

LFLAGS := -T $(LD_SCRIPT) -Wl,--gc-sections

######################################################################################

default: build 

.PHONY: build
build: $(EXE_ELF)

$(EXE_ELF): $(USER_SRC)
	$(RV_PREFIX)-gcc $(CFLAGS) -o $@ $^ $(LFLAGS)
	$(RV_PREFIX)-objdump -htd $@ > $(basename $@).lst
	$(RV_PREFIX)-objcopy -O binary $@ $(basename $@).bin
	@echo "Generating hex from elf"
	$(PROCESSOR_IMAGE_GEN) $(basename $@).bin $(basename $@).hex -w 32
	@echo "Generating vhdl memory"
	$(PROCESSOR_IMAGE_GEN_VHD) --hex $(basename $@).hex --vhd $(basename $@).vhd
	@echo "Installing vhd file to rtl"
	@cp $(basename $@).vhd $(PROCESSOR_IMAGE_MEM)

.PHONY: clean
clean:						
	rm -f *.o *.lst *.elf *.hex *.bin