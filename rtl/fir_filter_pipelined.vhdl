-- Use Standard Library
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;
use work.fir_generics_package.all;

-- Entity
entity fir_filter_pipelined is
    generic (
        ORDER             : integer := ORDER;
        BIT_WIDTH         : integer := BIT_WIDTH
    );
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        enable : in  std_logic;
        x      : in  signed(BIT_WIDTH-1 downto 0);
        y      : out signed(BIT_WIDTH-1 downto 0)
    );
end entity fir_filter_pipelined;

--Architecture
architecture firpipelined of fir_filter_pipelined is
    signal registers_forwardpath  : reg_array(0 to COEFFICIENT_NUMBER);
    signal forward_pipe           : reg_array(0 to COEFFICIENT_NUMBER);
    signal backward_pipe          : reg_array(0 to COEFFICIENT_NUMBER);
    signal mul_pipe               : reg_array(0 to COEFFICIENT_NUMBER);
    signal add_pipe               : reg_array(0 to COEFFICIENT_NUMBER);
    signal acc_pipe               : reg_array(0 to COEFFICIENT_NUMBER);
    signal add_res                : reg_array(0 to COEFFICIENT_NUMBER);
    signal mul_res                : reg_array(0 to COEFFICIENT_NUMBER);
    signal acc_res                : reg_array(0 to COEFFICIENT_NUMBER-1);
    begin
        registers_forwardpath(0) <= x;

        even_tap_seq_process : if ((ORDER mod 2) = 1) generate
            process(clk)
            begin
                if (rising_edge(clk)) then
                    if (reset = '1') then
                        registers_forwardpath(1 to COEFFICIENT_NUMBER)  <= (others => (others => '0'));
                        forward_pipe(0 to COEFFICIENT_NUMBER)           <= (others => (others => '0'));
                        backward_pipe(0 to COEFFICIENT_NUMBER)          <= (others => (others => '0'));
                    elsif (enable = '1') then
                        -- delay elements and delay pipeline
                        forward_pipe(0)                                 <= registers_forwardpath(0);
                        registers_forwardpath(1 to COEFFICIENT_NUMBER)  <= forward_pipe(0 to COEFFICIENT_NUMBER-1);
                        forward_pipe(1 to COEFFICIENT_NUMBER)           <= registers_forwardpath(1 to COEFFICIENT_NUMBER);
                        for i in 0 to COEFFICIENT_NUMBER loop
                            backward_pipe(i) <= forward_pipe(COEFFICIENT_NUMBER);
                        end loop;
                    end if;
                end if;
            end process;
        end generate;
        
        even_tap_pipe_process : if ((ORDER mod 2) = 1) generate
            process(clk)
            begin
                if (rising_edge(clk)) then
                    if (reset = '1') then
                        add_pipe(0 to COEFFICIENT_NUMBER) <= (others => (others => '0'));
                        mul_pipe(0 to COEFFICIENT_NUMBER) <= (others => (others => '0'));
                        acc_pipe(0 to COEFFICIENT_NUMBER) <= (others => (others => '0'));
                    elsif (enable = '1') then
                        --multiplication and addition pipeline
                        add_pipe(0 to COEFFICIENT_NUMBER) <= add_res(0 to COEFFICIENT_NUMBER);
                        mul_pipe(0 to COEFFICIENT_NUMBER) <= mul_res(0 to COEFFICIENT_NUMBER);
                        acc_pipe(0)                       <= mul_pipe(0);
                        acc_pipe(1 to COEFFICIENT_NUMBER) <= acc_res(0 to COEFFICIENT_NUMBER-1);  
                    end if ;
                end if ;
            end process;
        end generate;

        odd_tap_seq_process : if ((ORDER mod 2) = 0) generate
            process(clk)
            begin
                if (rising_edge(clk)) then
                    if (reset = '1') then
                        registers_forwardpath(1 to COEFFICIENT_NUMBER)  <= (others => (others => '0'));
                        forward_pipe(0 to COEFFICIENT_NUMBER)           <= (others => (others => '0'));
                        backward_pipe(0 to COEFFICIENT_NUMBER)          <= (others => (others => '0'));
                    elsif (enable = '1') then
                        -- delay elements and delay pipeline
                        forward_pipe(0)                                 <= registers_forwardpath(0);
                        registers_forwardpath(1 to COEFFICIENT_NUMBER)  <= forward_pipe(0 to COEFFICIENT_NUMBER-1);
                        forward_pipe(1 to COEFFICIENT_NUMBER)           <= registers_forwardpath(1 to COEFFICIENT_NUMBER);
                        backward_pipe(0) <= forward_pipe(COEFFICIENT_NUMBER);
                        for i in 1 to COEFFICIENT_NUMBER loop
                            backward_pipe(i) <= registers_forwardpath(COEFFICIENT_NUMBER);
                        end loop;                
                    end if ;
                end if ;
            end process;
        end generate;
        
        odd_tap_pipe_process : if ((ORDER mod 2) = 0) generate
            add_pipe(COEFFICIENT_NUMBER) <= add_res(COEFFICIENT_NUMBER);
            process(clk)
            begin
                if (rising_edge(clk)) then
                    if (reset = '1') then
                        add_pipe(0 to COEFFICIENT_NUMBER-1) <= (others => (others => '0'));
                        mul_pipe(0 to COEFFICIENT_NUMBER)   <= (others => (others => '0'));
                        acc_pipe(0 to COEFFICIENT_NUMBER)   <= (others => (others => '0'));
                    elsif (enable = '1') then
                        --multiplication and addition pipeline
                        add_pipe(0 to COEFFICIENT_NUMBER-1) <= add_res(0 to COEFFICIENT_NUMBER-1);
                        mul_pipe(0 to COEFFICIENT_NUMBER)   <= mul_res(0 to COEFFICIENT_NUMBER);
                        acc_pipe(0)                         <= mul_pipe(0);
                        acc_pipe(1 to COEFFICIENT_NUMBER)   <= acc_res(0 to COEFFICIENT_NUMBER-1);
                    end if;
                end if;
            end process;
        end generate;

        even_tap_comb_process : if ((ORDER mod 2) = 1) generate
            process(forward_pipe, backward_pipe, add_pipe, mul_pipe, acc_pipe)
            begin
                for i in 0 to COEFFICIENT_NUMBER loop
                    add_res(i) <= to_signed(to_integer(forward_pipe(i) + backward_pipe(COEFFICIENT_NUMBER-i)), add_res(i)'length);
                    mul_res(i) <= to_signed(to_integer(add_pipe(i)*INT_COEFFICIENTS(i)), mul_res(i)'length);
                end loop;
                for p in 0 to COEFFICIENT_NUMBER-1 loop
                    acc_res(p) <= to_signed(to_integer(acc_pipe(p) + mul_pipe(p+1)), acc_res(p)'length);
                end loop ;          
            end process;
        end generate;

        odd_tap_comb_process : if ((ORDER mod 2) = 0) generate
        process(forward_pipe, backward_pipe, add_pipe, mul_pipe, acc_pipe)
        begin
            add_res(COEFFICIENT_NUMBER) <= backward_pipe(0);
            for i in 0 to COEFFICIENT_NUMBER-1 loop
                add_res(i) <= to_signed(to_integer(forward_pipe(i) + backward_pipe(COEFFICIENT_NUMBER-i)), add_res(i)'length);
                acc_res(i) <= to_signed(to_integer(acc_pipe(i) + mul_pipe(i+1)),acc_res(i)'length);
            end loop;
            for p in 0 to COEFFICIENT_NUMBER loop
                mul_res(p) <= to_signed(to_integer(add_pipe(p)*INT_COEFFICIENTS(p)), mul_res(p)'length);
            end loop;
        end process;
        end generate;

        y <= acc_pipe(COEFFICIENT_NUMBER);

    end firpipelined;