library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;

use work.block_interleaver_components.m2D_index_counter_core;

use work.generic_components.comparator;

use work.generic_functions.ceil_division;
use work.generic_functions.get_log_round;
use work.generic_functions.max;

entity simplified_m2D_index_counter is 
	generic (
		
		NUMBER_OF_ELEMENTS : natural;
		
		NUMBER_OF_LINES : natural range 1 to 16
		
		);
	
	port (
	
			clk : in std_logic;								-- system clock

			rst : in std_logic; 								-- system reset
			
			i_en : in std_logic; 			

			o_end_cycle : out std_logic;

			o_lin_counter : out std_logic_vector ((get_log_round(NUMBER_OF_LINES) - 1) downto 0);		-- line counter

			o_column_counter : out std_logic_vector((get_log_round(ceil_division(NUMBER_OF_ELEMENTS,NUMBER_OF_LINES)) - 1) downto 0) 	-- column counter
			
			);
			
end simplified_m2D_index_counter;

architecture dataflow of simplified_m2D_index_counter is

	constant LINE_ADDR_LENGTH : natural := get_log_round(NUMBER_OF_LINES);
	
	constant COLUMN_ADDR_LENGTH : natural := get_log_round(ceil_division(NUMBER_OF_ELEMENTS,NUMBER_OF_LINES));
	
	constant ADDR_LENGTH : natural := max (LINE_ADDR_LENGTH, COLUMN_ADDR_LENGTH);

	signal w_i_clear_line : std_logic;
	
	signal w_o_lin_comp : std_logic;
	
	signal w_lin_counter_temp : std_logic_vector((ADDR_LENGTH - 1) downto 0);
	
	signal w_column_counter_temp : std_logic_vector((ADDR_LENGTH - 1) downto 0);
	
	signal w_lin_counter : std_logic_vector((LINE_ADDR_LENGTH - 1) downto 0);

	signal w_column_counter : std_logic_vector((COLUMN_ADDR_LENGTH - 1) downto 0);
	
	begin
	
		-- comparators
	
		LIN_COMP : comparator
		generic map (WORD_LENGTH => LINE_ADDR_LENGTH)
		port map ( i_r => std_logic_vector (to_unsigned ((NUMBER_OF_LINES - 1), LINE_ADDR_LENGTH)),
					  i => w_lin_counter,
					  lt => open,
					  eq => w_o_lin_comp);
					  
		-- matrix_indexer_incrementer_core inputs
		
		w_i_clear_line <= w_o_lin_comp and i_en;
		
		-- matrix_indexer_incrementer_core
		
		MIIC : m2D_index_counter_core
		generic map (WORD_LENGTH => ADDR_LENGTH)
		port map(clk => clk,
					rst => rst,
					i_clear_line => w_i_clear_line,
					i_clear_column => '0',
					i_inc => i_en,
					i_axis => not (w_o_lin_comp),
					o_lin_counter => w_lin_counter_temp,
					o_column_counter => w_column_counter_temp);
					
		--	matrix_indexer_incrementer_core outputs		
					
		w_lin_counter <= w_lin_counter_temp((LINE_ADDR_LENGTH - 1) downto 0);
		
		w_column_counter <= w_column_counter_temp ((COLUMN_ADDR_LENGTH - 1) downto 0);
		
		-- outputs
		
		o_end_cycle <= w_o_lin_comp;
		
		o_lin_counter <= w_lin_counter;
		
		o_column_counter <= w_column_counter;
		
end dataflow;
	
