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

entity fir_filter_axis_test is
end entity fir_filter_axis_test;

architecture fir_axis_test of fir_filter_axis_test is
    signal clk   : std_logic := '0';
    signal reset : std_logic;

    signal s_axis_filter_tvalid : std_logic := '0';
    signal s_axis_filter_tready : std_logic;
    signal s_axis_filter_tlast  : std_logic := '0';
    signal s_axis_filter_tdata  : signed(AXIS_WIDTH - 1 downto 0);
    
    signal m_axis_filter_tvalid : std_logic;
    signal m_axis_filter_tready : std_logic := '0';
    signal m_axis_filter_tlast  : std_logic;
    signal m_axis_filter_tdata  : signed(AXIS_WIDTH - 1 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;

    constant input_number : integer := 5001;
    signal read_done    : std_logic := '0';
    signal write_done   : std_logic := '0';
    signal assert_done  : std_logic := '0'; 
    begin

        DUT : entity work.fir_filter_axis
            generic map(
                ORDER => ORDER,
                AXIS_WIDTH => AXIS_WIDTH,
                BIT_WIDTH => BIT_WIDTH,
                FRACTIONAL_WIDTH => FRACTIONAL_WIDTH,
                COEFFICIENT_WIDTH => COEFFICIENT_WIDTH,
                COEFFICIENT_NUMBER => COEFFICIENT_NUMBER,
                PIPE_DELAY => PIPE_DELAY
            )
            port map(
                clk => clk,
                reset => reset,
                s_axis_filter_tvalid => s_axis_filter_tvalid,
                s_axis_filter_tready => s_axis_filter_tready,
                s_axis_filter_tdata => s_axis_filter_tdata,
                s_axis_filter_tlast => s_axis_filter_tlast,
                m_axis_filter_tvalid => m_axis_filter_tvalid,
                m_axis_filter_tready => m_axis_filter_tready,
                m_axis_filter_tdata => m_axis_filter_tdata,
                m_axis_filter_tlast => m_axis_filter_tlast
            );
        
        clk <= not clk after CLK_PERIOD/2;

        INPUT_READ_PROCESS : process
            file input_file      : text;
            variable input_data  : integer;
            variable file_line   : line;
            variable file_status : file_open_status;
            
            begin
                file_open(file_status, input_file, "C:/Work/fir_filter_system/tb/signal_fixed.txt", read_mode);
                Input_file_Availability_Assertion : assert file_status = open_ok report "Input File not Found!!" severity failure;

                wait until rising_edge(clk);
                reset <= '1';
                wait for CLK_PERIOD*2;
                reset <= '0';

                m_axis_filter_tready <= '1';
                while not endfile(input_file) loop
                    -- input_number := input_number + 1;
                    readline(input_file, file_line);
                    read(file_line, input_data);
                    s_axis_filter_tdata <= resize(to_signed(input_data, BIT_WIDTH), AXIS_WIDTH);
                    s_axis_filter_tvalid <= '1';
                    s_axis_filter_tlast  <= '0';
                    wait until rising_edge(clk);
                end loop;
                s_axis_filter_tlast <= '1';
                wait until rising_edge(clk);
                -- m_axis_filter_tready <= '0';
                s_axis_filter_tvalid <= '0';
                s_axis_filter_tlast  <= '0';
                wait until (m_axis_filter_tlast = '1');
                wait until rising_edge(clk);
                m_axis_filter_tready <= '0';
                report "End of read file reached!" severity note;
                file_close(input_file);
                read_done <= '1';
                -- wait until write_done = '1';
                wait;
        end process;

        OUTPUT_WRITE_PROCESS : process
            file output_file     : text;
            variable output_data : signed(31 downto 0);
            variable decimal_vaue : real;
            variable file_line   : line;
            variable file_status : file_open_status;
            
            begin
                file_open(file_status, output_file, "C:/Work/fir_filter_system/tb/filter_outputs.txt", write_mode);
                Output_file_Availability_Assertion: assert file_status = open_ok report "Output File not Found!!" severity failure;

                wait until rising_edge(clk);
                wait for CLK_PERIOD*2;

                if (ORDER mod 2 = 0) then
                    wait for CLK_PERIOD*(ORDER/2 + 5);
                    for i in 0 to input_number loop
                        output_data := signed(m_axis_filter_tdata); --to_real(sfixed(m_axis_filter_tdata))/2.0**FRACTIONAL_WIDTH;
                        decimal_vaue := to_real(sfixed(m_axis_filter_tdata))/2.0**FRACTIONAL_WIDTH; --to_integer(output_data); --to_integer(output_data);
                        write(file_line, decimal_vaue);
                        writeline(output_file, file_line);
                        wait until rising_edge(clk);
                    end loop;
                else
                    wait for CLK_PERIOD*((ORDER-1)/2 + 4);
                    for i in 0 to input_number + 1 loop
                        output_data := signed(m_axis_filter_tdata); --to_real(sfixed(m_axis_filter_tdata))/2.0**FRACTIONAL_WIDTH;
                        decimal_vaue := to_real(sfixed(m_axis_filter_tdata))/2.0**FRACTIONAL_WIDTH; --to_integer(signed(m_axis_filter_tdata)); --to_integer(output_data);
                        write(file_line, decimal_vaue);
                        writeline(output_file, file_line);
                        wait until rising_edge(clk);
                    end loop;                   
                end if;

                report "End of write file reached!" severity note;
                file_close(output_File);
                write_done <= '1';
                wait;
        end process;
        
end fir_axis_test; 