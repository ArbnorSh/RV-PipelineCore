#include <stdint.h>

#define CSR_CYCLE		0xc00
#define CSR_CYCLEH		0xc80
#define CSR_MSTATUS		0x300
#define CSR_MISA		0x301
#define CSR_MIE			0x304
#define CSR_MTVEC		0x305
#define CSR_MSCRATCH	0x340
#define CSR_MEPC		0x341
#define CSR_MCAUSE		0x342
#define CSR_MTVAL		0x343
#define CSR_MIP			0x344
#define CSR_MVENDORID   0xf11
#define CSR_MARCHID		0xf12
#define CSR_MIMPID		0xf13
#define CSR_MHARTID		0xf14

inline uint32_t csr_read(int csr_number);
inline void csr_write(int csr_number, uint32_t data);
inline void csr_set(const int csr_number, uint32_t mask);
inline void csr_clr(const int csr_number, uint32_t mask);
