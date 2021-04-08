set sdc_version 1.5
set_load_unit -picofarads 1

create_clock -name {clk} -period 3.6 [get_ports {clk}]
set_false_path -from [get_ports {rst}]

##INPUTS
#set_input_delay -clock clk -min 0.1 [all_inputs]
set_input_delay -clock clk -min 0.2 [all_inputs]
#set_input_delay -clock clk -max 0.2 [all_inputs]
set_input_delay -clock clk -max 2 [all_inputs]
#set_input_transition -min -rise 0.003 [all_inputs]
#set_input_transition -max -rise 0.16 [all_inputs]
#set_input_transition -min -fall 0.003 [all_inputs]
#set_input_transition -max -fall 0.16 [all_inputs]
set_input_transition -rise 0.2 [all_inputs]
set_input_transition -fall 0.2 [all_inputs]

##OUPUTS
#set_output_delay -clock clk -min 0.1 [all_inputs]
set_output_delay -clock clk -min 0.5 [all_outputs]
#set_output_delay -clock clk -max 0.2 [all_inputs]
set_output_delay -clock clk -max 2.9 [all_outputs]
#set_load -min 0.0014 [all_outputs]
#set_load -max 0.32 [all_outputs]
set_load 4 [all_outputs]
