library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.generic_components.comparator;
use work.generic_components.sync_ld_dff;
use work.generic_components.up_down_counter;

use work.generic_functions.get_log_round;

entity flag_signals_generator is
	generic (
		NUMBER_OF_ELEMENTS : natural);
		
	port (
		rst : in std_logic;							
		clk : in std_logic;								--Clock signal.
		
		i_end_count : in std_logic;				--Indicates that the last input has been counted.
		i_en : in std_logic;							--Enables the load of the line counter and column counter registers.
		i_wr_rd_status : in std_logic;			--Defines the current status of the block.
		
		o_full_ram : out std_logic;			--Represent that the ram has reached its limit. 
		o_first_out : out std_logic;			--Represents that the first output has been sent.
		o_last_out : out std_logic;			--Represents that the last output has been sent.
	
		o_counter : out std_logic_vector (get_log_round(NUMBER_OF_ELEMENTS+1) - 1 downto 0));
end flag_signals_generator;

architecture structure_fsg1 of flag_signals_generator is

   constant RAM_ADDR_LENGTH_1 : natural := get_log_round(NUMBER_OF_ELEMENTS+1);

	signal r_element_counter : std_logic_vector (RAM_ADDR_LENGTH_1 - 1 downto 0); --Shows the number of symbols in the ram plus 1.
	signal r_ram_max : std_logic_vector (RAM_ADDR_LENGTH_1 - 1 downto 0);		--Indicates the maximum number of elements written in the ram minus 1 during one cycle
	
	begin
		
		COMP4 : comparator
			generic map(WORD_LENGTH => RAM_ADDR_LENGTH_1)
			port map(i_r => r_ram_max,
						i => r_element_counter,
						lt => open,
						eq => o_first_out);
						
		COMP5 : comparator										--Checks if the ram has reachead its maximum capacity.
			generic map(WORD_LENGTH => RAM_ADDR_LENGTH_1)
			port map(i_r => (std_logic_vector (to_unsigned ((NUMBER_OF_ELEMENTS), RAM_ADDR_LENGTH_1))),
						i => r_element_counter,
						lt => open,
						eq => o_full_ram);
						
		COMP6 : comparator
			generic map(WORD_LENGTH => RAM_ADDR_LENGTH_1)	--Checks if the last data package is about to be sent.
			port map(i_r => (std_logic_vector (to_unsigned (1, RAM_ADDR_LENGTH_1))),
						i => r_element_counter,
						lt => open,
						eq => o_last_out);	
	
		REG6 : sync_ld_dff	--Holds the maximum number of elements written in the ram minus 1 during one cycle.
			generic map (
				WORD_LENGTH => RAM_ADDR_LENGTH_1)
			port map (
				rst => rst,
				clk => clk,
				ld => i_end_count,
				i_data => r_element_counter,
				o_data => r_ram_max);
				
		UDC0 : up_down_counter		--Counts the data flux in the ram.
			generic map(WORD_LENGTH => RAM_ADDR_LENGTH_1)
			port map ( clk => clk,
						  rst => rst,
						  i_dir => i_wr_rd_status,
						  i_en => i_en,
						  o_counter => r_element_counter);
						  
		o_counter <= r_element_counter;

end structure_fsg1;
