-- matrix_indexer_incrementer
-- component that increments line and column counters

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.generic_components.incrementer;
use work.generic_components.sync_ld_dff;

entity m2D_index_counter_core is
	generic(
		WORD_LENGTH : natural := 4
	);
	port (
			clk : in std_logic;								-- system clock
			rst : in std_logic; 								-- system reset
			i_clear_line : in std_logic;					-- sets line counter to zero when set
			i_clear_column : in std_logic; 				-- sets column counter to zero when set
			i_inc : in std_logic; 							-- increments counters when set
			i_axis : in std_logic; 							-- selects which axis will be incremented: '0' for lines, '1' for columns
			o_lin_counter : out std_logic_vector (WORD_LENGTH - 1 downto 0);		-- line counter
			o_column_counter : out std_logic_vector (WORD_LENGTH - 1 downto 0)); 	-- column counter 	
end m2D_index_counter_core;

architecture dataflow of m2D_index_counter_core is

	-----------------------------------
	-- internal signals:

	-- load signals for line and column registers
	signal w_ld_reg_lin : std_logic;
	signal w_ld_reg_column : std_logic;
    
	-- reset signals for line and column registers
	signal w_rst_reg_lin : std_logic;
   signal w_rst_reg_column : std_logic;
    
        -- input and output signals of the incrementer component
   signal w_i_incrementer : std_logic_vector(WORD_LENGTH - 1 downto 0);
   signal w_o_incrementer : std_logic_vector(WORD_LENGTH - 1 downto 0);
    
        -- signals for line and column counters (outputs of line and column registers)
   signal r_lin_counter : std_logic_vector(WORD_LENGTH - 1 downto 0);
   signal r_column_counter : std_logic_vector(WORD_LENGTH - 1 downto 0);

	------------------------------------
	
	begin
	
		-- selects incrementer input
		w_i_incrementer <= r_column_counter when (i_axis = '0') else
								 r_lin_counter;	
	
		-- increments line counter or column counter        
		incrementer0 : incrementer
        	generic map (WORD_LENGTH => WORD_LENGTH)
        	port map	(i => w_i_incrementer,
						 o => w_o_incrementer,
						 co => open);  
	  
		-- load and reset signals for line register
			w_ld_reg_lin <= i_inc and i_axis;
			w_rst_reg_lin <= rst or i_clear_line;

		-- line register
		reg_lin : sync_ld_dff 
			generic map (WORD_LENGTH => WORD_LENGTH)
			port map (rst => w_rst_reg_lin,
                   clk => clk,
                   ld => w_ld_reg_lin,
                   i_data => w_o_incrementer,
                   o_data => r_lin_counter);
	   
		-- define output o_lin_counter	
		o_lin_counter <= r_lin_counter;
        
		-- load and reset signals for column register
      w_ld_reg_column <= i_inc and not (i_axis);
		w_rst_reg_column <= rst or i_clear_column;

		-- column register               
		reg_column : sync_ld_dff 
        	generic map (WORD_LENGTH => WORD_LENGTH)
        	port map (rst => w_rst_reg_column,
                   clk => clk,
                   ld => w_ld_reg_column,
                   i_data => w_o_incrementer,
                   o_data => r_column_counter);
	
		-- define output o_column_counter        
		o_column_counter <= r_column_counter;	

end dataflow;
     
