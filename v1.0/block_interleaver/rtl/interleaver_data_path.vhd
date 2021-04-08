library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.block_interleaver_components.flag_signals_generator;
use work.block_interleaver_components.m2D_index_counter;
use work.block_interleaver_components.wr_rd_status_selector;

use work.generic_components.comparator;
use work.generic_components.decrementer;
use work.generic_components.sync_ld_dff;
use work.generic_components.single_port_2D_ram;


use work.generic_functions.ceil_division;
use work.generic_functions.get_log_round;
use work.generic_functions.max;

entity interleaver_data_path is
	generic (
		NUMBER_OF_ELEMENTS : natural := 12;
   	NUMBER_OF_LINES : natural := 3;
		WORD_LENGTH : natural := 3);
		
	port (

		rst : in std_logic;								-- system reset
		clk : in std_logic;								-- system clock
		i_start_rd_mode : in std_logic;						-- changes the status to read mode when set
		i_en : in std_logic;							-- enables the load of the line counter and column counter registers
		i_data : in std_logic_vector ((WORD_LENGTH - 1) downto 0);			-- data input
		o_full_ram : out std_logic;						-- shows that ram has reached its limit
		o_first_out : out std_logic;						-- shows that the first output will be sent
		o_last_out : out std_logic;							-- shows that the last output will be sent	
		o_data : out std_logic_vector ((WORD_LENGTH -1 ) downto 0));		-- data output
				
end interleaver_data_path;

architecture structure_idp of interleaver_data_path is
		
	--w_.. para wire
	--r_.. para sa�da de m�moria/registradores
	--c_.. para constantes.
	
	constant LINE_ADDR_LENGTH : natural := get_log_round(NUMBER_OF_LINES);
	constant COLUMN_ADDR_LENGTH : natural := get_log_round(ceil_division(NUMBER_OF_ELEMENTS,NUMBER_OF_LINES));
	constant ADDR_LENGTH : natural := max (LINE_ADDR_LENGTH, COLUMN_ADDR_LENGTH);
	constant RAM_ADDR_LENGTH : natural := get_log_round(NUMBER_OF_ELEMENTS);
	
	signal w_rst_indexer : std_logic;		-- resets matrix_indexer_incrementer_core
	signal w_wr_rd_status : std_logic;							-- wire that defines the current status of the interleaver: 0 to write and 1 to read
	signal w_ram_wr_en : std_logic;							-- enables writing in ram
	signal w_comp_2 : std_logic;							-- wires from the output of the comparators 0 to 7. 8 is the NOT of 1
	signal r_last_col : std_logic_vector ((COLUMN_ADDR_LENGTH - 1) downto 0);		-- last column index
	signal r_col_cnt : std_logic_vector ((COLUMN_ADDR_LENGTH - 1) downto 0);		-- output of the column counter register
	signal w_mux3 : std_logic_vector ((COLUMN_ADDR_LENGTH - 1) downto 0);		-- output of the third mux (0)last column 1)last column minus 1)
	signal r_last_col_1 : std_logic_vector ((COLUMN_ADDR_LENGTH - 1) downto 0);	-- last column index minus 1
	signal r_last_lin : std_logic_vector ((LINE_ADDR_LENGTH - 1) downto 0);		-- last line index
	signal r_lin_cnt : std_logic_vector ((LINE_ADDR_LENGTH - 1) downto 0);		-- output of the line counter register
	signal r_ram_data : std_logic_vector ((WORD_LENGTH - 1) downto 0);		-- signal containing the input of the ram
	
	begin		
		
		COMP2 : comparator	-- compares whether the last line written is littler than the current line.
			generic map (
				WORD_LENGTH => LINE_ADDR_LENGTH)
			port map (
				i_r => r_lin_cnt,
				i => r_last_lin,
				lt => w_comp_2,
				eq => open);
				
	
		w_mux3 <= r_last_col when (w_comp_2 = '0') else		-- selects the reference for the last column.
					 r_last_col_1;			 
								
		DEC0 : decrementer	 -- Calculates the last column minus 1.
			generic map (
				WORD_LENGTH => COLUMN_ADDR_LENGTH)
			port map (
				i => r_last_col,
				o => r_last_col_1,
				co => open);
		
		FSG0 : flag_signals_generator		--  sets o_full_ram, o_first_out and o_last_out when needed
			generic map (
				NUMBER_OF_ELEMENTS => NUMBER_OF_ELEMENTS)
			port map (
				rst => rst,							
				clk => clk,
				i_end_count => i_start_rd_mode,
				i_en => i_en,
				i_wr_rd_status => w_wr_rd_status,
				o_full_ram => o_full_ram, 
				o_first_out => o_first_out,
				o_last_out => o_last_out,
				o_counter => open);
		
		REG3 : sync_ld_dff	-- holds the last line written.
			generic map (
				WORD_LENGTH => LINE_ADDR_LENGTH)
			port map (
				rst => rst,
				clk => clk,
				ld => i_start_rd_mode,
				i_data => r_lin_cnt,
				o_data => r_last_lin);
				
		REG4 : sync_ld_dff	-- holds the last column written.
			generic map (
				WORD_LENGTH => COLUMN_ADDR_LENGTH)
			port map (
				rst => rst,
				clk => clk,
				ld => i_start_rd_mode,
				i_data => r_col_cnt,
				o_data => r_last_col);				
			
		REG5 : sync_ld_dff	-- holds the input.
			generic map (
				WORD_LENGTH => WORD_LENGTH)
			port map (
				rst => '0',
				clk => clk,
				ld => '1',
				i_data => i_data,
				o_data => r_ram_data);
				
		w_rst_indexer <= rst OR i_start_rd_mode;
		
		M2D0 :	m2D_index_counter			-- includes the counters that indicate the current line and the current column
			generic map (
				NUMBER_OF_ELEMENTS => NUMBER_OF_ELEMENTS,
				NUMBER_OF_LINES => NUMBER_OF_LINES)
			port map (
				clk => clk,
				rst => w_rst_indexer,
				i_wr_rd_status => w_wr_rd_status,
				i_max_col => w_mux3,
				i_en => i_en,
				o_lin_counter => r_lin_cnt,
				o_column_counter => r_col_cnt);
					
		SPR0 : single_port_2D_ram	-- holds the data that would be shuffled.
			generic map (
				NUMBER_OF_ELEMENTS => NUMBER_OF_ELEMENTS,
				NUMBER_OF_LINES => NUMBER_OF_LINES,
				WORD_LENGTH => WORD_LENGTH)
			port map (
				clk => clk,
				i_ram_data => r_ram_data,
				i_ram_wr_en => w_ram_wr_en,
				i_lin_addr => r_lin_cnt,
				i_col_addr => r_col_cnt,
				o_ram_data => o_data);

		WRSS0 : wr_rd_status_selector		-- sets w_wr_rd_status and w_ram_wr_en when needed
			port map (
				rst => rst,
				clk => clk,
				i_start_rd_mode => i_start_rd_mode,
				i_en => i_en,
				o_wr_rd_status => w_wr_rd_status,
				o_ram_wr_en => w_ram_wr_en);			
		
end structure_idp;
