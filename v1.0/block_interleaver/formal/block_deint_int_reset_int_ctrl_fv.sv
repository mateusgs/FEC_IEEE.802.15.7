module block_deint_int_reset_int_ctrl_fv #(NUMBER_OF_ELEMENTS=12, 
                                           NUMBER_OF_LINES = 3,
                                           WORD_LENGTH = 3) (
    clk,
    rst,
    i_consume,
    i_end_cw,
    i_start_cw,
    i_valid,
    i_data,
    o_end_cw,
    o_error,
    o_in_ready,
    o_start_cw,
    o_valid,
    o_data);

input clk;
input rst;
input i_consume;
input i_end_cw;
input i_start_cw;
input i_valid;
input [WORD_LENGTH-1:0] i_data;
input o_end_cw;
input o_error;
input o_in_ready;
input o_start_cw;
input o_valid;
input [WORD_LENGTH-1:0] o_data;

property p (expr);
    @(posedge clk) disable iff (rst)
    expr;
endproperty

//Helper logic to inform whether the interleaver is receiving a new codeword.
reg r_receiving_cw;
always @(posedge clk or posedge o_error) begin
    if (rst)
        r_receiving_cw <= 1'b0;
    else if (o_error)
        r_receiving_cw <= 1'b0;
    else if (i_valid && i_start_cw && !i_end_cw && o_in_ready && !o_error)
        r_receiving_cw <= 1'b1;
    else if (i_valid && i_end_cw && o_in_ready && !o_error)
        r_receiving_cw <= 1'b0;
end

int r_symbol_counter;
reg r_no_consumption_yet;

always @(posedge clk or posedge o_error) begin
    if (rst) begin
        r_symbol_counter <= 0;
        r_no_consumption_yet <= 1'b1;
    end else if (o_error) begin
        r_symbol_counter <= 0;
        r_no_consumption_yet <= 1'b1;
    end else if (o_valid && i_consume) begin
	//!o_end_cw because the counter is "0" at this point.
	//This is because the first received symbol is not computed
	//in this counter. Therefore, it is just a compensation.
        r_symbol_counter <= r_symbol_counter - 1;
        r_no_consumption_yet <= 1'b0;
    end else if (i_valid) begin
        r_symbol_counter <= r_symbol_counter + 1;
        r_no_consumption_yet <= 1'b1;
    end
end

// "REQ_INTER_001: The block interlever shall be reset by the input port 'rst', and this is an\
// synchronous active high pin. After setting it to '1' through a rising edge of the\
// clk input all outputs will be set  to zero, except for the o_in_ready, which will be\
// set to ‘1’, and the data output, that will depend on the previous values stored on\
// the deinterleaver RAM.” 
REQ_INTER_001_CHECK_01: assert property (rst |=> !o_error && o_in_ready && !o_start_cw && !o_end_cw && !o_valid);

// "REQ_INTER_002: Interleaver cannot receive the just 1 symbol."
REQ_INTER_002_CHECK_01: assert property (p(!r_receiving_cw && i_valid && i_end_cw|=> o_error));
REQ_INTER_002_COVER_01: cover property (p(!r_receiving_cw && i_valid && i_end_cw|=> o_error));

// "REQ_INTER_003: The first valid symbol must assert i_start_cw"
REQ_INTER_003_CHECK_01: assert property (p(!r_receiving_cw && i_valid && !i_start_cw |=> o_error));
REQ_INTER_003_COVER_01: cover property (p(!r_receiving_cw && i_valid && !i_start_cw |=> o_error));

// "REQ_INTER_004: Once the interleaver received the first valid symbol, i_start_cw cannot be asserted
// with i_valid again util the end of codeword transmission."
REQ_INTER_004_CHECK_01: assert property (p(r_receiving_cw && i_valid && i_start_cw |=> o_error));
REQ_INTER_004_COVER_01: cover property (p(r_receiving_cw && i_valid && i_start_cw |=> o_error));
REQ_INTER_004_CHECK_02: assert property (p(r_receiving_cw && r_symbol_counter < NUMBER_OF_ELEMENTS && !i_valid && i_start_cw |=> !o_error));
REQ_INTER_004_COVER_02: cover property (p(r_receiving_cw && r_symbol_counter < NUMBER_OF_ELEMENTS && !i_valid && i_start_cw |=> !o_error));

// "REQ_INTER_005: The last symbol received during reception (i_end_cw && i_valid) should deassert
// o_in_ready in the next cycle. It means that the interleaver is in transmission 
// mode, and it is not able to receive any new valid symbol."
REQ_INTER_005_CHECK_01: assert property (p(r_receiving_cw && i_valid && i_end_cw |=> !o_in_ready));
REQ_INTER_005_COVER_01: cover property (p(r_receiving_cw && i_valid && i_end_cw |=> !o_in_ready));

// "REQ_INTER_006: If the interlever is transmission mode (o_in_ready = 0), it should not receive
// any new symbol.
REQ_INTER_006_CHECK_01: assert property (p(!o_in_ready && i_valid |=> o_error));
REQ_INTER_006_COVER_01: cover property (p(!o_in_ready && i_valid |=> o_error));

// "REQ_INTER_007: During codeword transmission o_start_cw should be asserted until the first
//  valid symbol is consumed"
REQ_INTER_007_CHECK_01: assert property (p(o_valid && r_no_consumption_yet |-> o_start_cw));
REQ_INTER_007_COVER_01: cover property (p(o_valid && r_no_consumption_yet |-> o_start_cw));

// "REQ_INTER_008: The last symbol should assert o_end_cw, and it must be asserted until it is consumed.
// And the number of valid received symbols must be equal to the number of transmitted symbols for a given
// codeword"
REQ_INTER_008_CHECK_01: assert property (p(r_symbol_counter == 1 && o_valid |-> o_end_cw));
REQ_INTER_008_COVER_01: cover property (p(r_symbol_counter == 1 && o_valid |-> o_end_cw));

// "REQ_INTER_009: o_valid and o_in_ready behavior when receiving a codeword."
REQ_INTER_009_CHECK_01: assert property (p(r_receiving_cw |-> !o_valid && o_in_ready));
REQ_INTER_009_COVER_01: cover property (p(r_receiving_cw |-> !o_valid && o_in_ready));

// "REQ_INTER_010: When the last symbol is consumed, the interleaver will be able to 
// receive a new codeword."
REQ_INTER_010_CHECK_01: assert property (p(!i_valid && o_end_cw && o_valid && i_consume |=> o_in_ready && !o_valid));
REQ_INTER_010_COVER_01: cover property (p(!i_valid && o_end_cw && o_valid && i_consume |=> o_in_ready && !o_valid));

// "REQ_INTER_011: o_valid must be asserted one cycle after the deassertion of o_in_ready. This cycle in between is
// the latency during the transition from receiving to transmitting mode."
REQ_INTER_011_CHECK_01: assert property (p(r_receiving_cw && o_in_ready ##1 !i_valid && !o_in_ready && !o_error && r_symbol_counter <= NUMBER_OF_ELEMENTS |=> o_valid));
REQ_INTER_011_COVER_01: cover property (p(r_receiving_cw && o_in_ready ##1 !i_valid && !o_in_ready && !o_error && r_symbol_counter <= NUMBER_OF_ELEMENTS |=> o_valid));

// "REQ_INTER_012: When a valid symbol is consumed and it is not the last one, o_valid continues asserted
// o_in_ready deasserted in the next cycle."
REQ_INTER_012_CHECK_01: assert property (p(!i_valid && !o_end_cw && o_valid && i_consume |=> !o_in_ready && o_valid));
REQ_INTER_012_COVER_01: cover property (p(!i_valid && !o_end_cw && o_valid && i_consume |=> !o_in_ready && o_valid));

// "REQ_INTER_013: Memory overflow of internal memory should raise the error flag."
REQ_INTER_013_CHECK_01: assert property (p(r_symbol_counter > NUMBER_OF_ELEMENTS && r_receiving_cw && i_valid |=> o_error));
REQ_INTER_013_COVER_01: cover property (p(r_symbol_counter > NUMBER_OF_ELEMENTS && r_receiving_cw && i_valid |=> o_error));

endmodule
