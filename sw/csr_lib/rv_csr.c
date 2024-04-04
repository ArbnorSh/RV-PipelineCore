#include "rv_csr.h"

uint64_t get_mcycle(void)
{
    CSRUnion cycle;

    uint32_t cycleHighInitial, cycleLow, cycleHigh;
    while(1) {
      cycleHighInitial = csr_read(CSR_MCYCLEH);
      cycleLow = csr_read(CSR_MCYCLE);
      cycleHigh = csr_read(CSR_MCYCLEH);
      if (cycleHighInitial == cycleHigh) {
        break;
      }
    }

    cycle.parts.low = cycleLow;
    cycle.parts.high = cycleHigh;

    return cycle.full;
}

void set_mcycle(uint64_t value)
{
    CSRUnion cycle;
    cycle.full = value;

    csr_write(CSR_MCYCLE,  0);
    csr_write(CSR_MCYCLEH, cycle.parts.high);
    csr_write(CSR_MCYCLE,  cycle.parts.low);
}

uint64_t get_minstret(void)
{
    CSRUnion instRet;

    uint32_t instRetHighInitial, instRetLow, instRetHigh;
    while(1) {
      instRetHighInitial = csr_read(CSR_MINSTRETH);
      instRetLow = csr_read(CSR_MINSTRET);
      instRetHigh = csr_read(CSR_MINSTRETH);
      if (instRetHighInitial == instRetHigh) {
        break;
      }
    }

    instRet.parts.low = instRetLow;
    instRet.parts.high = instRetHigh;

    return instRet.full;
}

void set_minstret(uint64_t value)
{
    CSRUnion instRet;
    instRet.full = value;

    csr_write(CSR_MINSTRET,  0);
    csr_write(CSR_MINSTRETH, instRet.parts.high);
    csr_write(CSR_MINSTRET,  instRet.parts.low);
}
