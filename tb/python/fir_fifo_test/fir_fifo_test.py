import numpy as np

import cocotb
from cocotbext.axi import AxiStreamSource, AxiStreamBus, AxiStreamSink
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

CLOCK_CYCLES = 5000
FAST_CLK_PERIOD = 7.81
SLOW_CLK_PERIOD = 31.25
ORDER = 50
BIT_WIDTH = 16
FRACTIONAL_BITS = 15
PIPE_DELAY = 3

def fixed_to_float_manual(binary_str, integer_bits, fractional_bits):
    # Convert the integer part
    integer_part = int(binary_str[:integer_bits], 2)
    
    # Handle the sign for two's complement
    if binary_str[0] == '1':  # Sign bit is set
        integer_part -= (1 << integer_bits)
    
    # Convert the fractional part
    fractional_part = int(binary_str[integer_bits:], 2) / (1 << fractional_bits)
    
    # Combine the integer and fractional parts
    float_value = integer_part + fractional_part
    
    return float_value

def twos_complement(hexstr, bits):
    value = int(hexstr, 16)
    if value & (1 << (bits - 1)):
        value -= 1 << bits
    return value

async def generate_slow_clock(dut):
    """Generate Slow Clock Pulses"""

    for cycle in range(CLOCK_CYCLES):
        dut.clk_64MHz.value = 0
        await Timer(SLOW_CLK_PERIOD//2, units="ns")
        dut.clk_64MHz.value = 0
        await Timer(SLOW_CLK_PERIOD//2, units="ns")

async def generate_fast_clock(dut):
    """Generate Fast Clock Pulses"""

    for cycle in range(CLOCK_CYCLES):
        dut.clk_128MHz.value = 0
        await Timer(FAST_CLK_PERIOD//2, units="ns")
        dut.clk_128MHz.value = 1
        await Timer(FAST_CLK_PERIOD//2, units="ns")

@cocotb.test()
async def fir_fifo_impulse_test(dut):
    """Testing the impulse response of the FIR FIFO system"""

    #Preparing data for input and reference data for testing
    reference_data = np.loadtxt("C:/Work/fir_filter_system/matlab/filter_coefficients.txt", dtype=float)
    input_data = [0x7FFF]
    for i in range(50):
        input_data.append(0x0000)

    #Providing reset signal
    dut.resetn.value = 0

    #Generating clocks using cocotb inbuilt functions
    slow_clock = Clock(dut.clk_64MHz, SLOW_CLK_PERIOD, units="ns")
    fast_clock = Clock(dut.clk_128MHz, FAST_CLK_PERIOD, units="ns")
    cocotb.start_soon(slow_clock.start(start_high=False))
    cocotb.start_soon(fast_clock.start(start_high=False))
    await RisingEdge(dut.clk_64MHz)
    await Timer(SLOW_CLK_PERIOD*2, units="ns")

    #Remove reset
    dut.resetn.value = 1

    await RisingEdge(dut.fir_fifo_system_i.fir_filter_axis_wrap_0.resetn)
    await RisingEdge(dut.clk_64MHz)
    await Timer(SLOW_CLK_PERIOD*4, units="ns")

    #AXIS Source and Sink
    axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "S_AXIS_0"), dut.clk_64MHz, byte_size = 16)
    axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut,"M_AXIS_0"), dut.clk_64MHz, byte_size=16)
    dut._log.info("AXIS source is waiting for data")
    await axis_source.send(input_data)
    await axis_source.wait()
    dut._log.info("AXIS source has sent data")

    axis_output_hex_data = await axis_sink.recv()
    dut._log.info("AXIS sink has received data")
    axis_output_data = [twos_complement(hex(i)[2:], 16) for i in axis_output_hex_data]

    errors = 0
    output_data = np.zeros(len(axis_output_data))
    for cycle in range(len(axis_output_data)):
        #dut._log.info("%s", format(axis_output_data[cycle] % (1 << BIT_WIDTH), "016b"))
        output_data[cycle] = fixed_to_float_manual(format(axis_output_data[cycle] % (1 << BIT_WIDTH), "016b"), BIT_WIDTH-FRACTIONAL_BITS, FRACTIONAL_BITS)
        #assert (abs(refData[cycle]-outData[cycle]) < 0.001), f"[{cycle}] Impulse Response is incorrect: {outData[cycle]} but correct value: {refData[cycle]}"
        if abs(reference_data[cycle] - output_data[cycle]) >= 0.001:
            errors += 1
            dut._log.info("[%s] Impulse Response is incorrect: %s but correct value: %s", cycle, output_data[cycle], reference_data[cycle])
    dut._log.info("Errors count: %s", errors)
    np.savetxt("../cocotb/impulse_response.txt", output_data, fmt='%.20f')
