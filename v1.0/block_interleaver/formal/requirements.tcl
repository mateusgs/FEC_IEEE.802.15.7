proc get_requirements {} {
set dit_requirements [dict create]

# REQ_DIT_001: Initial state of DEINTERLEVER.
dict set dit_requirements REQ_DIT_001 description\
"REQ_DIT_001: The Deinterlever shall be reset by the input port 'rst', and this is an\
synchronous active high pin. After setting it to '1' through a rising edge of the\
clk input all outputs will be set  to zero, except for the o_in_ready, which will be\
set to ‘1’, and the data output, that will depend on the previous values stored on\
the deinterleaver RAM.” 

# REQ_DIT_002: Multiple instances of i_start_deinterleaver in the same cycle.
dict set dit_requirements REQ_DIT_002 description\
"REQ_DIT_002: The signal i_start_deinterleaver, during an deinterleaving\
cycle, must be set for one, and only one, period of clk. After being set once, it\
must not be set again before sending the complete interleaved codeword and, then, back\
to ‘1’. The o_in_ready is set to ‘0’ after the i_end_deinterleaver is pulsed and is\
turned back to ‘1’ in the end of the reading process. If it dosn’t behave like this\
all output signals, except for the o_error, that will change to ‘1’, and the data\
output signal, must be set to ‘0’ in the next rising edge of clk pulse."  

# REQ_DIT_003: Multiple instances of i_end_deinterleaver in the same cycle or in anticipated position.
dict set dit_requirements REQ_DIT_002 description\
"REQ_DIT_003: The signal i_end_deinterleaver,as the i_start_deinterleaver,\
must be set to ‘1’ only once for a single period of clk after the i_start_deinterleaver\
has already pulsed during an deinterleaving cycle. After that, it can only change\
again after another pulse of i_start_deinterleaver has happened. If those\
requirements are not met, the outputs must be changed to ‘0’, except for the\
data outputs and the o_error. The latter will made ‘1’."
 
# REQ_DIT_004: i_valid not restricted to a valid period or out of sync with the i_start_deinterleaver o i_end_deinterleaver signals.
dict set dit_requirements REQ_DIT_004 description\
"REQ_DIT_004: i_valid signal must go along with the i_start_identerleaver and\
i_end_deinterleaver signals. Also, it must appear only together with or between\
those two signals. Appearing on another time or not coming along with the other\
two, will result on the outputs being changed to ‘0’, except for the o_error,\
which will change to ‘1’ and the o_data."

# REQ_DIT_005: RAM overflow.
dict set dit_requirements REQ_DIT_005 description\
"REQ_DIT_005:  If an i_end_interleaver doesn’t appear after i_valid has\
accumulated a total number of periods of clk in ‘1’ equal to the maximum\
number of inputs, all outputs must change to ‘0’, except for o_error (‘1’) and the\
data output signals."

#REQ_DIT_006: End of the reading process
dict set dit_requirements REQ_DIT_007 description\
"REQ_DIT_006: the reading process will only end when all data stored \
in RAM is consumed, that is, when the number of outputs reach the \
number of inputs during the writing process. Before it happens, \
the block will not be available to receive new data (o_in_ready = ‘0’).” 

#REQ_DIT_008: Output data consumption
dict set dit_requirements REQ_DIT_008 description\
"REQ_DIT_008: For each period of clock in which i_consume is set to\
‘1’ in the reading process, a new valid data output must be sent in the \
following period of clock. When i_consume is set to ‘0’ during the reading \
process, all outputs will be stable.” 

proc create_properties {requirements type} {
	
	#REQ_DIT_001
	# Asserts
	set check_properties []
	set check_properties [linsert $check_properties end [assert {rst |=> not(o_error)} -name REQ_DIT_001.CHECK.01]]
	set check_properties [linsert $check_properties end [assert {rst |=> o_in_ready} -name REQ_DIT_001.CHECK.02]]
	set check_properties [linsert $check_properties end [assert {rst |=> not(o_valid)} -name REQ_DIT_001.CHECK.03]]
	set check_properties [linsert $check_properties end [assert {rst |=> not(o_start_deinterleaver)} -name REQ_DIT_001.CHECK.04]]
	set check_properties [linsert $check_properties end [assert {rst |=> not(o_end_deinterleaver)} -name REQ_DIT_001.CHECK.05]]
	dict set requirements REQ_DIT_001 checks $check_properties
	
	# Covers
	set cover_properties []
	set cover_properties [linsert $check_properties end [cover {rst |=> not(o_error)} -name REQ_DIT_001.COVER.01]]
	set cover_properties [linsert $check_properties end [cover {rst |=> o_in_ready} -name REQ_DIT_001.COVER.02]]
	set cover_properties [linsert $check_properties end [cover {rst |=> not(o_valid)} -name REQ_DIT_001.COVER.03]]
	set cover_properties [linsert $check_properties end [cover {rst |=> not(o_start_interleaver)} -name REQ_DIT_001.COVER.04]]
	set cover_properties [linsert $check_properties end [cover {rst |=> not(o_end_interleaver)} -name REQ_DIT_001.COVER.05]]
	dict set requirements REQ_DIT_001 covers $cover_properties

	#REQ_DIT_006
	# Asserts
	set check properties []
	set check_properties [linsert $check_properties end [assert {o_in_ready and i_consume |=> o_error} -name REQ_DIT_006.CHECK.01]]
	dict set requirements REQ_DIT_006 checks $check_properties
	
	# Covers
	set cover properties []
	set cover_properties [linsert $check_properties end [cover {o_in_ready and i_consume |=> o_error} -name REQ_DIT_006.COVER.01]]
	dict set requirements REQ_DIT_001 covers $cover_properties


	#REQ_DIT_002
	# Asserts
	set check properties []
	set check_properties [linsert $check_properties end [assert {not(o_in_ready) and i_start_deinterleaver |=> o_error} -name REQ_DIT_002.CHECK.01]]
	dict set requirements REQ_DIT_002 checks $check_properties
	
	# Covers
	set cover properties []
	set cover_properties [linsert $check_properties end [cover {not(o_in_ready) and i_start_deinterleaver |=> o_error} -name REQ_DIT_002.COVER.01]]
	dict set requirements REQ_DIT_002 covers $cover_properties

	#REQ_DIT_008
	# Asserts
	set check properties []
	set check_properties [linsert $check_properties end [assert {not(o_in_ready) and i_consume |=> o_valid} -name REQ_DIT_008.CHECK.01]]
	set check_properties [linsert $check_properties end [assert {not(o_in_ready) and not(i_consume) |=> not(o_valid)} -name REQ_DIT_008.CHECK.02]]
	dict set requirements REQ_DIT_006 checks $check_properties

	# Covers
	set cover properties []
	set cover_properties [linsert $check_properties end [cover {not(o_in_ready) and i_consume |=> o_valid} -name REQ_DIT_008.COVER.01]]
	set cover_properties [linsert $check_properties end [cover {not(o_in_ready) and not(i_consume) |=> not(o_valid)} -name REQ_DIT_008.COVER.02]]
	dict set requirements REQ_DIT_006 covers $cover_properties

	return $requirements
}



