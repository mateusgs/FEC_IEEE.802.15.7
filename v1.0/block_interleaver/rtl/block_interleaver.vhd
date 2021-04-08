library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.BLOCK_INTERLEAVER_COMPONENTS.rectangular_interleaver;
use work.BLOCK_INTERLEAVER_COMPONENTS.rectangular_deinterleaver;

entity block_interleaver is
    generic (
        NUMBER_OF_ELEMENTS : natural := 5;
        NUMBER_OF_LINES : natural := 2;
        WORD_LENGTH : natural := 4;
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
end block_interleaver;

architecture behavioral of block_interleaver is
begin
   GEN_INT: if MODE = false generate
	INTERLEAVER_INST : rectangular_interleaver		
		generic map (NUMBER_OF_ELEMENTS => NUMBER_OF_ELEMENTS,
			     NUMBER_OF_LINES => NUMBER_OF_LINES,
		 	     WORD_LENGTH => WORD_LENGTH)
		port map(
			clk => clk,
			rst => rst,
			i_consume => i_consume,
			i_end_interleaver => i_end_cw,
			i_start_interleaver => i_start_cw,
			i_valid => i_valid,
			i_data => i_data,
			o_end_interleaver => o_end_cw, 
			o_error => o_error,
			o_in_ready => o_in_ready,
			o_start_interleaver => o_start_cw,
			o_valid => o_valid,
			o_data => o_data);
   else generate
	DEINTERLEAVER_INST : rectangular_deinterleaver		
		generic map (NUMBER_OF_ELEMENTS => NUMBER_OF_ELEMENTS,
			     NUMBER_OF_LINES => NUMBER_OF_LINES,
		 	     WORD_LENGTH => WORD_LENGTH)
		port map(
			clk => clk,
			rst => rst,
			i_consume => i_consume,
			i_end_interleaver => i_end_cw,
			i_start_interleaver => i_start_cw,
			i_valid => i_valid,
			i_data => i_data,
			o_end_interleaver => o_end_cw, 
			o_error => o_error,
			o_in_ready => o_in_ready,
			o_start_interleaver => o_start_cw,
			o_valid => o_valid,
			o_data => o_data);

   end generate GEN_INT;
end behavioral;
