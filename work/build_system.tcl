#parameters - change accordingly
set PROJECT_NAME fir_fifo_system
set PROJECT_FOLDER fir_fifo_system
set PROJECT_DIRECTORY ../work/$PROJECT_FOLDER
set SOURCE_FOLDER ../rtl
set VHDL_TEST_FOLDER ../tb/vhdl
set SV_TEST_FOLDER ..tb/sv
set PACKAGE_FOLDER ../packages
set CONSTRAINTS_FOLDER ../constraints
set REPORTS_FOLDER ../reports

#check if the project directory exists and is a directory
if {[file exists $PROJECT_DIRECTORY] && [file isdirectory $PROJECT_DIRECTORY]} {
    exec rm -r $PROJECT_FOLDER
}

#create project
create_project $PROJECT_NAME ./$PROJECT_FOLDER -part xczu9eg-ffvb1156-2-e -force
set_property board_part xilinx.com:zcu102:part0:3.4 [current_project]
set_property platform.extensible true [current_project]

#create block design
create_bd_design "fir_fifo_system"
# create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e_0
# apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]

#Add filter block to block design
add_files [glob $SOURCE_FOLDER/*]
set_property file_type {VHDL 2008} [get_files  $SOURCE_FOLDER/fir_filter_fixed.vhdl]
set_property file_type {VHDL 2008} [get_files  $SOURCE_FOLDER/fir_filter_axis.vhdl]
set_property top fir_filter_axis [current_fileset]
update_compile_order -fileset sources_1

set_property top fir_filter_axis_wrapper [current_fileset]
create_bd_cell -type module -reference fir_filter_axis_wrapper fir_filter_axis_wrap_0
set_property CONFIG.FREQ_HZ 128000000 [get_bd_pins /fir_filter_axis_wrap_0/clk]

#FIFO_IN
create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_in
set_property -dict [list \
  CONFIG.Clock_Type_AXI {Independent_Clock} \
  CONFIG.Enable_TLAST {true} \
  CONFIG.INTERFACE_TYPE {AXI_STREAM} \
  CONFIG.Input_Depth_axis {512} \
  CONFIG.TDATA_NUM_BYTES {4} \
  CONFIG.TUSER_WIDTH {0} \
] [get_bd_cells fifo_generator_in]

#FIFO_OUT
create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_out
set_property -dict [list \
  CONFIG.Clock_Type_AXI {Independent_Clock} \
  CONFIG.Enable_TLAST {true} \
  CONFIG.INTERFACE_TYPE {AXI_STREAM} \
  CONFIG.Input_Depth_axis {512} \
  CONFIG.TDATA_NUM_BYTES {4} \
  CONFIG.TUSER_WIDTH {0} \
] [get_bd_cells fifo_generator_out]

#Internal AXIS connections
connect_bd_intf_net [get_bd_intf_pins fifo_generator_in/M_AXIS] [get_bd_intf_pins fir_filter_axis_wrap_0/s_axis_filter]
connect_bd_intf_net [get_bd_intf_pins fir_filter_axis_wrap_0/m_axis_filter] [get_bd_intf_pins fifo_generator_out/S_AXIS]

#External AXIS connections
make_bd_intf_pins_external  [get_bd_intf_pins fifo_generator_out/M_AXIS]
make_bd_intf_pins_external  [get_bd_intf_pins fifo_generator_in/S_AXIS]

#XPM_CDC
create_bd_cell -type ip -vlnv xilinx.com:ip:xpm_cdc_gen:1.0 xpm_cdc_gen_0
set_property -dict [list \
  CONFIG.CDC_TYPE {xpm_cdc_single} \
  CONFIG.DEST_SYNC_FF {2} \
  CONFIG.INIT_SYNC_FF {true} \
] [get_bd_cells xpm_cdc_gen_0]

#reset connections
create_bd_port -dir I -type rst resetn
connect_bd_net [get_bd_ports resetn] [get_bd_pins xpm_cdc_gen_0/src_in]
connect_bd_net [get_bd_pins xpm_cdc_gen_0/dest_out] [get_bd_pins fir_filter_axis_wrap_0/resetn]
connect_bd_net [get_bd_ports resetn] [get_bd_pins fifo_generator_in/s_aresetn]
connect_bd_net [get_bd_pins fifo_generator_out/s_aresetn] [get_bd_pins xpm_cdc_gen_0/dest_out]

#Clock connections
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {New External Port} Freq {64} Ref_Clk0 {None} Ref_Clk1 {None} Ref_Clk2 {None}}  [get_bd_pins xpm_cdc_gen_0/src_clk]
connect_bd_net [get_bd_ports clk_64MHz] [get_bd_pins fifo_generator_in/s_aclk]
connect_bd_net [get_bd_ports clk_64MHz] [get_bd_pins fifo_generator_out/m_aclk]

apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {New External Port} Freq {128} Ref_Clk0 {None} Ref_Clk1 {None} Ref_Clk2 {None}}  [get_bd_pins xpm_cdc_gen_0/dest_clk]
connect_bd_net [get_bd_ports clk_128MHz] [get_bd_pins fir_filter_axis_wrap_0/clk]
connect_bd_net [get_bd_ports clk_128MHz] [get_bd_pins fifo_generator_in/m_aclk]
connect_bd_net [get_bd_ports clk_128MHz] [get_bd_pins fifo_generator_out/s_aclk]

#Validate Design
validate_bd_design
regenerate_bd_layout
save_bd_design

make_wrapper -files [get_files C:/Work/fir_filter_system/work/firfiltersystem/firfiltersystem.srcs/sources_1/bd/fir_fifo_system/fir_fifo_system.bd] -top
add_files -norecurse c:/Work/fir_filter_system/work/firfiltersystem/firfiltersystem.gen/sources_1/bd/fir_fifo_system/hdl/fir_fifo_system_wrapper.v
update_compile_order -fileset sources_1
