-- package for storing coefficients
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use IEEE.fixed_pkg.all;
-- use work.fir_generics_package.all;

package coefficients_package is
    constant BIT_WIDTH          : integer := 16;
    constant COEFFICIENT_WIDTH  : integer := 16;
    constant ORDER              : integer := 8;
    constant FRACTIONAL_WIDTH   : integer := 15;
    constant CLK_PERIOD         : time    := 10 ns;
    constant COEFFICIENT_LENGTH : integer := (integer(floor(real(ORDER/2))) + 1)*COEFFICIENT_WIDTH;
    constant COEFFICIENT_NUMBER : integer := integer(floor(real(ORDER/2)));
    type co_array_int is array(0 to COEFFICIENT_NUMBER) of signed(COEFFICIENT_WIDTH-1 downto 0);
    constant INT_COEFFICIENTS  : co_array_int := (to_signed(2,COEFFICIENT_WIDTH), to_signed(-1, COEFFICIENT_WIDTH), to_signed(3, COEFFICIENT_WIDTH), to_signed(-4, COEFFICIENT_WIDTH), to_signed(5, COEFFICIENT_WIDTH));
    type coefficient_fixed_array is array(0 to COEFFICIENT_NUMBER) of sfixed(COEFFICIENT_WIDTH-FRACTIONAL_WIDTH-1 downto -FRACTIONAL_WIDTH);
    constant FIXED_COEFFICIENTS  : coefficient_fixed_array := (
        to_sfixed(0.15, COEFFICIENT_WIDTH-FRACTIONAL_WIDTH-1, -FRACTIONAL_WIDTH), 
        to_sfixed(-0.1, COEFFICIENT_WIDTH-FRACTIONAL_WIDTH-1, -FRACTIONAL_WIDTH), 
        to_sfixed(0.2, COEFFICIENT_WIDTH-FRACTIONAL_WIDTH-1, -FRACTIONAL_WIDTH), 
        to_sfixed(-0.15, COEFFICIENT_WIDTH-FRACTIONAL_WIDTH-1, -FRACTIONAL_WIDTH), 
        to_sfixed(0.5, COEFFICIENT_WIDTH-FRACTIONAL_WIDTH-1, -FRACTIONAL_WIDTH));
end package coefficients_package;