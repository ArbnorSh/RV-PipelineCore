-- For details on CSR, refer to privilege RISC-V Specification

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity csr_exec is
    generic(
      VENDOR_ID : std_logic_vector(31 downto 0) := (others => '0');
      ARCHITECTURE_ID : std_logic_vector(31 downto 0) := (others => '0');
      IMPLEMENTATION_ID : std_logic_vector(31 downto 0) := (others => '0');
      HART_ID : std_logic_vector(31 downto 0) := (others => '0')
    );
    Port ( clk, reset : in STD_LOGIC;
           csr_address_read : in STD_LOGIC_VECTOR (11 downto 0);
           csr_address_write : in STD_LOGIC_VECTOR (11 downto 0);
           write_enable : in STD_LOGIC;
           write_value : in STD_LOGIC_VECTOR(31 downto 0);
           rd1 : in STD_LOGIC_VECTOR (31 downto 0);
           imm_ext : in STD_LOGIC_VECTOR (31 downto 0);
           funct3 : in STD_LOGIC_VECTOR (2 downto 0);
           illegal_instruction, instr_addr_misaligned : in STD_LOGIC;
           load_misaligned, store_misaligned : in STD_LOGIC;
           instr_except_pc : in std_logic_vector(31 downto 0);
           interrupt_external, interrupt_timer : in STD_LOGIC;
           interrupt_external_w, interrupt_timer_w : in STD_LOGIC;
           interrupt_external_m, interrupt_timer_m : out STD_LOGIC;
           out_write_reg : out STD_LOGIC_VECTOR(31 downto 0);
           out_write_csr : out STD_LOGIC_VECTOR (31 downto 0);
           out_mepc : out STD_LOGIC_VECTOR(31 downto 0);
           trap_jump_addr : out STD_LOGIC_VECTOR (31 downto 0);
           trap_caught : out std_logic := '0';
           mret_instr : in std_logic;
           pc_e : in std_logic_vector(31 downto 0));
end csr_exec;

architecture Behavioral of csr_exec is
    
    component edge_detector is
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               d : in STD_LOGIC;
               edge_detected : out STD_LOGIC);
    end component;

    signal read_csr : std_logic_vector(31 downto 0);
    
    signal csr_cycle : std_logic_vector(63 downto 0) := (others => '0');
    signal csr_misa : std_logic_vector(31 downto 0) := (others => '0');
    signal csr_mstatus : std_logic_vector(31 downto 0) := (others => '0');
    signal csr_mstatus_mie, csr_mstatus_mpie : std_logic;
    signal csr_mtvec : std_logic_vector(31 downto 0) := (others => '0');
    signal csr_mtvec_base : std_logic_vector(31 downto 2);
    signal csr_mtvec_mode : std_logic_vector(1 downto 0);
    signal csr_mie : std_logic_vector(31 downto 0);
    signal csr_meie, csr_mtie, csr_msie : std_logic;
    signal csr_mip : std_logic_vector(31 downto 0);
    signal csr_meip, csr_mtip, csr_msip : std_logic;
    signal csr_mepc : std_logic_vector(31 downto 0);
    signal csr_mepc_r : std_logic_vector(31 downto 1);
    signal csr_mcause : std_logic_vector(31 downto 0);
    signal csr_interrupt : std_logic;
    signal csr_exception_code : std_logic_vector(3 downto 0);
    signal csr_mscratch : std_logic_vector(31 downto 0);
    
    -- Defines for CSR Address
    constant CSR_CYCLE_ADDR : std_logic_vector(11 downto 0) := X"C00";
    constant CSR_CYCLEH_ADDR : std_logic_vector(11 downto 0) := X"C80";
    constant CSR_MVENDOR_ID_ADDR : std_logic_vector(11 downto 0) := X"F11";
    constant CSR_MARCHITECTURE_ID_ADDR : std_logic_vector(11 downto 0) := X"F12";
    constant CSR_MIMPLEMENTATION_ID_ADDR : std_logic_vector(11 downto 0) := X"F13";
    constant CSR_MHART_ID_ADDR : std_logic_vector(11 downto 0) := X"F14";
    constant CSR_MISA_ADDR : std_logic_vector(11 downto 0) := X"301";
    constant CSR_MSTATUS_ADDR : std_logic_vector(11 downto 0) := X"300";
    constant CSR_MTVEC_ADDR : std_logic_vector(11 downto 0) := X"305";
    constant CSR_MIE_ADDR : std_logic_vector(11 downto 0) := X"304";
    constant CSR_MIP_ADDR : std_logic_vector(11 downto 0) := X"344";
    constant CSR_MEPC_ADDR : std_logic_vector(11 downto 0) := X"341";
    constant CSR_MCAUSE_ADDR : std_logic_vector(11 downto 0) := X"342";
    constant CSR_MSCRATCH_ADDR : std_logic_vector(11 downto 0) := X"340";
    
    -- Exceptions
    signal is_exception : std_logic;
    signal mtrap_cause : std_logic_vector(3 downto 0);
    signal intr_ext_async, intr_timer_async : std_logic;
    signal intr_sources_async, out_of_edge_detector : std_logic_vector(1 downto 0);
    signal valid_pc : std_logic;
    
begin
    
            -- Interupt logic
    GEN_EDGE_DETECT : for i in 0 to 1 generate
 
        interrupt_edge: edge_detector port map(
            clk => clk,
            reset => reset,
            d => intr_sources_async(i),
            edge_detected => out_of_edge_detector(i)
            );
 
    end generate;
    
    (interrupt_external_m, interrupt_timer_m) <= out_of_edge_detector;
        
    process(all)
    begin
    
        is_exception <= instr_addr_misaligned or illegal_instruction or 
                        load_misaligned or store_misaligned;
        
        if pc_e /= 32X"0" then
            valid_pc <= '1';
        else
            valid_pc <= '0';
        end if;
                                             
        intr_ext_async   <= csr_mstatus_mie and csr_meie and interrupt_external and 
                            valid_pc; 
        intr_timer_async <= csr_mstatus_mie and csr_mtie and interrupt_timer and 
                            valid_pc;
        intr_sources_async <= intr_ext_async & intr_timer_async;
        
        trap_caught <= is_exception or interrupt_external_w or interrupt_timer_w;
        
        if is_exception = '1' then
            if instr_addr_misaligned = '1' then 
                mtrap_cause <= 4D"00";
            elsif illegal_instruction = '1' then
                mtrap_cause <= 4D"02";
            elsif load_misaligned = '1' then
                mtrap_cause <= 4D"04";
            elsif store_misaligned = '1' then
                mtrap_cause <= 4D"06";
            end if;
        else
            if interrupt_external_w = '1' then
                mtrap_cause <= 4D"11";
            elsif interrupt_timer_w = '1' then
                mtrap_cause <= 4D"07";
            end if;
        end if;
        
        trap_jump_addr <= ( 31 downto 2 => csr_mtvec_base, 1 downto 0 => "00" );
            
    end process;
    
    -- MSCRATCH
    process(clk)
    begin
        if rising_edge(clk) then   
            if reset then
                csr_mscratch <= (others => '0');
            elsif (csr_address_write = CSR_MSCRATCH_ADDR) and (write_enable = '1') then
                csr_mscratch <= write_value;            
            end if;
        end if;
    end process;
    
    -- MCYCLE and MCYCLEH
    process(clk)
    begin
        if rising_edge(clk) then   
            if reset then
                csr_cycle <= (others => '0');
            else
                csr_cycle <= csr_cycle + 1;            
            end if;
        end if;
    end process;
    
    -- MISA
    -- bit 8 -> RV32I base ISA
    csr_misa(8) <= '1';
    -- bit 30 and 31 sets MXL to 1, for XLEN -> 32
    csr_misa(31 downto 30) <= "01";
    
    -- MSTATUS and MSTATUSH
    process(clk)
    begin
        if rising_edge(clk) then   
            if reset then
                csr_mstatus_mie <= '0';
            elsif trap_caught then
                -- Save interrupt state
                -- and disable interrupts
                csr_mstatus_mpie <= csr_mstatus_mie;
                csr_mstatus_mie  <= '0';
            elsif mret_instr then
                csr_mstatus_mie  <= csr_mstatus_mpie;
                csr_mstatus_mpie <= '1';
            elsif (csr_address_write = CSR_MSTATUS_ADDR) and (write_enable = '1') then
                csr_mstatus_mie <= write_value(3);
            end if;
        end if;
    end process;
    
    -- MTVEC -> base address and mode (direct/vectored)
    csr_mtvec <= csr_mtvec_base & csr_mtvec_mode;
    process(clk)
    begin
        if rising_edge(clk) then   
            if reset then
                csr_mtvec_base <= (others => '0');
                csr_mtvec_mode <= (others => '0');
            elsif (csr_address_write = CSR_MTVEC_ADDR) and (write_enable = '1') then
                csr_mtvec_base <= write_value(31 downto 2);
                csr_mtvec_mode <= write_value(1 downto 0);
            end if;
        end if;
    end process;
    
    -- MIE 
    --  Machine External Interrupt Enable
    --  Machine Timer Interrupt Enable
    --  Machine Software Interrupt Enable
    csr_mie <= (31 downto 12 => '0', 11 => csr_meie, 10 downto 8 => '0', 7 => csr_mtie, 
                6 downto 4 => '0', 3 => csr_msie, 2 downto 0 => '0');
    process(clk)
    begin
        if rising_edge(clk) then   
            if reset then
                csr_meie <= '0';
                csr_mtie <= '0';
                csr_msie <= '0';
            elsif (csr_address_write = CSR_MIE_ADDR) and (write_enable = '1') then
                csr_meie <= write_value(11);
                csr_mtie <= write_value(7);
                csr_msie <= write_value(3);
            end if;
        end if;
    end process;
    
    -- MIP 
    --  Machine External Interrupt Pending
    --  Machine Timer Interrupt Pendind
    --  Machine Software Interrupt Pending
    csr_mip <= (31 downto 12 => '0', 11 => csr_meip, 10 downto 8 => '0', 7 => csr_mtip, 
                6 downto 4 => '0', 3 => csr_msip, 2 downto 0 => '0');
    process(clk)
    begin
        if rising_edge(clk) then   
            if reset then
                csr_meip <= '0';
                csr_mtip <= '0';
                csr_msip <= '0';
            else
                if interrupt_external_w = '1' then 
                    csr_meip <= '1';
                end if;
                
                if interrupt_timer_w = '1' then 
                    csr_mtip <= '1';
                end if;                
                 
                if (csr_address_write = CSR_MIP_ADDR) and (write_enable = '1') then
                    csr_meip <= write_value(11);
                    csr_mtip <= write_value(7);
                    csr_msip <= write_value(3);
                end if;
                
            end if;
        end if;
    end process;
    
    -- MEPC
    -- Handle when a Trap is taken
    csr_mepc <= (31 downto 1 => csr_mepc_r, 0 => '0');
    process(clk)
    begin
        if rising_edge(clk) then   
            if reset then
                csr_mepc_r <= (others => '0');
            elsif trap_caught = '1' then
                csr_mepc_r <= instr_except_pc(31 downto 1);
            elsif (csr_address_write = CSR_MEPC_ADDR) and (write_enable = '1') then
                csr_mepc_r <= write_value(31 downto 1);
            end if;
        end if;
    end process;
    
    out_mepc <= csr_mepc;
    
    -- MCAUSE
    -- Handle trap cause
    csr_mcause <= (31 => csr_interrupt, 30 downto 4 => '0', 3 downto 0 => csr_exception_code);
    process(clk)
    begin
        if rising_edge(clk) then   
            if reset then
                csr_interrupt <= '0';
                csr_exception_code <= (others => '0');
            elsif trap_caught = '1' then
                csr_interrupt <= '0' when is_exception else '1';
                csr_exception_code <= mtrap_cause;
            end if;
        end if;
    end process;
    
    -- CSR READ/WRITE
    process(all)
    begin

        case funct3 is
           when "001" => 
                -- csrrw
                out_write_csr <= rd1;
           when "101" =>
                -- csrrwi
                out_write_csr <= imm_ext;
           when "010" => 
                -- csrrs
                out_write_csr <= read_csr or rd1;
           when "110" =>
                -- csrrsi
                out_write_csr <= read_csr or imm_ext;
           when "011" => 
                -- csrrc
                out_write_csr <= read_csr and (not rd1);
           when "111" =>
                -- csrrci
                out_write_csr <= read_csr and (not imm_ext);
           when others => 
                out_write_csr <= (others => '0');
        end case;

    end process;
    
    process(all)
    begin
        
        case csr_address_read is
            
            when CSR_CYCLE_ADDR =>
                read_csr <= csr_cycle(31 downto 0);
            when CSR_CYCLEH_ADDR =>
                read_csr <= csr_cycle(63 downto 32);
            when CSR_MVENDOR_ID_ADDR =>
                read_csr <= VENDOR_ID;
            when CSR_MARCHITECTURE_ID_ADDR =>
                read_csr <= ARCHITECTURE_ID;
            when CSR_MIMPLEMENTATION_ID_ADDR =>
                read_csr <= IMPLEMENTATION_ID;
            when CSR_MHART_ID_ADDR =>
                read_csr <= HART_ID;
            when CSR_MISA_ADDR =>
                read_csr <= csr_misa;
            when CSR_MSTATUS_ADDR =>
                read_csr <= csr_mstatus;
            when CSR_MTVEC_ADDR =>
                read_csr <= csr_mtvec;
            when CSR_MIE_ADDR =>
                read_csr <= csr_mie;
            when CSR_MIP_ADDR =>
                read_csr <= csr_mip;
            when CSR_MEPC_ADDR =>
                read_csr <= csr_mepc;
            when CSR_MCAUSE_ADDR =>
                read_csr <= csr_mcause;
            when CSR_MSCRATCH_ADDR =>
                read_csr <= csr_mscratch;
            when others =>
                read_csr <= (others => '0');
        end case;
    
    end process;
    
    out_write_reg <= read_csr;

end Behavioral;