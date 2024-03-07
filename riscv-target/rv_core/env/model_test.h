#ifndef _COMPLIANCE_MODEL_H
#define _COMPLIANCE_MODEL_H
#define RVMODEL_DATA_SECTION \
        .pushsection .tohost,"aw",@progbits;                            \
        .align 8; .global tohost; tohost: .dword 0;                     \
        .align 8; .global fromhost; fromhost: .dword 0;                 \
        .popsection;                                                    \
        .align 8; .global begin_regstate; begin_regstate:               \
        .word 128;                                                      \
        .align 8; .global end_regstate; end_regstate:                   \
        .word 4;

//RV_COMPLIANCE_HALT
#define RVMODEL_HALT                     \
      jal uart_init;                     \
      la   a0, begin_signature;          \
      la   a1, end_signature;            \
  signature_dump_loop:                   \
      bge  a0, a1, end_dump;             \
      jal uart_send_hex;                 \
      li a4, '\n';                       \
      jal uart_send_byte;                \
      addi a0, a0, 4;                    \
      j    signature_dump_loop;          \
end_dump:                                \
    .pushsection .data.string;           \
stop_sim:                                \
    .string "RVMODEL_HALT\n";            \
    .popsection;                         \
    la a0, stop_sim;                     \
    jal uart_write_str;                  \
    halt_loop:  j halt_loop;

#define RVMODEL_BOOT                  \
.section .text.init;                  \
        .align  4;                    \
        .globl _start;                \
_start:                               \
    la t0, __data_start;              \
    la t1, __data_end;                \
    la t2, __data_rom_start;          \
                                      \
init_data:                            \
    bgeu t0, t1, init_data_done;      \
    lw t3, 0(t2);                     \
    sw t3, 0(t0);                     \
    addi t0, t0, 4;                   \
    addi t2, t2, 4;                   \
                                      \
    j init_data;                      \
                                      \
init_data_done:                       \
    la t0, __bss_start;               \
    la t1, __bss_end;                 \
                                      \
clear_bss:                            \
    bgeu t0, t1, end_clear_bss;       \
    sw zero, 0(t0);                   \
    addi t0, t0, 4;                   \
                                      \
    j clear_bss;                      \
                                      \
end_clear_bss:                        

//RV_COMPLIANCE_DATA_BEGIN
#define RVMODEL_DATA_BEGIN                                              \
  RVMODEL_DATA_SECTION                                                        \
  .align 4;\
  .global begin_signature; begin_signature:

//RV_COMPLIANCE_DATA_END
#define RVMODEL_DATA_END                                                      \
  .align 4;\
  .global end_signature; end_signature:  

//RVTEST_IO_INIT
#define RVMODEL_IO_INIT
//RVTEST_IO_WRITE_STR
#define RVMODEL_IO_WRITE_STR(_R, _STR)
//RVTEST_IO_CHECK
#define RVMODEL_IO_CHECK()
//RVTEST_IO_ASSERT_GPR_EQ
#define RVMODEL_IO_ASSERT_GPR_EQ(_S, _R, _I)
//RVTEST_IO_ASSERT_SFPR_EQ
#define RVMODEL_IO_ASSERT_SFPR_EQ(_F, _R, _I)
//RVTEST_IO_ASSERT_DFPR_EQ
#define RVMODEL_IO_ASSERT_DFPR_EQ(_D, _R, _I)


#endif // _COMPLIANCE_MODEL_H
