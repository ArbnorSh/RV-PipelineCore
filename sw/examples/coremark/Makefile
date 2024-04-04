PROCESSOR_HOME ?= ../../..

UART_SOURCE   := $(PROCESSOR_HOME)/sw/uart_lib/c_lang/uart_lib.c
CSR_SOURCE    := $(PROCESSOR_HOME)/sw/csr_lib/rv_csr.c
SRC 		  += $(UART_SOURCE) $(CSR_SOURCE)

C_INC += -I $(PROCESSOR_HOME)/sw/uart_lib/common/ -I $(PROCESSOR_HOME)/sw/uart_lib/c_lang/
C_INC += -I $(PROCESSOR_HOME)/sw/csr_lib/
C_INC += -I .

include $(PROCESSOR_HOME)/sw/common/common.mk
