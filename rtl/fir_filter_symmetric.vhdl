-- Use Standard Library
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;
use IEEE.math_real.all;
use work.fir_generics_package.all;

-- Entity
entity fir_filter_symmetric is
    generic (
        ORDER : integer := ORDER;
        BIT_WIDTH : integer := BIT_WIDTH
    );
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        enable : in  std_logic;
        x      : in  signed(BIT_WIDTH-1 downto 0);
        y      : out signed(BIT_WIDTH-1 downto 0)
    );
end entity fir_filter_symmetric;

--Architecture
architecture firsymmetric of fir_filter_symmetric is
    constant coefficient_n : integer := integer(floor(real(ORDER/2)));
    type reg_array is array(natural range <>) of signed(BIT_WIDTH-1 downto 0);
    signal registers_forwardpath  : reg_array(0 to coefficient_n);
    signal registers_backwardpath : reg_array(0 to coefficient_n); 
    begin
        registers_forwardpath(0) <= x;

        even_tap_seq_process : if ((ORDER mod 2) = 1) generate
            process(clk)
            begin
                if (rising_edge(clk)) then
                    if (reset = '1') then
                        registers_forwardpath(1 to coefficient_n)  <= (others => (others => '0'));
                        registers_backwardpath(0 to coefficient_n) <= (others => (others => '0'));
                    elsif (enable = '1') then
                        registers_forwardpath(1 to coefficient_n)  <= registers_forwardpath(0 to coefficient_n - 1);
                        registers_backwardpath(0)                  <= registers_forwardpath(coefficient_n);
                        registers_backwardpath(1 to coefficient_n) <= registers_backwardpath(0 to coefficient_n -1);
                    end if;
                end if ;
            end process;
        end generate;

        odd_tap_seq_process : if ((ORDER mod 2) = 0) generate
            registers_backwardpath(0) <= registers_forwardpath(coefficient_n);
            process(clk)
            begin
                if (rising_edge(clk)) then
                    if (reset = '1') then
                        registers_forwardpath(1 to coefficient_n)  <= (others => (others => '0'));
                        registers_backwardpath(1 to coefficient_n) <= (others => (others => '0'));
                    elsif (enable = '1') then
                        registers_forwardpath(1 to coefficient_n)  <= registers_forwardpath(0 to coefficient_n-1);
                        registers_backwardpath(1 to coefficient_n) <= registers_backwardpath(0 to coefficient_n-1);
                    end if;
                end if ;
            end process;
        end generate;
        
        even_tap_comb_process : if ((ORDER mod 2) = 1) generate 
            process(registers_forwardpath, registers_backwardpath)
            variable yout : signed(BIT_WIDTH-1 downto 0);
            begin
                yout := to_signed(0, yout'length);
                for i in 0 to coefficient_n loop
                    yout := yout + to_signed(to_integer(INT_COEFFICIENTS(i)*(registers_forwardpath(i) + registers_backwardpath(coefficient_n-i))),yout'length);
                end loop;
                y <= yout;
            end process;
        end generate;

        odd_tap_comb_process : if ((ORDER mod 2) = 0) generate
            process(registers_forwardpath, registers_backwardpath)
            variable yout : signed(BIT_WIDTH-1 downto 0);
            begin
                yout := to_signed(0, yout'length);
                for i in 0 to coefficient_n - 1 loop
                    yout := yout + to_signed(to_integer(INT_COEFFICIENTS(i)*(registers_forwardpath(i) + registers_backwardpath(coefficient_n-i))),yout'length);
                end loop;
                yout := yout + to_signed(to_integer(INT_COEFFICIENTS(coefficient_n)*registers_forwardpath(coefficient_n)),yout'length);
                y <= yout; 
            end process;
        end generate;
end firsymmetric;
