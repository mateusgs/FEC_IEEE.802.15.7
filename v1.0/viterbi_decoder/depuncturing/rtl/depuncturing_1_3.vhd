library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.generic_components.comparator;
use work.generic_components.sync_ld_dff;
use work.generic_components.shifter_left;
use work.generic_components.up_counter;
use work.generic_components.multiplexer_array;
use work.GENERIC_TYPES.std_logic_vector_array;

entity depuncturing_1_3 is
	port(
		i_data : in std_logic_vector(2 downto 0);
		o_data : out std_logic_vector(31 downto 0)
		);
end depuncturing_1_3;

architecture rtl of depuncturing_1_3 is

signal w_i_muxes : std_logic_vector_array(1 downto 0)(3 downto 0);
signal w_a0 : std_logic_vector(3 downto 0); 
signal w_b0 : std_logic_vector(3 downto 0);
signal w_c0 : std_logic_vector(3 downto 0);

begin

	w_i_muxes <= ("1000","0111");

	MUXA0 : multiplexer_array
	generic map(
		WORD_LENGTH => 4,
		NUM_OF_ELEMENTS => 2
	)
	port map(
		i_array => w_i_muxes,
		i_sel(0) => i_data(2),
		o => w_a0
	);
	
	MUXB0 : multiplexer_array
	generic map(
		WORD_LENGTH => 4,
		NUM_OF_ELEMENTS => 2
	)
	port map(
		i_array => w_i_muxes,
		i_sel(0) => i_data(1),
		o => w_b0
	);
	
	MUXC0 : multiplexer_array
	generic map(
		WORD_LENGTH => 4,
		NUM_OF_ELEMENTS => 2
	)
	port map(
		i_array => w_i_muxes,
		i_sel(0) => i_data(0),
		o => w_c0
	);
	
	o_data <= "000000000000" & w_a0 & "0000" & w_b0 & "0000" & w_c0;
	
end rtl;
