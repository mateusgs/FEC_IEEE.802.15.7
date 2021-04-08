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

entity depuncturing_1_4 is
	port(
		i_data : in std_logic_vector(3 downto 0);
		o_data : out std_logic_vector(31 downto 0)
		);
end depuncturing_1_4;

architecture rtl of depuncturing_1_4 is

signal w_i_muxes : std_logic_vector_array(1 downto 0)(3 downto 0);
signal w_i_mux2  : std_logic_vector_array(1 downto 0)(3 downto 0);
signal w_i_mux3  : std_logic_vector_array(1 downto 0)(3 downto 0);

signal w_o_comp0 : std_logic;
signal w_o_comp1 : std_logic;
signal w_o_mux0  : std_logic_vector(3 downto 0);
signal w_o_mux1  : std_logic_vector(3 downto 0);

signal w_a : std_logic_vector(3 downto 0);
signal w_b : std_logic_vector(3 downto 0);


begin

	w_i_muxes <= ("1000", "0111");

	COMP0 : comparator	
	generic map (
		WORD_LENGTH => 1
		)
	port map (
		i_r(0) => i_data(3),
		i(0) => i_data(2),
		lt => open,
		eq => w_o_comp0
		);
		
	COMP1 : comparator	
	generic map (
		WORD_LENGTH => 1
		)
	port map (
		i_r(0) => i_data(1),
		i(0) => i_data(0),
		lt => open,
		eq => w_o_comp1
		);	
		
	MUX0 : multiplexer_array
	generic map(
		WORD_LENGTH => 4,
		NUM_OF_ELEMENTS => 2
	)
	port map(
		i_array => w_i_muxes,
		i_sel(0) => i_data(2),
		o => w_o_mux0
	);	
	
	MUX1 : multiplexer_array
	generic map(
		WORD_LENGTH => 4,
		NUM_OF_ELEMENTS => 2
	)
	port map(
		i_array => w_i_muxes,
		i_sel(0) => i_data(0),
		o => w_o_mux1
	);	
	
	w_i_mux2 <= (w_o_mux0, "0000");
	
	MUX2 : multiplexer_array
	generic map(
		WORD_LENGTH => 4,
		NUM_OF_ELEMENTS => 2
	)
	port map(
		i_array => w_i_mux2,
		i_sel(0) => w_o_comp0,
		o => w_a
	);
	
	w_i_mux3 <= (w_o_mux1, "0000");

	MUX3 : multiplexer_array
	generic map(
		WORD_LENGTH => 4,
		NUM_OF_ELEMENTS => 2
	)
	port map(
		i_array => w_i_mux3,
		i_sel(0) => w_o_comp1,
		o => w_b
	);	
	
	o_data <= "00000000000000000000" & w_a & "0000" & w_b;

end rtl;
