library IEEE;
--review: Mantenha os includes dos pacotes ordenados por ordem alfab�tica.
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.block_interleaver_components.flag_signals_generator;
use work.block_interleaver_components.simplified_m2D_index_counter;
use work.block_interleaver_components.wr_rd_status_selector;

use work.generic_components.adder;
use work.generic_components.comparator;
use work.generic_components.incrementer;
use work.generic_components.sync_ld_dff;
use work.generic_components.single_port_linear_ram;

use work.generic_functions.ceil_division;
use work.generic_functions.get_log_round;
use work.generic_functions.max;

entity deinterleaver_data_path is
	generic (
		--review: porque o valor default � 20? Pode deixar ele indefinido.
		NUMBER_OF_ELEMENTS : natural := 12;
   	NUMBER_OF_LINES : natural := 3;
		WORD_LENGTH : natural := 3);
		
	port (
		--review: Olhe tamb�m os coment�rios do c�digo. Quando tem que comentar muito que dizer que pode ter algo errado: Estrutura da interface,
		--nome dos sinais ou coment�rio redundante. 

		rst : in std_logic;								--Resets the line counter and column counter registers. Also changes to write mode.
		--review: coment�rio redundante
		clk : in std_logic;								--Clock signal.
		--review: normalmente sempre tem um sinal "rst" para a interfaces de data path. Esse seria o reset do sistema,
		--que � ativado toda vez que o block � "ligado". Seria o rst_indexer?

		i_start_rd_mode : in std_logic;				--Changes the status of FSM to read mode.
		i_en : in std_logic;								--Enables the load of the line counter and column counter registers.
--		i_ram_wr_en : in std_logic;					--Enables the ram.
		
		--review: coment�rio redundante
		i_data : in std_logic_vector ((WORD_LENGTH - 1) downto 0); --Data input.
		
		o_full_ram : out std_logic;			--Represent that the ram has reached its limit. 
		o_first_out : out std_logic;			--Represents that the first output has been sent.
		--review: O �ltimo dado � enviado quando a RAM est� vazia, n�o? --N�o, esse sinal serve para informar a controladora que ela deve mudar para o est�gio last output
		o_last_out : out std_logic;						--Represents that the last output has been sent.
		
		--review: coment�rio redundante
		o_data : out std_logic_vector ((WORD_LENGTH -1 ) downto 0));	--Data output.	
		
		
end deinterleaver_data_path;

--review: o que significa structure_idp? H� algum nome mais simples para isso? =Structure => Structural architecture. IDP => Interleaver Data Path.
architecture structure_ddp of deinterleaver_data_path is

	constant LINE_ADDR_LENGTH : natural := get_log_round(NUMBER_OF_LINES);
	
	constant COLUMN_ADDR_LENGTH : natural := get_log_round(ceil_division(NUMBER_OF_ELEMENTS,NUMBER_OF_LINES));
	
	constant ADDR_LENGTH : natural := max (LINE_ADDR_LENGTH, COLUMN_ADDR_LENGTH);

	constant RAM_ADDR_LENGTH : natural := get_log_round(NUMBER_OF_ELEMENTS);
	
	signal w_wr_increment : std_logic;
	signal w_rd_increment : std_logic;
	signal w_wr_rd_status : std_logic;
	signal w_not_wr_rd_st : std_logic;
	signal w_select_amount : std_logic;
	signal w_ram_wr_en : std_logic;
	signal w_end_cycle : std_logic;
	signal w_indexer_rst : std_logic;
	
	signal r_ram_data : std_logic_vector ((WORD_LENGTH - 1) downto 0);
	
	signal w_iteration : std_logic_vector ((LINE_ADDR_LENGTH - 1) downto 0);
	signal r_last_lin : std_logic_vector ((LINE_ADDR_LENGTH - 1) downto 0);
	signal r_lin_counter : std_logic_vector ((LINE_ADDR_LENGTH - 1) downto 0);
	
	signal r_last_col : std_logic_vector ((COLUMN_ADDR_LENGTH - 1) downto 0);
	signal r_last_col_concat : std_logic_vector (COLUMN_ADDR_LENGTH downto 0);
	signal w_sweep : std_logic_vector ((COLUMN_ADDR_LENGTH - 1) downto 0);	
	signal r_col_counter : 	std_logic_vector ((COLUMN_ADDR_LENGTH - 1) downto 0);
	signal r_last_col_1 : std_logic_vector (COLUMN_ADDR_LENGTH downto 0);
		
	signal r_counter : std_logic_vector ((RAM_ADDR_LENGTH - 1) downto 0);
	signal w_sweep_1 : std_logic_vector ((RAM_ADDR_LENGTH - 1) downto 0);	
	signal w_jump_amount : std_logic_vector ((RAM_ADDR_LENGTH - 1) downto 0);
	signal w_ram_addr : std_logic_vector ((RAM_ADDR_LENGTH - 1) downto 0);
	signal w_next_index : std_logic_vector ((RAM_ADDR_LENGTH - 1) downto 0);
	signal r_indexer : std_logic_vector ((RAM_ADDR_LENGTH - 1) downto 0);
	signal w_sum_result : std_logic_vector ((RAM_ADDR_LENGTH - 1) downto 0);
		
	
	begin
		
	----------------------ADDER-----------------------
	--Adds the current index with the jump-amount to--
	--calculate the  next index. The  jump amount is--
	--defined according to the last line.-------------
	
		ADR0 : adder
			generic map (
				WORD_LENGTH => RAM_ADDR_LENGTH)
			port map (
				i0 => r_indexer,
				i1 => w_jump_amount,
				o => w_sum_result,
				co => open);
	
	--Logic   gates:  AND   and  NOT.  Setting   the--
	--increment  signal  for   the  write  and  read--
	--situations.-------------------------------------
	
		w_rd_increment <= w_wr_rd_status AND i_en;
	
	--------------------------------------------------
	
	w_indexer_rst <= rst or i_start_rd_mode;
	
	--------------------------------------------------
	
		w_sweep <= r_col_counter;
		w_iteration <= r_lin_counter;
					
	--------------------COMPARATOR--------------------
	--Compares whether the iteration is greater than--
	--the  last line for  selecting the  jump-amount--
	--the indexer.------------------------------------
	
		COMP0 : comparator
			generic map (
				WORD_LENGTH => LINE_ADDR_LENGTH)
			port map (
				i_r => w_iteration,
				i => r_last_lin,
				lt => w_select_amount,
				eq => open);
				
	-----------------------FLAGS----------------------
	--Generates the one-bit  output signals required--
	--by  the  controller  and   counts  the  data  --
	--received.---------------------------------------
		
		FSG1 : flag_signals_generator
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
				o_counter => r_counter);
				
	-------------------INCREMENTERS-------------------
	--Calculates the last column plus 1 for the jump--
	--amount.-----------------------------------------
	r_last_col_concat(COLUMN_ADDR_LENGTH) <= '0';
	r_last_col_concat(COLUMN_ADDR_LENGTH-1 downto 0) <= r_last_col;
		INC0 : incrementer
			generic map (WORD_LENGTH => COLUMN_ADDR_LENGTH+1)
			port map	(i => r_last_col_concat,
						 o => r_last_col_1,
						 co => open);
						 
	--Calculates  the sweep  plus  1 to  be used  as--
	--indexer of each firts iteration of the sweeps.--
		
		INC1 : incrementer
			generic map (WORD_LENGTH => COLUMN_ADDR_LENGTH)
			port map	(i => w_sweep,
						 o => w_sweep_1 ((COLUMN_ADDR_LENGTH - 1) downto 0),
						 co => open);
						 
		w_sweep_1 ((RAM_ADDR_LENGTH - 1) downto COLUMN_ADDR_LENGTH) <= (others => '0');
						 
	---------------INDEXER_INCREMENTERS---------------
	--Computes  the last  line  and the last  column--
	--during the writing process.---------------------
	
		MII0 : simplified_m2D_index_counter
			generic map (
				NUMBER_OF_ELEMENTS => NUMBER_OF_ELEMENTS,
				NUMBER_OF_LINES => NUMBER_OF_LINES)
			port map (
				clk => clk,
				rst => w_indexer_rst,
				i_en => i_en,
				o_end_cycle => w_end_cycle,
				o_lin_counter => r_lin_counter,
				o_column_counter => r_col_counter
				);
				
	-----------------------MUXES----------------------
	--Selects the indexer of each process (write and--
	--read).------------------------------------------

		w_ram_addr <= r_indexer when (w_ram_wr_en = '0') else
						  r_counter;
					  
	--Selects   the  jump-amount  of  the   indexer.--
	
		w_jump_amount (COLUMN_ADDR_LENGTH downto 0) <= r_last_col_1 when (w_select_amount = '0') else
																			  r_last_col_concat;
																			  
		w_jump_amount ((RAM_ADDR_LENGTH - 1) downto COLUMN_ADDR_LENGTH+1) <= (others => '0');
								
	--Selects  the  indexer  input in  each  process--
	--(iteration and next-sweep).---------------------
	
		w_next_index <= w_sum_result when (w_end_cycle = '0') else
							 w_sweep_1;
						 
	------------------------RAM-----------------------
	--Stores the data.--------------------------------
	
		SPR0 : single_port_linear_ram
			generic map (
				NUMBER_OF_ELEMENTS => NUMBER_OF_ELEMENTS,
				WORD_LENGTH => WORD_LENGTH)
		
			port map (
				clk => clk,
				i_ram_data => r_ram_data,
				i_ram_wr_en => w_ram_wr_en,
				i_ram_addr => w_ram_addr,
				o_ram_data => o_data
			);
			
	---------------------REGISTERS--------------------
	--Holds the input for a period of clock.----------
	
		REG0 : sync_ld_dff
			generic map (
				WORD_LENGTH => WORD_LENGTH)
			port map (
				rst => '0',
				clk => clk,
				ld => '1',
				i_data => i_data,
				o_data => r_ram_data);
				
	--Keeps track of the index while reading.---------
	
		REG1 : sync_ld_dff
			generic map (
				WORD_LENGTH => RAM_ADDR_LENGTH)
			port map (
				rst => rst,
				clk => clk,
				ld => w_rd_increment,
				i_data => w_next_index,
				o_data => r_indexer);
	
	-- Stores last line. -----------------------------

		REG2 : sync_ld_dff
			generic map (
				WORD_LENGTH => LINE_ADDR_LENGTH)
			port map (
				rst => rst,
				clk => clk,
				ld => i_start_rd_mode,
				i_data => r_lin_counter,
				o_data => r_last_lin);

	-- Stores last column. -----------------------------

		REG3 : sync_ld_dff
			generic map (
				WORD_LENGTH => COLUMN_ADDR_LENGTH)
			port map (
				rst => rst,
				clk => clk,
				ld => i_start_rd_mode,
				i_data => r_col_counter,
				o_data => r_last_col);
								
	-----------------------STATUS---------------------
	--Sets  the status of  the data  path (write  or--
	--read).------------------------------------------
	
		WRS0 : wr_rd_status_selector
			port map (
				rst => rst,
				clk => clk,
				i_start_rd_mode => i_start_rd_mode,
				i_en => i_en,
				o_wr_rd_status => w_wr_rd_status,
				o_ram_wr_en => w_ram_wr_en);
	
	--------------------------------------------------
		
end structure_ddp;
