library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.env.all;

library work;

-- Entity
entity fir_filter_parameterized_tb is
end entity fir_filter_parameterized_tb;


--Architecture
architecture test of fir_filter_parameterized_tb is
        constant n:   integer := 2;
        constant w_x: integer := 8;
        constant w_h: integer := 8;
        constant clk_period : time := 10 ns;
        signal   clk :  std_logic := '0';
        signal   reset: std_logic;
        signal   x  :   signed(w_x - 1 downto 0);
        signal   Hz :   signed((n+1)*w_h - 1 downto 0);
        signal   y  :   signed(w_x + w_h + n - 1 downto 0);
        signal temp : std_logic_vector((n+1)*w_h - 1 downto 0);
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
        begin
            temp <= x"010203";
            Hz <= to_signed(66051, (n+1)*w_h);
            wait until reset = '0';
            for i in 0 to 2**w_x loop
                x <= to_signed(i, w_x);
                wait until rising_edge(clk);
            end loop;

            x <= (others => '0');
            wait until rising_edge(clk);
            report "Test : OK";
            finish;
        end process;
        
end test;