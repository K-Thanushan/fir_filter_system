import numpy as np
import cocotb
from cocotbext.axi import AxiStreamSource, AxiStreamBus, AxiStreamSink
from cocotb.triggers import Timer, RisingEdge

CLOCK_CYCLES     = 1000
CLOCK_PERIOD     = 10
ORDER            = 50
BIT_WIDTH        = 16
FRACTIONAL_WIDTH = 15
PIPE_DELAY       = 4

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
    val = int(hexstr, 16)
    if val & (1 <<( bits-1)):
        val -= 1 << bits
    return val

async def generate_clock(dut):
    """ Generate Clock Signal """
    for cycle in range(CLOCK_CYCLES):
        dut.clk.value = 0
        await Timer(CLOCK_PERIOD//2, units="ns")
        dut.clk.value = 1
        await Timer(CLOCK_PERIOD//2, units="ns")

@cocotb.test()
async def AXIS_filter_test(dut):
    reference_data = np.loadtxt("C:/Work/fir_filter_system/tb/filter_coefficients.txt", dtype=float)
    input_data = [0x7fff] #[0x0001]
    for i in range(50):
        input_data.append(0x0000)

    dut.reset.value = 0
    await cocotb.start(generate_clock(dut))

    dut.reset.value = 1
    await RisingEdge(dut.clk)
    await Timer(CLOCK_PERIOD*2, units="ns")

    dut.reset.value = 0
    AXIS_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis_filter"), dut.clk, dut.reset, byte_size=32)
    AXIS_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis_filter"), dut.clk, dut.reset, byte_size=32)
    dut._log.info("AXIS_source is waiting for data")
    await AXIS_source.send(input_data)
    await AXIS_source.wait()
    dut._log.info("AXIS_source has sent data")

    AXIS_output_hex_data = await AXIS_sink.recv()
    dut._log.info("AXIS_sink has received data")
    AXIS_output_data = [twos_complement(hex(i)[2:], 4) for i in AXIS_output_hex_data]
    dut._log.info("%s", AXIS_output_data)
    dut._log.info("%s", len(AXIS_output_data))
    
    num_errors = 0
    output_data = np.zeros(len(AXIS_output_data))
    for cycle in range(len(AXIS_output_data)):
        #dut._log.info("%s", format(axis_out_data[cycle] % (1 << BIT_WIDTH), "016b"))
        output_data[cycle] = fixed_to_float_manual(format(AXIS_output_data[cycle] % (1 << BIT_WIDTH), "016b"), BIT_WIDTH-FRACTIONAL_WIDTH, FRACTIONAL_WIDTH)
        #assert (abs(reference_data[cycle]-output_data[cycle]) < 0.001), f"[{cycle}] Impulse Response is incorrect: {output_data[cycle]} but correct value: {reference_data[cycle]}"
        if abs(reference_data[cycle]-output_data[cycle]) >= 0.001:
            num_errors += 1
            dut._log.info("[%s] Impulse Response is incorrect: %s but correct value: %s", cycle, output_data[cycle], reference_data[cycle])
    dut._log.info("Errors count: %s", num_errors)
    np.savetxt("C:/Work/fir_filter_system/tb/cocotb_impulse_response.txt", output_data, fmt='%.20f')