.section .text.crt0
.balign 4
.global _start

_start:

    // Init Pointers
    .option push
    .option norelax
    la sp, stack_pointer
    la gp, global_pointer
    .option pop

    // data section from LMA to VMA
    la t0, data_start_vma
    la t1, data_end_vma
    la t2, data_start_lma

init_data:
    bgeu t0, t1, init_data_done
    lw t3, 0(t2)
    sw t3, 0(t0)
    addi t0, t0, 4
    addi t2, t2, 4

    j init_data

init_data_done:
    // Zero .bss section
    la t0, bss_start
    la t1, bss_end

clear_bss:
    bgeu t0, t1, end_clear_bss
    sw zero, 0(t0)
    addi t0, t0, 4

    j clear_bss

end_clear_bss:

main_entry:

    mv a0, zero
    mv a1, zero
    jal main

main_exit:
    ebreak
    j main_exit


// ==========================================
// Constants
.equ stack_pointer,     __stack_top
.equ global_pointer,    __global_pointer$
.equ data_start_vma,    __data_start
.equ data_end_vma,      __data_end  
.equ data_start_lma,    __data_rom_start
.equ bss_start,         __bss_start
.equ bss_end,           __bss_end

.end
