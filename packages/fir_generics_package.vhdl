-- package for defining generic parameters and signal types
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

package fir_generics_package is
    constant ORDER              : integer := 8;
    constant BIT_WIDTH          : integer := 16;
    constant COEFFICIENT_WIDTH  : integer := 16;
    constant COEFFICIENT_LENGTH : integer := (integer(floor(real(ORDER/2))) + 1)*COEFFICIENT_WIDTH;
    constant COEFFICIENT_NUMBER : integer := integer(floor(real(ORDER/2)));
    type reg_array is array(natural range <>) of signed(BIT_WIDTH-1 downto 0);
    type coefficient_array is array(0 to COEFFICIENT_NUMBER) of signed(COEFFICIENT_WIDTH-1 downto 0);
    constant INT_COEFFICIENTS  : coefficient_array := (
        to_signed(2, COEFFICIENT_WIDTH), 
        to_signed(-1, COEFFICIENT_WIDTH), 
        to_signed(3, COEFFICIENT_WIDTH), 
        to_signed(-4, COEFFICIENT_WIDTH), 
        to_signed(5, COEFFICIENT_WIDTH));
end package fir_generics_package;