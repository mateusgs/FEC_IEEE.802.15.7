module block_interleaver_func_fv #(NUMBER_OF_ELEMENTS=12,
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
//reg r_receiving_cw;
//reg r_transmitting_cw;
/*always @(posedge clk or posedge o_error) begin
    if (rst) begin
        r_receiving_cw <= 1'b0;
        r_transmitting_cw <= 1'b0;
    end else if (o_error) begin
        r_receiving_cw <= 1'b0;
        r_transmitting_cw <= 1'b0;
    end else if (i_valid && i_start_cw && !i_end_cw && o_in_ready && !o_error)
    begin
        r_receiving_cw <= 1'b1;
        r_transmitting_cw <= 1'b0;
    end else if (i_valid && i_end_cw && o_in_ready && !o_error) begin
        r_receiving_cw <= 1'b0;
        r_transmitting_cw <= 1'b1;
    end else if (o_valid && o_end_cw && i_consume) begin
        r_transmitting_cw <= 1'b0;
        r_receiving_cw <= 1'b0;
    end
end*/

let w_inc_rx_counter = $past(i_valid) && $past(o_in_ready) && !$past(rst) &&
!o_error;
let w_inc_tx_counter = o_valid && i_consume && !o_end_cw;
let r_lin_cnt = GEN_INT.INTERLEAVER_INST.IDP.r_lin_cnt;
let r_col_cnt = GEN_INT.INTERLEAVER_INST.IDP.r_col_cnt;
let r_last_col = GEN_INT.INTERLEAVER_INST.IDP.r_last_col;
let w_col_bound = GEN_INT.INTERLEAVER_INST.IDP.w_mux3;
let r_last_lin = GEN_INT.INTERLEAVER_INST.IDP.r_last_lin;

REQ_FUNC_INTER_CHECK_01: assert property (p(w_inc_rx_counter &&
!$past(i_end_cw) && r_lin_cnt < NUMBER_OF_LINES-1 |=> r_lin_cnt - 1 ==
$past(r_lin_cnt)));

REQ_FUNC_INTER_CHECK_02: assert property (p(r_lin_cnt < NUMBER_OF_LINES));

REQ_FUNC_INTER_CHECK_03: assert property (p(w_inc_rx_counter &&
!$past(i_end_cw) && r_lin_cnt == NUMBER_OF_LINES-1 |=> r_lin_cnt == 0 &&
r_col_cnt - 1 == $past(r_col_cnt)));

REQ_FUNC_INTER_CHECK_04: assert property (p(w_inc_rx_counter && $past(i_end_cw)
|=> r_lin_cnt == 0 && r_col_cnt == 0 && r_last_lin == $past(r_lin_cnt) &&
r_last_col == $past(r_col_cnt)));

REQ_FUNC_INTER_CHECK_05: assert property (p(w_inc_tx_counter && r_col_cnt <
w_col_bound |=> r_col_cnt == $past(r_col_cnt) + 1));

let w_next_state = GEN_INT.INTERLEAVER_INST.IC.w_next_state;
let ERROR = 3;
REQ_FUNC_INTER_CHECK_06: assert property (p(w_next_state != ERROR |-> r_col_cnt <
$ceil(real'(NUMBER_OF_ELEMENTS)/real'(NUMBER_OF_LINES))));

REQ_FUNC_INTER_CHECK_07: assert property (p(o_valid |-> r_col_cnt <=
r_last_col));

REQ_FUNC_INTER_CHECK_08: assert property (p(w_inc_tx_counter && r_col_cnt ==
w_col_bound |=> r_col_cnt == 0 &&  r_lin_cnt - 1 == $past(r_lin_cnt)));

REQ_FUNC_INTER_CHECK_09: assert property (p(o_valid && r_lin_cnt <= r_last_lin
|-> w_col_bound == r_last_col));

REQ_FUNC_INTER_CHECK_10: assert property (p(o_valid && r_lin_cnt > r_last_lin
|-> w_col_bound == r_last_col - 1));

REQ_FUNC_INTER_CHECK_11: assert property (p($past(o_end_cw) &&
$past(i_consume) && !$past(i_valid) |=> r_lin_cnt == 0 && r_col_cnt == 0 &&
r_last_lin == 0 && r_last_col == 0));
endmodule
