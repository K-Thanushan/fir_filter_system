if [file exists ../work/FIRQuesta] { exec rm -r FIRQuesta }
exec mkdir FIRQuesta

vlib FIRQuesta/work

vcom -2008 -l ./logs/FIRpackages.log -work work ../packages/fir_fixed_generics_package.vhdl
vcom -2008 -l ./logs/FIRpackages.log -work work ../packages/fixed_to_signed_package.vhdl
vcom -2008 -l ./logs/FIRrtl.log ../rtl/fir_filter_fixed.vhdl
vcom -2008 -l ./logs/FIRrtl.log ../rtl/fir_filter_axis.vhdl
vcom -2008 -l ./logs/FIRsim.log ../tb/vhdl/fir_filter_axis_test.vhdl

vsim -voptargs=+acc+fir_filter_axis -gui work.fir_filter_axis_test

quietly WaveActivateNextPane {} 0

add wave -color green clk reset
add wave -divider Master_Interface:
add wave -color cyan s_axis_filter_tvalid s_axis_filter_tready s_axis_filter_tlast s_axis_filter_tdata

add wave -divider Slave_Interface:
add wave -color yellow m_axis_filter_tvalid m_axis_filter_tready m_axis_filter_tlast m_axis_filter_tdata

# run 2000ns
run 51000ns