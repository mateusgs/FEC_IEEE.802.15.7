library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.generic_components.comparator;
use work.block_interleaver_components.m2D_index_counter_core;

use work.generic_functions.ceil_division;
use work.generic_functions.get_log_round;
use work.generic_functions.max;

entity m2D_index_counter is 
	generic (
		NUMBER_OF_ELEMENTS : natural;
		NUMBER_OF_LINES : natural range 1 to 16
		);
	port (
		clk : in std_logic;														-- system clock
		rst : in std_logic; 													-- system reset	
		i_wr_rd_status : in std_logic;												-- defines the current status of the interleaver: 0 to write and 1 to read
		i_max_col : in std_logic_vector	((get_log_round(ceil_division(NUMBER_OF_ELEMENTS,NUMBER_OF_LINES)) - 1) downto 0);	-- carries the maximum value for the column counter
		i_en : in std_logic; 													-- enables the load of the line counter and column counter registers
		o_lin_counter : out std_logic_vector ((get_log_round(NUMBER_OF_LINES) - 1) downto 0);				-- line counter
		o_column_counter : out std_logic_vector((get_log_round(ceil_division(NUMBER_OF_ELEMENTS,NUMBER_OF_LINES)) - 1) downto 0) 	-- column counter
		);
			
end m2D_index_counter;

architecture dataflow of m2D_index_counter is

	constant LINE_ADDR_LENGTH : natural := get_log_round(NUMBER_OF_LINES);
	constant COLUMN_ADDR_LENGTH : natural := get_log_round(ceil_division(NUMBER_OF_ELEMENTS,NUMBER_OF_LINES));
	constant ADDR_LENGTH : natural := max (LINE_ADDR_LENGTH, COLUMN_ADDR_LENGTH);
	
	signal w_i_clear_line : std_logic;	-- shows that line counter must be reseted next indexing
	signal w_clear_line : std_logic;	-- input i_clear_line of matrix_indexer_incrementer_core	
	signal w_i_clear_column : std_logic;	-- shows that column counter must be reseted next indexing
	signal w_clear_column : std_logic;	-- input i_clear_column of matrix_indexer_incrementer_core
	signal w_axis : std_logic;			-- selects which axis will be incremented: '0' for lines, '1' for columns
	signal w_o_lin_comp : std_logic;		-- output of line comparator
	signal w_o_col_comp : std_logic;		-- output of column comparator
	signal w_lin_counter_temp : std_logic_vector((ADDR_LENGTH - 1) downto 0);		-- temporary wire for line counter
	signal w_column_counter_temp : std_logic_vector((ADDR_LENGTH - 1) downto 0);	-- temporary wire for column counter
	signal w_lin_counter : std_logic_vector((LINE_ADDR_LENGTH - 1) downto 0);		-- line counter with proper length
	signal w_column_counter : std_logic_vector((COLUMN_ADDR_LENGTH - 1) downto 0);		--column counter with proper length
	
	begin
	
		LIN_COMP : comparator		--line comparator: verifies if current line has reached its maximum value
		generic map (WORD_LENGTH => LINE_ADDR_LENGTH)
		port map ( i_r => std_logic_vector (to_unsigned ((NUMBER_OF_LINES - 1), LINE_ADDR_LENGTH)),
					  i => w_lin_counter,
					  lt => open,
					  eq => w_o_lin_comp);
					 
		COL_COMP : comparator		-- column comparator: verifies if current column has reached its maximum value
		generic map (
			WORD_LENGTH => COLUMN_ADDR_LENGTH)
		port map ( i_r => i_max_col,
					  i => w_column_counter,
					  lt => open,
					  eq => w_o_col_comp);
					  
		
		w_axis <= (not w_o_lin_comp) when (i_wr_rd_status = '0') else w_o_col_comp;	-- selects the reference to w_axis based on the status
		
		w_clear_line <= w_o_lin_comp when (i_wr_rd_status = '0') else '0';			-- selects the reference to w_clear_line based on the status
		
		w_clear_column <= '0' when (i_wr_rd_status = '0') else w_o_col_comp;		-- selects the reference to w_clear_column based on the status
		
		-- matrix_indexer_incrementer_core inputs
		w_i_clear_line <= w_clear_line and i_en;
		w_i_clear_column <= w_clear_column and i_en;
		
		MIIC : m2D_index_counter_core
		generic map (WORD_LENGTH => ADDR_LENGTH)
		port map(clk => clk,
					rst => rst,
					i_clear_line => w_i_clear_line,
					i_clear_column => w_i_clear_column,
					i_inc => i_en,
					i_axis => w_axis,
					o_lin_counter => w_lin_counter_temp,
					o_column_counter => w_column_counter_temp);
					
		
		-- matrix_indexer_incrementer_core outputs					
		w_lin_counter <= w_lin_counter_temp((LINE_ADDR_LENGTH - 1) downto 0);		-- converting ADD_LENGTH to LINE_ADDR_LENGTH
		w_column_counter <= w_column_counter_temp ((COLUMN_ADDR_LENGTH - 1) downto 0);	-- converting ADD_LENGTH to COLUMN_ADDR_LENGTH
		
		-- outputs
		o_lin_counter <= w_lin_counter;
		o_column_counter <= w_column_counter;
		
end dataflow;
	
