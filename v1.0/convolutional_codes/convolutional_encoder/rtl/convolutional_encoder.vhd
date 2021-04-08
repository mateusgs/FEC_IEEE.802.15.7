library IEEE;
	use IEEE.numeric_std.all;
	use IEEE.std_logic_1164.all;
	
library work;
	use work.GENERIC_TYPES.integer_array;
	use work.GENERIC_FUNCTIONS.get_log_round;
	use work.GENERIC_COMPONENTS.comparator;
	use work.GENERIC_COMPONENTS.sync_ld_dff;
	use work.GENERIC_COMPONENTS.up_counter;
	use work.convolutional_encoder_components.conv_flop_cascade;

entity convolutional_encoder is
	generic (
		CASCADE_LENGTH : natural := 7;
		GENERATOR_POLY : integer_array (2 downto 0) := (91, 121, 117);
      --GENERATOR_POLY: array_of_integers(RATE-1 downto 0)
      --This is because Quartus compiler does not support using generic terms
      --to define other generic terms. So, for this case, it will be considered
      --the first 'k' terms of generator poly where 'k' = RATE.        
      RATE : integer := 3);
	port (
		clk : in std_logic;
      rst : in std_logic;
		i_consume : in std_logic;
      i_data : in std_logic;
		i_last_data : in std_logic;
		i_valid : in std_logic;
		o_in_ready : out std_logic;
		o_last_data : out std_logic;
		o_valid : out std_logic;
      o_data : out std_logic_vector((RATE - 1) downto 0));
end convolutional_encoder;

architecture structure_ce of convolutional_encoder is
   	
	signal w_data : std_logic;
	signal w_en_inc : std_logic;
	signal w_en_shift : std_logic;
	signal w_end_cnt : std_logic;
	signal w_inc_0 : std_logic;
	signal w_inc_1 : std_logic;
	signal w_inc_cnt : std_logic;
	signal w_rst_inc : std_logic;	
	signal w_counter : std_logic_vector ((get_log_round (CASCADE_LENGTH - 2) - 1) downto 0);

	begin
	
		o_in_ready <= NOT (w_inc_cnt) AND i_consume AND NOT (rst);
		o_last_data <= w_end_cnt;
		o_valid <= (w_inc_cnt OR i_valid) AND NOT (rst);
		w_inc_0 <= i_valid AND i_consume;
		w_inc_1 <= w_inc_cnt AND i_consume;
		w_en_inc <= i_last_data AND w_inc_0;
		w_en_shift <= w_inc_0 OR w_inc_1;
		w_rst_inc <= rst OR (w_end_cnt AND i_consume);
		w_data <= i_data when w_inc_cnt = '0' else
					 '0';
					 
		FLC0 : conv_flop_cascade
			generic map (
				CASCADE_LENGTH => CASCADE_LENGTH,				
				GENERATOR_POLY => GENERATOR_POLY,
				RATE => RATE)
			port map (
				clk => clk,
				rst => rst,
				i_consume => w_en_shift,
				i_data => w_data,		
				o_data => o_data);
				
		UPC0 : up_counter
			generic map (
				WORD_LENGTH => get_log_round (CASCADE_LENGTH - 2))
			port map ( 
				clk => clk,
				rst => w_rst_inc,
				i_inc => w_inc_1, 
				o_counter => w_counter);
				
		COMP0 : comparator
			generic map (
				WORD_LENGTH => get_log_round (CASCADE_LENGTH - 2))
			port map (
				i_r => std_logic_vector (to_unsigned ((CASCADE_LENGTH - 2), get_log_round (CASCADE_LENGTH - 1))),
				i => w_counter,
				lt => open,
				eq => w_end_cnt);
				
		SLD0 : sync_ld_dff 
			generic map (WORD_LENGTH => 1) 
			port map (
				rst => w_rst_inc,
				clk => clk,
				ld => w_en_inc,
				i_data (0) => '1',
				o_data (0) => w_inc_cnt);

end structure_ce;