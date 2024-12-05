library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.env.all;

-- Entity
entity fir_filter_tb is
end entity fir_filter_tb;

--Architecture
architecture test of fir_filter_tb is
        constant n:   integer := 2;
        constant w_x: integer := 8;
        constant w_h: integer := 8;
        constant clk_period : time := 10 ns;
        signal   clk :  std_logic := '0';
        signal   reset: std_logic;
        signal   x  :   signed(w_x - 1 downto 0);
        signal   Hz :   signed((n+1)*w_h - 1 downto 0);
        signal   y  :   signed(w_x + w_h + n - 1 downto 0);
    begin
        clk <= not clk  after clk_period/2;
        reset <= '1', '0' after 20 ns;


        DUT : entity work.fir_filter_parameterized
            generic map (
                n => n,
                w_x => w_x,
                w_h => w_h
            )
            port map (
                clk => clk,
                reset => reset,
                x => x,
                Hz => Hz,
                y => y
            );

        PROCESS_SEQUENCE : process
            variable expected_output : real := 0.0;
        begin
            Hz(0) <= to_signed(to_integer(unsigned(std_logic_vector(to_std_logic_vector(x"01")))), w_h);
            Hz(1) <= to_signed(to_integer(unsigned(std_logic_vector(to_std_logic_vector(x"02")))), w_h);
            Hz(2) <= to_signed(to_integer(unsigned(std_logic_vector(to_std_logic_vector(x"03")))), w_h);
            for i in 0 to 2**w_x loop
                x <= to_signed(i, w_x);
                wait for rising_edge(clk);
            end loop;

            x <= (others => '0');
            wait for rising_edge(clk);
            report "Test : OK";
            finish;
        end process;
        
end test;