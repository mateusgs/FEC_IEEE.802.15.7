library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.GENERIC_TYPES.integer_array;

package CONVOLUTIONAL_ENCODER_COMPONENTS is

component conv_flop_cascade is
	generic (
		CASCADE_LENGTH : natural;		  		  
		GENERATOR_POLY : integer_array (2 downto 0);
      RATE : integer);
	port (
		clk : in std_logic;
      rst : in std_logic;		  
      i_consume : in std_logic;
      i_data : in std_logic;
      o_data : out std_logic_vector((RATE - 1) downto 0));
end component;

component convolutional_encoder is
	generic (
		CASCADE_LENGTH : natural;
		GENERATOR_POLY : integer_array (2 downto 0);
		RATE : integer);
	port (
		clk : in std_logic;
		rst : in std_logic;
		i_consume : in std_logic;
		i_data : in std_logic;
		i_last_data : in std_logic;
		i_valid : in std_logic;
		o_in_ready : out std_logic;
		o_last_data : out std_logic;
		o_valid : out std_logic;		
		o_data : out std_logic_vector((RATE - 1) downto 0));
end component;

end package CONVOLUTIONAL_ENCODER_COMPONENTS;
