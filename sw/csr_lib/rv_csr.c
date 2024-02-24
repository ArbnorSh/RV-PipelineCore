// Privileged CSR Instructions
// Helper functions to use them from C
#include <rv_csr.h>

inline uint32_t csr_read(int csr_number) {

  uint32_t csr_data;

  asm volatile ("csrr %[result], %[input_i]" : [result] "=r" (csr_data) : [input_i] "i" (csr_number));

  return csr_data;
}

inline void csr_write(int csr_number, uint32_t data) {

  uint32_t csr_data = data;

  asm volatile ("csrw %[input_i], %[input_j]" :  : [input_i] "i" (csr_number), [input_j] "r" (csr_data));
}

inline void csr_set(const int csr_number, uint32_t mask) {

  uint32_t csr_data = mask;

  asm volatile ("csrs %[input_i], %[input_j]" :  : [input_i] "i" (csr_number), [input_j] "r" (csr_data));
}

inline void csr_clr(const int csr_number, uint32_t mask) {

  uint32_t csr_data = mask;

  asm volatile ("csrc %[input_i], %[input_j]" :  : [input_i] "i" (csr_number), [input_j] "r" (csr_data));
}
