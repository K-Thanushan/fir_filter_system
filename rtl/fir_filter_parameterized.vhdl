-- Use Standard Library
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Entity
entity fir_filter_parameterized is
    generic (
        n:   integer := 2;
        w_x: integer := 8;
        w_h: integer := 8
    );
    port (
        clk:   in  std_logic;
        reset: in  std_logic;
        x:     in  signed(w_x-1 downto 0);
        Hz:    in  signed((n+1)*w_h-1 downto 0); -- All coefficients combined (must change later)
        y:     out signed(w_x + w_h + n-1 downto 0)
    );
end entity fir_filter_parameterized;

-- Architecture
architecture firgeneralbehavioural of fir_filter_parameterized is
    type signed_array is array (0 to n) of signed(w_x + w_h - 1 downto 0);
    signal mul_zeros: signed_array;
    type add_array is array (0 to n) of signed(w_x + w_h + n-1 downto 0);
    signal add_zeros: add_array;
    type h_array is array (0 to n-1) of signed(w_x + w_h + n-1 downto 0);
    signal registers: h_array;
    begin
        combinational_process: process(x, Hz)
        begin
            for i in 0 to n loop
                mul_zeros(i) <= x*Hz(((((n+1)*w_h)-1) - w_h*i) downto ((((n+1)*w_h)-w_h) - w_h*i));
            end loop;
        end process combinational_process;
        
        add_zeros(0) <= resize(mul_zeros(0), w_x + w_h + n);
        add_zeros_process : for p in 1 to n generate
            add_zeros(p) <= resize(mul_zeros(p), w_x + w_h + n) + registers(p - 1);
        end generate;

        sequential_process: process(clk)
        begin
            if  (rising_edge(clk)) then
                if (reset = '1') then
                    registers <= (others => (others => '0')); -- Initializing the registers
                else
                    for r in 0 to n-1 loop
                        registers(r) <= add_zeros(r);
                    end loop;
                end if;
            end if ;
        end process sequential_process;
        y <= add_zeros(n);
end firgeneralbehavioural;