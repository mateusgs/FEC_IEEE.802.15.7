library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.generic_functions.get_log_round;
use work.VLC_PHY_FEC_CONSTANTS.fec_frame;

entity vlc_phy_frame_mem is
	generic (
		NUMBER_OF_ELEMENTS : natural := 1023;
		WORD_LENGTH : natural := 8);

	port (
		i_ram_addr : in std_logic_vector(get_log_round(NUMBER_OF_ELEMENTS)-1 downto 0);
		o_ram_data : out std_logic_vector(WORD_LENGTH-1 downto 0)
	);
end vlc_phy_frame_mem;

architecture behavioral of vlc_phy_frame_mem is
	begin
		o_ram_data <= std_logic_vector(to_unsigned(fec_frame (to_integer (unsigned (i_ram_addr))), WORD_LENGTH));
end behavioral;
