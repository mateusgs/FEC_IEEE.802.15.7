library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.BLOCK_INTERLEAVER_COMPONENTS.block_interleaver;
use work.generic_components.sync_ld_dff;
use work.generic_components.up_down_counter;
use work.generic_functions.get_log_round;

entity block_interleaver_func_verification_model is
    generic (
        NUMBER_OF_ELEMENTS : natural := 12;
        NUMBER_OF_LINES : natural := 3;
        WORD_LENGTH : natural := 3;
	COUNTER_LENGTH : natural := get_log_round(NUMBER_OF_ELEMENTS)
    );
    port (
        clk : in std_logic; -- system clock
        rst : in std_logic; -- system reset
        i_consume_int : in std_logic; -- when i_consume is '1', the next data output must be sent
        i_consume_deint : in std_logic; -- when i_consume is '1', the next data output must be sent
        i_end_cw : in std_logic; -- flags the last input data
	i_record : in std_logic;
        i_start_cw : in std_logic; -- flags the first input data
        i_valid : in std_logic;	-- shows if the input data is valid or not
        i_data : in std_logic_vector(WORD_LENGTH-1 downto 0); -- input data
        o_end_cw : out std_logic; -- flags the last output data
        o_error : out std_logic; -- flags that there is an error and that the system must be reseted
        o_in_ready : out std_logic; -- shows that the interleaver can receive data 
        o_start_cw : out std_logic; -- flags the first output data
        o_valid : out std_logic; -- shows if the output data is valid
        o_data : out std_logic_vector(WORD_LENGTH-1 downto 0); -- output data
        o_saved_data : out std_logic_vector(WORD_LENGTH-1 downto 0); -- output data
        o_cnt : out std_logic_vector(COUNTER_LENGTH-1 downto 0) -- output data
    );
end block_interleaver_func_verification_model;

architecture behavioral of block_interleaver_func_verification_model is
        signal w_end_cw : std_logic;
        signal w_start_cw : std_logic;
        signal w_valid : std_logic;
        signal w_data : std_logic_vector(WORD_LENGTH-1 downto 0);
        signal r_record_holder : std_logic;
begin
	INTERLEAVER_INST : block_interleaver	
		generic map (NUMBER_OF_ELEMENTS => NUMBER_OF_ELEMENTS,
			     NUMBER_OF_LINES => NUMBER_OF_LINES,
		 	     WORD_LENGTH => WORD_LENGTH,
			     MODE => false)
		port map(
			clk => clk,
			rst => rst,
			i_consume => i_consume_int,
			i_end_cw => i_end_cw,
			i_start_cw => i_start_cw,
			i_valid => i_valid,
			i_data => i_data,
			o_end_cw => w_end_cw, 
			o_error => open,
			o_in_ready => open,
			o_start_cw => w_start_cw,
			o_valid => w_valid,
			o_data => w_data);
	DEINTERLEAVER_INST : block_interleaver		
		generic map (NUMBER_OF_ELEMENTS => NUMBER_OF_ELEMENTS,
			     NUMBER_OF_LINES => NUMBER_OF_LINES,
		 	     WORD_LENGTH => WORD_LENGTH,
			     MODE => true)
		port map(
			clk => clk,
			rst => rst,
			i_consume => i_consume_deint,
			i_end_cw => w_end_cw,
			i_start_cw => w_start_cw,
			i_valid => w_valid,
			i_data => w_data,
			o_end_cw => open, 
			o_error => open,
			o_in_ready => open,
			o_start_cw => open,
			o_valid => o_valid,
			o_data => o_data);

		RECODER_HOLDER : sync_ld_dff	-- holds the input.
			generic map (
				WORD_LENGTH => 1)
			port map (
				rst => rst,
				clk => clk,
				ld => not r_record_holder,
				i_data(0) => i_record or (not i_valid),
				o_data(0) => r_record_holder);
POSITION_RECORDER : up_down_counter
		generic map (WORD_LENGTH => COUNTER_LENGTH)
		port map(clk => clk,
			 rst => rst,
			 i_dir => o_valid,
			 i_en => o_valid or not r_record_holder,
			 o_counter => o_cnt);
		SYMBOL_RECODER : sync_ld_dff	-- holds the input.
			generic map (
				WORD_LENGTH => WORD_LENGTH)
			port map (
				rst => rst,
				clk => clk,
				ld => not r_record_holder,
				i_data => i_data,
				o_data => o_saved_data);
end behavioral;
