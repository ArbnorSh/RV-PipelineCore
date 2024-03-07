OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    ROM (rx) : ORIGIN = 0x00000000, LENGTH = 2M
    RAM (rwx): ORIGIN = 0x80000000, LENGTH = 2M
}

SECTIONS
{
    .text : 
    {
        KEEP(*(.text.crt0));
        *(.text.init)

        *(.text)
        *(.text.*)
        
        . = ALIGN(4);

        _etext = .;
    } > ROM

    .data :
    {
        *(.rodata)
        *(.rodata.*)
        
        . = ALIGN(4);
        
        _sdata = .;
        
        *(.data)
        *(.data.*)

        . = ALIGN(4);
        _edata = .;

        . = ALIGN(16);
        /* Addresing Symbols: The 0x800 magic number allows signed 
           12-bit offsets relaxations from _global_pointer */
        __global_pointer$ = . + 0x800;

        *(.sdata)
        *(.sdata.*)
        *(.srodata.*)
        
        . = ALIGN(4);
    } >RAM AT>ROM

    
    /* .bss section which is used for uninitialized data */
    .bss (NOLOAD) :
    {   
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)

        . = ALIGN(4);
        __bss_end = .;
    } > RAM

    _end = . ;
}

PROVIDE(__stack_top      = ORIGIN(RAM) + LENGTH(RAM));
PROVIDE(__data_rom_start = LOADADDR(.data));
PROVIDE(__data_start     = ADDR(.data));
PROVIDE(__data_end       = ADDR(.data) + SIZEOF(.data));
PROVIDE(__bss_start      = __BSS_START__);
PROVIDE(__bss_end        = __BSS_END__);
