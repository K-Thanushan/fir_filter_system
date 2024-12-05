--Package for coverting a fixed point number to a signed number manually
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.fixed_pkg.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.fir_fixed_generics_package.all;

package fixed_to_signed_package is
    
    function convert_fixed_to_signed(
        y_fixed : sfixed(BIT_WIDTH - FRACTIONAL_WIDTH - 1 downto -FRACTIONAL_WIDTH)
    ) return signed;

end package fixed_to_signed_package;

package body fixed_to_signed_package is
    function convert_fixed_to_signed(
        y_fixed : sfixed(BIT_WIDTH - FRACTIONAL_WIDTH - 1 downto -FRACTIONAL_WIDTH)
    ) return signed is
        variable y : signed(BIT_WIDTH - 1 downto 0);
    begin
        for i in 0 to BIT_WIDTH - 1 loop
            y(i) := y_fixed(-BIT_WIDTH + 1 + i);
        end loop;
        return y;
        end function convert_fixed_to_signed;
end package body;