if [file exists ../work/FIRQuesta] { exec rm -r FIRQuesta }
exec mkdir FIRQuesta

vlib FIRQuesta/work

vcom -2008 -l ./logs/FIRpackages.log -work work ../packages/fir_fixed_generics_package.vhdl
vcom -2008 -l ./logs/FIRpackages.log -work work ../packages/fixed_to_signed_package.vhdl
vcom -2008 -l ./logs/FIRrtl.log ../rtl/fir_filter_fixed.vhdl
vcom -2008 -l ./logs/FIRsim.log ../tb/vhdl/fir_filter_fixed_test.vhdl

vsim -gui work.fir_filter_fixed_test

quietly WaveActivateNextPane {} 0
add wave -divider Inputs:
add wave -color green clk reset
add wave -color cyan enable x x_valid

add wave -divider Outputs:
add wave -color yellow y

# run 51000ns
run 51000ns