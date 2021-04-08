# Copyright (C) 2018  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details.

# Quartus Prime: Generate Tcl File for Project
# File: block_interleaver.tcl
# Generated on: Sun Apr 19 22:21:42 2020

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "block_interleaver"]} {
		puts "Project block_interleaver is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists block_interleaver]} {
		project_open -revision block_interleaver block_interleaver
	} else {
		project_new -revision block_interleaver block_interleaver
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone V"
	set_global_assignment -name DEVICE 5CGXFC5C6F27C7
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 18.1.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "15:39:21  APRIL 19, 2020"
	set_global_assignment -name LAST_QUARTUS_VERSION "18.1.0 Lite Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/generic_types.vhd
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/generic_functions.vhd
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/generic_components.vhd
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/comparator.vhd
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/sync_ld_dff.vhd
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/up_down_counter.vhd
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/incrementer.vhd
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/half_adder_unit.vhd
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/half_subtractor_unit.vhd
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/decrementer.vhd
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/single_port_linear_ram.vhd
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/single_port_2D_ram.vhd
	set_global_assignment -name VHDL_FILE ../../generic_components/rtl/adder.vhd
	set_global_assignment -name VHDL_FILE ../rtl/block_interleaver_components/wr_rd_status_selector.vhd
	set_global_assignment -name VHDL_FILE ../rtl/block_interleaver_components/simplified_m2D_index_counter.vhd
	set_global_assignment -name VHDL_FILE ../rtl/block_interleaver_components/m2D_index_counter_core.vhd
	set_global_assignment -name VHDL_FILE ../rtl/block_interleaver_components/m2D_index_counter.vhd
	set_global_assignment -name VHDL_FILE ../rtl/block_interleaver_components/flag_signals_generator.vhd
	set_global_assignment -name VHDL_FILE ../rtl/rectangular_interleaver.vhd
	set_global_assignment -name VHDL_FILE ../rtl/rectangular_deinterleaver.vhd
	set_global_assignment -name VHDL_FILE ../rtl/interleaver_data_path.vhd
	set_global_assignment -name VHDL_FILE ../rtl/interleaver_controller.vhd
	set_global_assignment -name VHDL_FILE ../rtl/deinterleaver_data_path.vhd
	set_global_assignment -name VHDL_FILE ../rtl/block_interleaver_components.vhd
	set_global_assignment -name VHDL_FILE ../rtl/block_interleaver.vhd
	set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
	set_global_assignment -name VHDL_SHOW_LMF_MAPPING_MESSAGES OFF
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top
	set_parameter -name MODE true
	set_parameter -name NUMBER_OF_ELEMENTS 4385
	set_parameter -name NUMBER_OF_LINES 15
	set_parameter -name WORD_LENGTH 4

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
