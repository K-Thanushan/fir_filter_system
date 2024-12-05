-- Use Standard Library
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.fixed_pkg.all;
use work.fir_fixed_generics_package.all;
use work.fixed_to_signed_package.all;

--Entity
entity fir_filter_fixed is
    generic(
        ORDER              : integer := ORDER;
        BIT_WIDTH          : integer := BIT_WIDTH;
        FRACTIONAL_WIDTH   : integer := FRACTIONAL_WIDTH;
        COEFFICIENT_WIDTH  : integer := COEFFICIENT_WIDTH;
        COEFFICIENT_NUMBER : integer := COEFFICIENT_NUMBER
    );
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        enable  : in  std_logic;
        x_valid : in  std_logic;
        x       : in  signed(BIT_WIDTH - 1 downto 0); -- sfixed(BIT_WIDTH - FRACTIONAL_WIDTH -1 downto -FRACTIONAL_WIDTH);
        y_valid : out std_logic;
        y       : out signed(BIT_WIDTH - 1 downto 0)
    );
end entity fir_filter_fixed;

--Architecture
 architecture firfixed of fir_filter_fixed is
    signal registers_forwardpath : reg_array(1 to COEFFICIENT_NUMBER);
    signal forward_pipe          : reg_array(0 to COEFFICIENT_NUMBER);
    signal backward_pipe         : reg_array(0 to COEFFICIENT_NUMBER);
    signal mul_pipe              : reg_array(0 to COEFFICIENT_NUMBER);
    signal add_pipe              : reg_array(0 to COEFFICIENT_NUMBER);
    signal acc_pipe              : reg_array(0 to COEFFICIENT_NUMBER);
    signal add_res               : reg_array(0 to COEFFICIENT_NUMBER);
    signal mul_res               : reg_array(0 to COEFFICIENT_NUMBER);
    signal acc_res               : reg_array(0 to COEFFICIENT_NUMBER-1);
    signal y_fixed               : sfixed(BIT_WIDTH - FRACTIONAL_WIDTH -1 downto -FRACTIONAL_WIDTH);
    signal valid_shift           : std_logic_vector(PIPE_DELAY - 1 downto 0);
    begin
        --registers_forwardpath(0) <= to_sfixed(x, BIT_WIDTH - FRACTIONAL_WIDTH - 1, -FRACTIONAL_WIDTH);-- when x_valid = '1' else ((others => '0'));

        even_tap_seq_process : if ((ORDER mod 2) = 1) generate
            process(clk)
            begin
                if (rising_edge(clk)) then
                    if (reset = '1') then
                        registers_forwardpath(1 to COEFFICIENT_NUMBER) <= (others => (others => '0'));
                        forward_pipe(0 to COEFFICIENT_NUMBER)          <= (others => (others => '0'));
                        backward_pipe(0 to COEFFICIENT_NUMBER)         <= (others => (others => '0'));
                    elsif (enable = '1' and (valid_shift(PIPE_DELAY-1) = '1' or x_valid = '1')) then
                        -- delay elements and delay pipeline
                        forward_pipe(0)                                 <= sfixed(x);
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
                    elsif (enable = '1' and (valid_shift(PIPE_DELAY-1) = '1' or x_valid = '1')) then
                        --multiplication and addition pipeline
                        add_pipe(0 to COEFFICIENT_NUMBER) <= add_res(0 to COEFFICIENT_NUMBER);
                        mul_pipe(0 to COEFFICIENT_NUMBER) <= mul_res(0 to COEFFICIENT_NUMBER);
                        acc_pipe(0)                       <= mul_pipe(0);
                        acc_pipe(1 to COEFFICIENT_NUMBER) <= acc_res(0 to COEFFICIENT_NUMBER-1);  
                    end if;
                end if;
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
                    elsif (enable = '1' and (valid_shift(PIPE_DELAY-1) = '1' or x_valid = '1')) then
                        -- delay elements and delay pipeline
                        forward_pipe(0)                                 <= sfixed(x);
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
                    elsif (enable = '1' and (valid_shift(PIPE_DELAY-1) = '1' or x_valid = '1')) then
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
                    add_res(i) <= resize((forward_pipe(i) + backward_pipe(COEFFICIENT_NUMBER-i)), BIT_WIDTH - FRACTIONAL_WIDTH - 1, -FRACTIONAL_WIDTH);-- add_res(i));
                    mul_res(i) <= resize((add_pipe(i)*FIXED_COEFFICIENTS(i)), BIT_WIDTH - FRACTIONAL_WIDTH - 1, -FRACTIONAL_WIDTH);-- mul_res(i));
                end loop;
                for p in 0 to COEFFICIENT_NUMBER-1 loop
                    acc_res(p) <= resize((acc_pipe(p) + mul_pipe(p+1)), BIT_WIDTH - FRACTIONAL_WIDTH - 1, -FRACTIONAL_WIDTH);-- acc_res(p));
                end loop ;          
            end process;
        end generate;

        odd_tap_comb_process : if ((ORDER mod 2) = 0) generate
        process(forward_pipe, backward_pipe, add_pipe, mul_pipe, acc_pipe)
        begin
            add_res(COEFFICIENT_NUMBER) <= backward_pipe(0);
            for i in 0 to COEFFICIENT_NUMBER-1 loop
                add_res(i) <= resize((forward_pipe(i) + backward_pipe(COEFFICIENT_NUMBER-i)), BIT_WIDTH - FRACTIONAL_WIDTH - 1, -FRACTIONAL_WIDTH);--add_res(i));
                acc_res(i) <= resize((acc_pipe(i) + mul_pipe(i+1)), BIT_WIDTH - FRACTIONAL_WIDTH - 1, -FRACTIONAL_WIDTH);--acc_res(i));
            end loop;
            for p in 0 to COEFFICIENT_NUMBER loop
                mul_res(p) <= resize((add_pipe(p)*FIXED_COEFFICIENTS(p)), BIT_WIDTH - FRACTIONAL_WIDTH - 1, -FRACTIONAL_WIDTH);--mul_res(p));
            end loop;
        end process;
        end generate;


        valid_shift_process : process(clk)
        begin
            if(rising_edge(clk)) then
                if (reset = '1') then
                    valid_shift <= (others => '0');
                elsif (enable = '1') then
                    valid_shift(0)                       <= x_valid;
                    valid_shift(PIPE_DELAY - 1 downto 1) <= valid_shift(PIPE_DELAY - 2 downto 0);
                else
                    valid_shift <= valid_shift;         
                end if;
            end if;
        end process;

        --         y <= signed(acc_pipe(COEFFICIENT_NUMBER));
        --Use following code block to trick QuestaSim.
        y_fixed <= acc_pipe(COEFFICIENT_NUMBER);
        process (y_fixed)
        begin
            -- for i in 0 to BIT_WIDTH - 1 loop
            --     y(i) <= y_fixed(-BIT_WIDTH + 1 + i);
            -- end loop;
            y <= convert_fixed_to_signed(y_fixed);
        end process;

        y_valid <= valid_shift(PIPE_DELAY - 1);
end firfixed;