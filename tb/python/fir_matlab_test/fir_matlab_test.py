import numpy as np
import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

CLOCK_PERIOD = 10
ORDER = 50
NUM_TAPS = ORDER + 1
INTEGER_BITS = 1
FRACTIONAL_BITS = 15
PIPE_DELAY = 4

def twos_complement(hexstr, bits):
    value = int(hexstr, 16)
    if value & (1 << (bits - 1)):
        value -= 1 << bits
    return value

def int_to_signed(value, bit_length):
    if value < 0:
        value = (1 << bit_length) + value
    
    bin_str = format(value, '0{}b'.format(bit_length))
    return bin_str

def signed_to_int(signed_val):
    integer_value = int(signed_val, 2) - (1 << len(signed_val)) if signed_val[0] == '1' else int(signed_val,2)
    return integer_value

async def read_output(dut, length):
    output_array = np.zeros((length,))
    reference_data = np.loadtxt("C:/Work/fir_filter_system/matlab/expected_impulse_response.txt", dtype=int)
    # global reference_data
    for i in range(0, length):
        output_array[i] = signed_to_int(str(dut.y.value))
        dut._log.info(output_array[i])
        assert abs((output_array[i] - reference_data[i])) < 1.5, f"Output {output_array[i]} != {reference_data[i]}"
        await Timer(CLOCK_PERIOD, units="ns")

async def read_input(dut, input_data):
    for i in range(len(input_data)):
        dut._log.info(input_data.dtype)
        dut.x.value = input_data[i]
        dut.x_valid.value = 1
        await Timer(CLOCK_PERIOD, units="ns")


@cocotb.test()
async def fir_matlab_test(dut):
    """Testing the filter using test vectors generated from MATLAB"""

    #Preparing Input Data and Reference Data
    #reference_data = np.loadtxt("C:/Work/fir_filter_system/matlab/expected_impulse_response.txt", dtype=int)
    #input_data = np.loadtxt("C:/Work/fir_filter_system/matlab/impulse_input.txt", dtype=np.int16)    
    input_data = np.zeros((51,), dtype = np.int32)
    input_data[0] = 32767
    for i in range(50):
          input_data.append(0)

    #Providing initial values for signals
    dut.reset.value = 1
    dut.enable.value = 0



    
    dut.x_valid.value = 0

    #Generating Clock Signal
    clock_signal = Clock(dut.clk, CLOCK_PERIOD, units="ns")
    cocotb.start_soon(clock_signal.start(start_high=False))
    await RisingEdge(dut.clk)
    await Timer(CLOCK_PERIOD*2, units="ns")

    #Applying Reset signal
    # dut.reset.value = 1
    # await Timer(CLOCK_PERIOD*2, units="ns")
    dut.reset.value = 0
    dut.enable.value = 1

    cocotb.start_soon(read_input(dut, input_data))
    await Timer(CLOCK_PERIOD*(ORDER // 2 + PIPE_DELAY), units="ns")
    cocotb.start_soon(read_output(dut, len(input_data)))
    await Timer(CLOCK_PERIOD*(len(input_data)), units="ns")

        







