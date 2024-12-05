--Use Standard Library
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;

--Entity
entity fir_filter_basic is
    generic (
        order   : integer := 5;
        w_x     : integer := 16;
        w_h     : integer := 16
    );
    port(
        clk :   in  std_logic;
        reset:  in  std_logic;
        enable: in  std_logic;
        x:      in  signed(w_x-1 downto 0);
        coeff:  in  signed((order+1)*w_h-1 downto 0);
        y:      out signed(w_x-1 downto 0)
    );
end entity fir_filter_basic;

--Architecture
architecture firbasic of fir_filter_basic is
    type h_array is array (0 to order) of signed(w_x-1 downto 0);
    signal registers: h_array;
    type co_array is array (0 to order) of signed(w_h-1 downto 0);
    signal coefficients: co_array;
    begin
        store_coefficients: process(coeff)
        begin
            for p in 0 to order loop
                coefficients(p) <= coeff(w_h*(p+1)-1 downto w_h*p);
            end loop;
        end process store_coefficients;

        registers(0) <= x;
        
        sequential_process: process(clk)
        begin
            if (rising_edge(clk)) then
                if (reset = '1') then
                    registers(1 to order) <= (others => (others => '0'));
                elsif (enable = '1') then
                    registers(1 to order) <= registers(0 to order-1); 
                end if;
            end if;
        end process sequential_process;
        
        combinational_process: process(registers,coefficients)
        variable yout : signed (w_x-1 downto 0);
        begin
            yout := to_signed(0, w_x);
            for i in 0 to order loop
                yout := yout + to_signed(to_integer(registers(i)*coefficients(i)),yout'length);
            end loop;
            y <= yout;
        end process combinational_process;
        
end firbasic;