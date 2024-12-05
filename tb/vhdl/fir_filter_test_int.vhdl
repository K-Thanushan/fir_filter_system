library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use std.env.all;
use IEEE.math_real.all;

library work;
-- use work.fir_generics_package.all;
use work.coefficients_package.all;

--Entity
entity fir_filter_test_int is
end entity fir_filter_test_int;

--Architecture
architecture int_test of fir_filter_test_int is
    signal clk    : std_logic := '0';
    signal reset  : std_logic;
    signal enable : std_logic;
    signal x      : signed(BIT_WIDTH-1 downto 0);
    signal y      : signed(BIT_WIDTH-1 downto 0);
    begin
        clk    <= not clk after CLK_PERIOD/2;

        DUT : entity work.fir_filter_pipelined
            generic map(
                ORDER => ORDER,
                BIT_WIDTH => BIT_WIDTH
            )
            port map(
                clk => clk,
                reset => reset,
                enable => enable,
                x => x,
                y => y
            );

        PROCESS_SEQUENCE : process
        begin
            wait until rising_edge(clk);
            reset  <= '1';
            wait for CLK_PERIOD*2;
            reset <= '0';
            enable <= '1';
            -- wait until enable = '1';
            for i in 1 to 2**BIT_WIDTH loop
                x <= to_signed(i, x'length);
                wait until rising_edge(clk);
            end loop;

            x <= (others => '0');
            wait until rising_edge(clk);
            report "Test : OK";
            finish;
        end process;
end int_test; 