library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.block_interleaver_components.deinterleaver_data_path;
use work.block_interleaver_components.interleaver_controller;


entity rectangular_deinterleaver is
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
end rectangular_deinterleaver;

architecture behavioral of rectangular_deinterleaver is

	-- control signals
	
	signal w_full_ram: std_logic;
	signal w_first_out: std_logic;
	signal w_last_out: std_logic;
	signal w_rst_data_path : std_logic;
	signal w_start_rd_mode: std_logic;
	signal w_en_data_path: std_logic;
	

begin
	
	IC: interleaver_controller 
	port map (
		clk => clk,
		rst => rst,
		i_start_interleaver => i_start_interleaver,
		i_valid => i_valid,
		i_end_interleaver => i_end_interleaver,
		i_consume => i_consume,
		i_full_ram => w_full_ram,
		i_first_out => w_first_out,
		i_last_out => w_last_out,
		o_rst_indexer => w_rst_data_path, 
		o_start_rd_mode => w_start_rd_mode,
		o_en => w_en_data_path,
		o_end_interleaver => o_end_interleaver,
		o_error => o_error,
		o_in_ready => o_in_ready,
		o_start_interleaver => o_start_interleaver,
		o_valid => o_valid
		);
	
	IDP: deinterleaver_data_path
	generic map(
		NUMBER_OF_ELEMENTS => NUMBER_OF_ELEMENTS,
   	NUMBER_OF_LINES => NUMBER_OF_LINES,
		WORD_LENGTH => WORD_LENGTH)
	port map(
		rst => w_rst_data_path,
		clk => clk,
		i_start_rd_mode => w_start_rd_mode,
		i_en => w_en_data_path,
		i_data => i_data,
		o_full_ram => w_full_ram,
		o_first_out => w_first_out,
		o_last_out => w_last_out,
		o_data => o_data);	

end behavioral;
