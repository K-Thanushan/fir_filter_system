-- Self Checking testbench for FIR Filter using fixed point 
-- TextIO library is used for reading files

-- Libraries
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use IEEE.fixed_pkg.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

use work.fir_fixed_generics_package.all;

entity fir_filter_fixed_test is
end entity fir_filter_fixed_test;

architecture fir_fixed_test of fir_filter_fixed_test is
    signal clk     : std_logic := '0';
    signal reset   : std_logic;
    signal enable  : std_logic;
    signal x_valid : std_logic;
    signal x       : signed(BIT_WIDTH-1 downto 0);
    signal y_valid : std_logic;
    signal y       : signed(BIT_WIDTH-1 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    constant input_number : integer := 1860;
    signal read_done    : std_logic := '0';
    signal write_done   : std_logic := '0';
    signal assert_done  : std_logic := '0'; 
    begin

        DUT : entity work.fir_filter_fixed
            generic map(
                ORDER => ORDER,
                BIT_WIDTH => BIT_WIDTH,
                FRACTIONAL_WIDTH => FRACTIONAL_WIDTH,
                COEFFICIENT_WIDTH => COEFFICIENT_WIDTH,
                COEFFICIENT_NUMBER => COEFFICIENT_NUMBER
            )
            port map(
                clk => clk,
                reset => reset,
                enable => enable,
                x_valid => x_valid,
                x => x,
                y_valid => y_valid,
                y => y
            );
        
        clk <= not clk after CLK_PERIOD/2;

        INPUT_READ_PROCESS : process
            file input_file      : text;
            variable input_data  : integer;
            variable file_line   : line;
            variable file_status : file_open_status;
            
            begin
                file_open(file_status, input_file, "C:/Work/fir_filter_system/matlab/I_upsampled_input_fixed.txt", read_mode);
                Input_file_Availability_Assertion : assert file_status = open_ok report "Input File not Found!!" severity failure;

                wait until rising_edge(clk);
                reset <= '1';
                wait for CLK_PERIOD*2;
                reset <= '0';
                enable <= '1';

                while not endfile(input_file) loop
                    -- input_number := input_number + 1;
                    readline(input_file, file_line);
                    read(file_line, input_data);
                    x <= to_signed(input_data, x'length); --resize(signed(to_sfixed(input_Data, BIT_WIDTH-FRACTIONAL_WIDTH-1, -FRACTIONAL_WIDTH)), BIT_WIDTH); --
                    x_valid <= '1';
                    wait until rising_edge(clk);
                end loop;
                x_valid <= '0';
                report "End of read file reached!" severity note;
                file_close(input_file);
                read_done <= '1';
                -- wait until write_done = '1';
                wait;
        end process;

        OUTPUT_WRITE_PROCESS : process
            file output_file      : text;
            variable output_data  : signed(BIT_WIDTH-1 downto 0);
            variable integer_data : integer;
            variable file_line    : line;
            variable file_status  : file_open_status;

            begin
                file_open(file_status, output_file, "C:/Work/fir_filter_system/tb/filter_outputs.txt", write_mode);
                Output_file_Availability_Assertion: assert file_status = open_ok report "Output File not Found!!" severity failure;

                wait until rising_edge(clk);
                wait for CLK_PERIOD*2;

                if (ORDER mod 2 = 0) then
                    wait for CLK_PERIOD*(ORDER/2 + 5);
                    for i in 0 to input_number loop
                        output_data := signed(y); --to_real(sfixed(y))/2.0**FRACTIONAL_WIDTH;
                        integer_data := to_integer(output_data);
                        write(file_line, integer_data);
                        writeline(output_file, file_line);
                        wait until rising_edge(clk);
                    end loop;
                else
                    wait for CLK_PERIOD*((ORDER-1)/2);
                    for i in 0 to input_number + 1 loop
                        output_data := signed(y); --to_real(sfixed(y))/2.0**FRACTIONAL_WIDTH;
                        write(file_line, output_data);
                        writeline(output_file, file_line);
                        wait until rising_edge(clk);
                    end loop;                   
                end if;

                report "End of write file reached!" severity note;
                file_close(output_File);
                write_done <= '1';
                wait;
        end process;

        -- CHECK_PROCESS : process
        --     file reference_file_assertion   : text;
        --     file output_file_assertion : text;

        --     variable reference_data         : real;
        --     variable reference_fileline     : line;
        --     variable output_data            : real;
        --     variable output_fileline        : line;
        --     variable reference_file_status  : file_open_status;
        --     variable output_file_status : file_open_status;
            
        --     variable line_number : integer := 0;
        --     begin
        --         wait until write_done = '1';
                
        --         while (assert_done = '0') loop
        --             file_open(reference_file_status, reference_file_assertion, "C:\Work\fir_filter_system\tb\reference_outputs.txt", read_mode);
        --             refer_file_availabIlity_assertion : assert reference_file_status = open_ok report "Reference output file not Found!" severity failure;
        --             file_open(output_file_status, output_file_assertion, "C:/Work/fir_filter_system/tb/filter_outputs.txt", read_mode);
        --             out_file_availabIlity_assertion : assert output_file_status = open_ok report "Output file not Found!" severity failure;

        --             while not endfile(output_file_assertion) loop
        --                 line_number := line_number + 1;
        --                 readline(reference_file_assertion, reference_fileline);
        --                 read(reference_fileline, reference_data);
        --                 readline(output_file_assertion, output_fileline);
        --                 read(output_fileline, output_data);
        --                 Data_assertion : assert reference_data = output_data report "Data Mismatched!!! Expected Data :" & real'image(reference_data) & " but Output Data: " & real'image(output_data) severity error;
        --                 if reference_data = output_data  then
        --                     report "Data Valid!!!!!!! Input Data ID: " & integer'image(line_number) severity note;
        --                 end if;
        --             end loop;
        --         end loop;


        -- end process;
        
end fir_fixed_test; 
