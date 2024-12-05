import numpy as np
import cocotb
from cocotb.triggers import Timer, RisingEdge
from golden_filter_model import sinc_filter

CLOCK_PERIOD = 10
ORDER = 50
NUM_TAPS = ORDER + 1
fc = 0.15
fs = 1
INTEGER_BITS = 1
FRACTIONAL_BITS = 15
PIPE_DELAY = 4

def fixed_to_float_manual(binary_string, integer_bits, fractional_bits):
    # Convert the integer part
    integer_part = int(binary_string[:integer_bits], 2)
    
    # Handle the sign for two's complement
    if binary_string[0] == '1':  # Sign bit is set
        integer_part -= (1 << integer_bits)
    
    # Convert the fractional part
    fractional_part = int(binary_string[integer_bits:], 2) / (1 << fractional_bits)
    # Combine the integer and fractional parts
    float_value = integer_part + fractional_part
    return float_value

async def generate_clock(dut):
    """Generate Clock signal"""
    for cycle in range(100):
        dut.clk.value = 0
        await Timer(CLOCK_PERIOD//2, units="ns")
        dut.clk.value = 1
        await Timer(CLOCK_PERIOD//2, units="ns")

async def reset_dut(reset, duration_ns):
    """Generating reset signal"""
    reset.value = 1
    await Timer(duration_ns, units="ns")
    reset.value = 0

@cocotb.test()
async def fir_fixed_test(dut):
    coefficients = sinc_filter(fc,NUM_TAPS, fs) #np.loadtxt("C:/Work/fir_filter_system/tb/filter_coefficients.txt")
    dut.enable.value = 0
    dut.x.value = 0
    await cocotb.start(generate_clock(dut))
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    await Timer(CLOCK_PERIOD*2, units="ns")

    dut.reset.value = 0
    dut.enable.value = 1
    dut.x.value = 1
    await Timer(CLOCK_PERIOD, units="ns")
    dut.x.value = 0
    output_array = np.zeros((NUM_TAPS,))
    await Timer(CLOCK_PERIOD*(ORDER // 2 + PIPE_DELAY), units="ns")
    for i in range(0, ORDER+1):
        # dut._log.info(dut.y.value)
        floaty = fixed_to_float_manual(str(dut.y.value), INTEGER_BITS, FRACTIONAL_BITS)
        output_array[i] = floaty
        assert abs((output_array[i] - coefficients[i])) < 0.001, f"Output {floaty} != {coefficients[i]}"
        await Timer(CLOCK_PERIOD, units="ns")

    np.savetxt("C:/Work/fir_filter_system/tb/filter_cocotb_output.txt", output_array, fmt='%.20f')
    

    