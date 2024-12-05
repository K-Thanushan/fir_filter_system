#parameters - change accordingly
set PROJECT_NAME firfiltersystem
set PROJECT_FOLDER firfiltersystem
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
create_project $PROJECT_NAME ./$PROJECT_FOLDER -part xczu7ev-ffvc1156-2-e -force
set_property board_part xilinx.com:zcu106:part0:2.5 [current_project]

#add design sources
add_files [glob $SOURCE_FOLDER/*]
set_property file_type {VHDL 2008} [get_files  $SOURCE_FOLDER/fir_filter_fixed.vhdl]
set_property file_type {VHDL 2008} [get_files  $SOURCE_FOLDER/fir_filter_axis.vhdl]
set_property top fir_filter_axis [current_fileset]

#add packages
add_files $PACKAGE_FOLDER/fir_fixed_generics_package.vhdl
add_files $PACKAGE_FOLDER/fixed_to_signed_package.vhdl
set_property file_type {VHDL 2008} [get_files $PACKAGE_FOLDER/fir_fixed_generics_package.vhdl]
set_property file_type {VHDL 2008} [get_files $PACKAGE_FOLDER/fixed_to_signed_package.vhdl]

#add simulation sources
add_files -fileset sim_1 [glob $VHDL_TEST_FOLDER/*]
set_property file_type {VHDL 2008} [get_files  $VHDL_TEST_FOLDER/fir_filter_fixed_test.vhdl]
set_property file_type {VHDL 2008} [get_files  $VHDL_TEST_FOLDER/fir_filter_axis_test.vhdl]
set_property top fir_filter_axis_test [get_filesets sim_1]

#running simulation
launch_simulation
add_wave {{/fir_filter_axis_test/dut}} 
relaunch_sim

#Adding constraints
add_files -fileset constrs_1 -norecurse $CONSTRAINTS_FOLDER/fir_constraints.xdc
set_property target_constrs_file $CONSTRAINTS_FOLDER/fir_constraints.xdc [current_fileset -constrset]

#Running Synthesis
launch_runs synth_1 -jobs 6
wait_on_run synth_1
open_run synth_1 -name synth_1

#Synthesis Reports
report_timing_summary -file $REPORTS_FOLDER/syn_timing.rpt
report_utilization -file $REPORTS_FOLDER/syn_utilization.rpt
report_power -file $REPORTS_FOLDER/syn_power.rpt

#Running implementation
launch_runs impl_1 -jobs 6
wait_on_run impl_1
open_run impl_1 -name impl_1

#Implementation reports
report_timing_summary -file $REPORTS_FOLDER/impl_timing.rpt
report_methodology -name ultrafast_methodology_1 -file $REPORTS_FOLDER/impl_methodolgy.rpt
report_drc -name drc_1 -ruledecks {default} -file $REPORTS_FOLDER/impl_drc.rpt
report_power -file $REPORTS_FOLDER/impl_power.rpt
report_utilization -file $REPORTS_FOLDER/impl_utilization.rpt
report_ssn -file $REPORTS_FOLDER/impl_noise.rpt
