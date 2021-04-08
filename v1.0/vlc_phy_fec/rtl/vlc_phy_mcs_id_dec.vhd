library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

entity vlc_phy_mcs_id_dec is
	generic (
		CONV_SEL : natural := 2;
		MCS_ID_LENGTH : natural := 6;
		RS_CODEC_SEL : natural := 3);
	port (
		i_mcs_id : in std_logic_vector (MCS_ID_LENGTH - 1 downto 0);
		o_conv_sel : out std_logic_vector (CONV_SEL - 1 downto 0);
		o_rs_codec_sel : out std_logic_vector (RS_CODEC_SEL - 1 downto 0));
end vlc_phy_mcs_id_dec;

architecture structure_vlc_phy_mcs_id_dec of vlc_phy_mcs_id_dec is	

	signal concatenated_vector : std_logic_vector (RS_CODEC_SEL + CONV_SEL - 1 downto 0);

begin
	--xcelium
	--concatenated_vector <= "01101" when i_mcs_id = "000000" else
	--			"10010" when i_mcs_id = "000001" else
	--			"10011" when i_mcs_id = "000010" else
	--			"10000" when i_mcs_id = "000011" else
	--			"00000" when i_mcs_id = "000100" else
	--			"00100" when i_mcs_id = "000101" else
	--			"01000" when i_mcs_id = "000110" else
	--			"01100" when i_mcs_id = "000111" else
	--			"00000" when i_mcs_id = "001000" else
	--			"10100" when i_mcs_id = "010000" else
	--			"11000" when i_mcs_id = "010001" else
	--			"10100" when i_mcs_id = "010010" else
	--			"11000" when i_mcs_id = "010011" else
	--			"00000" when i_mcs_id = "010100" else
	--			"10100" when i_mcs_id = "010101" else
	--			"11000" when i_mcs_id = "010110" else
	--			"10100" when i_mcs_id = "010111" else
	--			"11000" when i_mcs_id = "011000" else
	--			"10100" when i_mcs_id = "011001" else
	--			"11000" when i_mcs_id = "011010" else
	--			"10100" when i_mcs_id = "011011" else
	--			"11000" when i_mcs_id = "011100" else
	--			"00000" when i_mcs_id = "011101" else
	--			"10100" when i_mcs_id = "100000" else
	--			"10100" when i_mcs_id = "100001" else
	--			"10100" when i_mcs_id = "100010" else
	--			"10100" when i_mcs_id = "100011" else
	--			"10100" when i_mcs_id = "100100" else
	--			"00000" when i_mcs_id = "100101" else
	--			"00000" when i_mcs_id = "100110" else
	--						   "11100";
	with i_mcs_id select
		concatenated_vector <= "01101" when "000000",
							   "10010" when "000001",
							   "10011" when "000010",
							   "10000" when "000011",
							   "00000" when "000100",
							   "00100" when "000101",
							   "01000" when "000110",
							   "01100" when "000111",
							   "00000" when "001000",
							   "10100" when "010000",
							   "11000" when "010001",
							   "10100" when "010010",
							   "11000" when "010011",
							   "00000" when "010100",
							   "10100" when "010101",
							   "11000" when "010110",
							   "10100" when "010111",
							   "11000" when "011000",
							   "10100" when "011001",
							   "11000" when "011010",
							   "10100" when "011011",
							   "11000" when "011100",
							   "00000" when "011101",
							   "10100" when "100000",
							   "10100" when "100001",
							   "10100" when "100010",
							   "10100" when "100011",
							   "10100" when "100100",
							   "00000" when "100101",
							   "00000" when "100110",
							   "00000" when others;
									
	o_rs_codec_sel <= concatenated_vector (RS_CODEC_SEL + CONV_SEL - 1 downto CONV_SEL);
	o_conv_sel <= concatenated_vector (CONV_SEL - 1 downto 0);
end structure_vlc_phy_mcs_id_dec;
