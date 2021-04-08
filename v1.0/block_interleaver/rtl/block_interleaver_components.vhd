library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.generic_functions.ceil_division;
use work.generic_functions.get_log_round;

package BLOCK_INTERLEAVER_COMPONENTS is
component block_interleaver is
    generic (
        NUMBER_OF_ELEMENTS : natural := 12;
        NUMBER_OF_LINES : natural := 3;
        WORD_LENGTH : natural := 3;
	MODE : boolean := false -- INTERLEAVER=false and DEINTERLEAVER=true
    );
    port (
        clk : in std_logic; -- system clock
        rst : in std_logic; -- system reset
        i_consume : in std_logic; -- when i_consume is '1', the next data output must be sent
        i_end_cw : in std_logic; -- flags the last input data
        i_start_cw : in std_logic; -- flags the first input data
        i_valid : in std_logic;	-- shows if the input data is valid or not
        i_data : in std_logic_vector(WORD_LENGTH-1 downto 0); -- input data
        o_end_cw : out std_logic; -- flags the last output data
        o_error : out std_logic; -- flags that there is an error and that the system must be reseted
        o_in_ready : out std_logic; -- shows that the interleaver can receive data 
        o_start_cw : out std_logic; -- flags the first output data
        o_valid : out std_logic; -- shows if the output data is valid
        o_data : out std_logic_vector(WORD_LENGTH-1 downto 0) -- output data
    );
end component;

component rectangular_deinterleaver is
    generic (
        NUMBER_OF_ELEMENTS : natural := 12;
        NUMBER_OF_LINES : natural := 3;
        WORD_LENGTH : natural := 3
    );
    port (
        clk : in std_logic;												-- system clock
        rst : in std_logic;												-- system reset
        i_consume : in std_logic;										-- when i_consume is '1', the next data output must be sent
        i_end_interleaver : in std_logic;								-- flags the last input data
        i_start_interleaver : in std_logic;							-- flags the first input data
        i_valid : in std_logic;											-- shows if the input data is valid or not
        i_data : in std_logic_vector(WORD_LENGTH-1 downto 0);	-- input data
        o_end_interleaver : out std_logic;							-- flags the last output data
        o_error : out std_logic;											-- flags that there is an error and that the system must be reseted
        o_in_ready : out std_logic;										-- shows that the interleaver can receive data 
        o_start_interleaver : out std_logic;							-- flags the first output data
        o_valid : out std_logic;											-- shows if the output data is valid
        o_data : out std_logic_vector(WORD_LENGTH-1 downto 0)	-- output data
    );
end component;
component rectangular_interleaver is
	generic (
		NUMBER_OF_ELEMENTS : natural := 12;
		NUMBER_OF_LINES : natural := 3;
		WORD_LENGTH : natural := 3
	);
	port (
		clk : in std_logic;						-- system clock
		rst : in std_logic;						-- system reset
		i_consume : in std_logic;					-- asks for the next output data
		i_end_interleaver : in std_logic;				-- flags last input data
		i_start_interleaver : in std_logic;				-- flags first input data
		i_valid : in std_logic;					-- shows if the input data is valid or not
		i_data : in std_logic_vector(WORD_LENGTH-1 downto 0);	-- input data
		o_end_interleaver : out std_logic;				-- flags last output data
		o_error : out std_logic;					-- warns that there is an error and that the system must be reseted
		o_in_ready : out std_logic;				-- shows that the interleaver is ready to receive data
		o_start_interleaver : out std_logic;				-- flags first output data
		o_valid : out std_logic;					-- shows if the output data is valid
		o_data : out std_logic_vector(WORD_LENGTH-1 downto 0)	-- output data
	);
end component;

component m2D_index_counter is 
	generic (
		NUMBER_OF_ELEMENTS : natural;
		NUMBER_OF_LINES : natural range 1 to 16
	);
	port (
		clk : in std_logic;								
		rst : in std_logic; 				
		i_wr_rd_status : in std_logic;
		i_max_col : in std_logic_vector	((get_log_round(ceil_division(NUMBER_OF_ELEMENTS,NUMBER_OF_LINES)) - 1) downto 0);
		i_en : in std_logic; 							
		o_lin_counter : out std_logic_vector ((get_log_round(NUMBER_OF_LINES) - 1) downto 0);		
		o_column_counter : out std_logic_vector((get_log_round(ceil_division(NUMBER_OF_ELEMENTS,NUMBER_OF_LINES)) - 1) downto 0) 	
	);
end component;	

component m2D_index_counter_core is
	generic(
		WORD_LENGTH : natural
	);
	port (
		clk : in std_logic;								
		rst : in std_logic; 								
		i_clear_line : in std_logic;					
		i_clear_column : in std_logic; 				
		i_inc : in std_logic; 							
		i_axis : in std_logic; 							
		o_lin_counter : out std_logic_vector (WORD_LENGTH - 1 downto 0);		
		o_column_counter : out std_logic_vector (WORD_LENGTH - 1 downto 0)
	);
end component;

component wr_rd_status_selector is
	port (
		rst : in std_logic;							
		clk : in std_logic;							
		i_start_rd_mode : in std_logic;			
		i_en : in std_logic;							
		o_wr_rd_status : out std_logic;			
		o_ram_wr_en : out std_logic
	);				
end component;

component flag_signals_generator is
	generic (
		NUMBER_OF_ELEMENTS : natural);
		
	port (
		rst : in std_logic;							
		clk : in std_logic;				--Clock signal.
		
		i_end_count : in std_logic;				--Indicates that the last input has been counted.
		i_en : in std_logic;							--Enables the load of the line counter and column counter registers.
		i_wr_rd_status : in std_logic;			--Defines the current status of the block.
		
		o_full_ram : out std_logic;			--Represent that the ram has reached its limit. 
		o_first_out : out std_logic;			--Represents that the first output has been sent.
		o_last_out : out std_logic;			--Represents that the last output has been sent.
	
		o_counter : out std_logic_vector (get_log_round(NUMBER_OF_ELEMENTS+1) - 1 downto 0));	
end component;

component simplified_m2D_index_counter is 
	generic (
		NUMBER_OF_ELEMENTS : natural;
		NUMBER_OF_LINES : natural range 1 to 16
		);
	port (
		clk : in std_logic;								
		rst : in std_logic;
		i_en : in std_logic;
		o_end_cycle : out std_logic;
		o_lin_counter : out std_logic_vector ((get_log_round(NUMBER_OF_LINES) - 1) downto 0);		
		o_column_counter : out std_logic_vector((get_log_round(ceil_division(NUMBER_OF_ELEMENTS,NUMBER_OF_LINES)) - 1) downto 0) 	
	);
end component;	

component deinterleaver_data_path is
	generic (
		NUMBER_OF_ELEMENTS : natural;
   	NUMBER_OF_LINES : natural;
		WORD_LENGTH : natural);
	port (
		rst : in std_logic;								
		clk : in std_logic;								
		i_start_rd_mode : in std_logic;				
		i_en : in std_logic;										
		i_data : in std_logic_vector ((WORD_LENGTH - 1) downto 0); 
		o_full_ram : out std_logic;		
		o_first_out : out std_logic;			
		o_last_out : out std_logic;						
		o_data : out std_logic_vector ((WORD_LENGTH -1 ) downto 0));	
end component;

component interleaver_controller is
	port (
		clk : in std_logic;
		rst : in std_logic;
		i_start_interleaver : in std_logic;		
		i_valid : in std_logic;						
		i_end_interleaver : in std_logic;		
		i_consume : in std_logic;					
		i_full_ram : in std_logic;					
		i_first_out : in std_logic;				
		i_last_out : in std_logic;					
		o_rst_indexer : out std_logic;			
		o_start_rd_mode : out std_logic;			
		o_en : out std_logic;						
		o_end_interleaver : out std_logic;		
		o_error : out std_logic;								
		o_in_ready : out std_logic;				
		o_start_interleaver : out std_logic;	
		o_valid : out std_logic);					
end component;

component interleaver_data_path is
	generic (
		NUMBER_OF_ELEMENTS : natural;
		NUMBER_OF_LINES : natural range 1 to 16;
		WORD_LENGTH : natural);
	port (
		rst : in std_logic;								
		clk : in std_logic;								
		i_start_rd_mode : in std_logic;				
		i_en : in std_logic;										
		i_data : in std_logic_vector ((WORD_LENGTH - 1) downto 0); 
		o_full_ram : out std_logic;		
		o_first_out : out std_logic;			
		o_last_out : out std_logic;								
		o_data : out std_logic_vector ((WORD_LENGTH - 1) downto 0));	
end component;

end package BLOCK_INTERLEAVER_COMPONENTS;
