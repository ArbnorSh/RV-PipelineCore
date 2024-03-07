USER_SRC ?= $(wildcard ./*.c) $(wildcard ./*.s) $(wildcard ./*.cpp) $(wildcard ./*.S)

C_INC ?= -I .
ASM_INC ?= -I .

RISCV_PREFIX ?= riscv32-unknown-elf-

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

CC      = $(RISCV_PREFIX)gcc
OBJDUMP = $(RISCV_PREFIX)objdump
OBJCOPY = $(RISCV_PREFIX)objcopy
SIZE    = $(RISCV_PREFIX)size

CFLAGS += -march=$(MARCH) -mabi=$(MABI) -Wall -ffunction-sections 
CFLAGS += -fdata-sections -nostartfiles -ffreestanding -g -Os

LFLAGS := -T $(LD_SCRIPT) -Wl,--gc-sections

STARTUP_CODE := $(PROCESSOR_SW_COMMON_PATH)/crt0.S

SRC += $(USER_SRC)
SRC += $(STARTUP_CODE)

OBJECTS = $(SRC:%=%.o)

######################################################################################

EXE_ELF = $(shell basename $(CURDIR))

default: build 

.PHONY: build
build: $(EXE_ELF).elf

# source file into an object file
%.s.o: %.s
	@$(CC) -c $(CFLAGS) $(ASM_INC) $< -o $@

%.S.o: %.S
	@$(CC) -c $(CFLAGS) $(ASM_INC) $< -o $@

%.c.o: %.c
	@$(CC) -c $(CFLAGS) $(C_INC) $< -o $@

%.cpp.o: %.cpp
	@$(CC) -c $(CFLAGS) $(C_INC) $< -o $@

# Final executable
$(EXE_ELF).elf: $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^ $(LFLAGS)
	$(OBJDUMP) -htd $@ > $(basename $@).lst
	$(OBJCOPY) -O binary $@ $(basename $@).bin
	@echo "Generating hex from elf"
	python $(PROCESSOR_IMAGE_GEN) $(basename $@).bin $(basename $@).hex -w 32
	@echo "Generating vhdl memory"
	python $(PROCESSOR_IMAGE_GEN_VHD) --hex $(basename $@).hex --vhd $(basename $@).vhd
	@echo "Installing vhd file to rtl"
	@cp $(basename $@).vhd $(PROCESSOR_IMAGE_MEM)

.PHONY: clean
clean:						
	rm -f *.o *.lst *.elf *.hex *.bin *.vhd