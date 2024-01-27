# s0 = [0x80]
li s0, 0x80

# mtvec = _exception_handler
la t0, _exception_handler
csrw mtvec, t0

# enable mie
li t1, 0x08
csrw mstatus, t1

# enable meie
li t1, 0x800
csrw mie, t1

# infinite loop
# after some time, interrupt will trigger
nop_exit:
beq x0, x0, nop_exit


_exception_handler:
    csrrw t0, mscratch, t0
    
    csrr t0, mcause     # external interrupt
    sw t0, 0(s0)        # [0x80] = 11
    
    csrrw t0, mscratch, t0
    mret



