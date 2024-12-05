-- Use Standard Library
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Entity
entity fir_filter_retimed is
    generic (
        n:   integer := 2;
        w_x: integer := 8;
        w_h: integer := 8
    );
    port (
        clk:   in  std_logic;
        reset: in  std_logic;
        x:     in  signed(w_x-1 downto 0);
        Hz:    in  signed (3*w_h-1 downto 0);
        y:     out signed (w_x + w_h + n -1 downto 0)
    );
end entity fir_filter_retimed;

-- Architecture
architecture firretimedBehavioural of fir_filter_retimed is
    type signed_array is array (0 to n) of signed(w_x + w_h - 1 downto 0);
    signal mul_zeros: signed_array;
    type add_array is array (0 to n) of signed(w_x + w_h + n -1 downto 0);
    signal add_zeros: add_array;
    type h_array is array (0 to n-1) of signed(w_x + w_h + n -1 downto 0);
    signal H_zeros: h_array;
    begin
    comb_process: process(x, Hz)
    begin
        mul_zeros(0) <= x * Hz(23 downto 16);
        mul_zeros(1) <= x * Hz(15 downto 8);
        mul_zeros(2) <= x * Hz(7 downto 0);
    end process comb_process;

    add_zeros(0) <= resize(mul_zeros(0), w_x + w_h + n);
    add_zeros(1) <= resize(mul_zeros(1), w_x + w_h + n) + H_zeros(0);
    add_zeros(2) <= resize(mul_zeros(2), w_x + w_h + n) + H_zeros(1);

    seq_process: process(clk, reset)
    begin
        if (reset = '1') then
            H_zeros(0) <= to_signed(0, w_x + w_h + n);
            H_zeros(1) <= to_signed(0, w_x + w_h + n);
        elsif (rising_edge(clk)) then
            H_zeros(0) <= add_zeros(0);
            H_zeros(1) <= add_zeros(1);
        end if;
    end process seq_process;
    y <= add_zeros(n);
end firretimedBehavioural;