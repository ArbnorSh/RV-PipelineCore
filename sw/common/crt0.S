.section .text
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
    // Init stack and global pointers
    la sp, stack_pointer
    la gp, global_pointer

    mv a0, zero
    mv a1, zero
    jal main

main_exit:
    ebreak
    j main_exit


// ==========================================
// Constants
stack_pointer:  .word __stack_top
global_pointer: .word __global_pointer
data_start_vma: .word __data_start
data_end_vma:   .word __data_end  
data_start_lma: .word __data_rom_start
bss_start:      .word __bss_start
bss_end:        .word __bss_end

.end
