library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity vlc_phy_fec_pmc_enables is
	generic (
		CONV_SEL : natural := 2;
		RS_CODEC_SEL : natural := 3);
	port (
		i_mode : in std_logic;
		i_conv_sel : in std_logic_vector (CONV_SEL-1 downto 0);
		i_rs_codec_sel : in std_logic_vector (RS_CODEC_SEL-1 downto 0);
		o_en_fec_enc : out std_logic;
		o_en_fec_dec : out std_logic;
		o_en_fec_enc_inner_code : out std_logic;
		o_en_fec_enc_outer_code : out std_logic;
		o_en_fec_dec_inner_code : out std_logic;
		o_en_fec_dec_outer_code : out std_logic;
		o_en_fec_enc_rs_15_11 : out std_logic;
		o_en_fec_enc_rs_15_7 : out std_logic;
		o_en_fec_enc_rs_15_4 : out std_logic;
		o_en_fec_enc_rs_15_2 : out std_logic;
		o_en_fec_enc_rs_64_32 : out std_logic;
		o_en_fec_enc_rs_160_128 : out std_logic;
		o_en_fec_dec_rs_15_11 : out std_logic;
		o_en_fec_dec_rs_15_7 : out std_logic;
		o_en_fec_dec_rs_15_4 : out std_logic;
		o_en_fec_dec_rs_15_2 : out std_logic;
		o_en_fec_dec_rs_64_32 : out std_logic;
		o_en_fec_dec_rs_160_128 : out std_logic);
end vlc_phy_fec_pmc_enables;

architecture structure_vlc_phy_fec_pmc_enables of vlc_phy_fec_pmc_enables is	
	signal w_has_inner_code : std_logic;
	signal w_has_outer_code : std_logic;
	signal w_has_rs_15_11 : std_logic;
	signal w_has_rs_15_7 : std_logic;
	signal w_has_rs_15_4 : std_logic;
	signal w_has_rs_15_2 : std_logic;
	signal w_has_rs_64_32 : std_logic;
	signal w_has_rs_160_128 : std_logic;
begin
	process (i_conv_sel)
	begin
		if i_conv_sel = "00" then
			w_has_inner_code <= '0';
		else
			w_has_inner_code <= '1';
		end if;
	end process;

	process (i_rs_codec_sel)
	begin
		if i_rs_codec_sel = "001" then
			w_has_outer_code <= '1';
			w_has_rs_15_11 <= '1';
			w_has_rs_15_7 <= '0';
			w_has_rs_15_4 <= '0';
			w_has_rs_15_2 <= '0';
			w_has_rs_64_32 <= '0';
			w_has_rs_160_128 <= '0';
		elsif i_rs_codec_sel = "010" then
			w_has_outer_code <= '1';
			w_has_rs_15_11 <= '0';
			w_has_rs_15_7 <= '1';
			w_has_rs_15_4 <= '0';
			w_has_rs_15_2 <= '0';
			w_has_rs_64_32 <= '0';
			w_has_rs_160_128 <= '0';
		elsif i_rs_codec_sel = "011" then
			w_has_outer_code <= '1';
			w_has_rs_15_11 <= '0';
			w_has_rs_15_7 <= '0';
			w_has_rs_15_4 <= '1';
			w_has_rs_15_2 <= '0';
			w_has_rs_64_32 <= '0';
			w_has_rs_160_128 <= '0';
		elsif i_rs_codec_sel = "100" then
			w_has_outer_code <= '1';
			w_has_rs_15_11 <= '0';
			w_has_rs_15_7 <= '0';
			w_has_rs_15_4 <= '0';
			w_has_rs_15_2 <= '1';
			w_has_rs_64_32 <= '0';
			w_has_rs_160_128 <= '0';
		elsif i_rs_codec_sel = "101" then
			w_has_outer_code <= '1';
			w_has_rs_15_11 <= '0';
			w_has_rs_15_7 <= '0';
			w_has_rs_15_4 <= '0';
			w_has_rs_15_2 <= '0';
			w_has_rs_64_32 <= '1';
			w_has_rs_160_128 <= '0';
		elsif i_rs_codec_sel = "110" then
			w_has_outer_code <= '1';
			w_has_rs_15_11 <= '0';
			w_has_rs_15_7 <= '0';
			w_has_rs_15_4 <= '0';
			w_has_rs_15_2 <= '0';
			w_has_rs_64_32 <= '0';
			w_has_rs_160_128 <= '1';
		else
			w_has_outer_code <= '0';
			w_has_rs_15_11 <= '0';
			w_has_rs_15_7 <= '0';
			w_has_rs_15_4 <= '0';
			w_has_rs_15_2 <= '0';
			w_has_rs_64_32 <= '0';
			w_has_rs_160_128 <= '0';
		end if;
	end process;

	process (i_mode,
		 w_has_inner_code,
		 w_has_outer_code,
		 w_has_rs_15_11,
		 w_has_rs_15_7,
		 w_has_rs_15_4,
		 w_has_rs_15_2,
		 w_has_rs_64_32,
		 w_has_rs_160_128)
	begin
		if (i_mode = '0') then
			o_en_fec_enc <= '1';
			o_en_fec_dec <= '0';
			o_en_fec_enc_inner_code <= w_has_inner_code;
			o_en_fec_enc_outer_code <= w_has_outer_code;
			o_en_fec_dec_inner_code <= '0';
			o_en_fec_dec_outer_code <= '0';
			o_en_fec_enc_rs_15_11 <= w_has_rs_15_11;
			o_en_fec_enc_rs_15_7 <= w_has_rs_15_7;
			o_en_fec_enc_rs_15_4 <= w_has_rs_15_4;
			o_en_fec_enc_rs_15_2 <= w_has_rs_15_2;
			o_en_fec_enc_rs_64_32 <= w_has_rs_64_32;
			o_en_fec_enc_rs_160_128 <= w_has_rs_160_128;
			o_en_fec_dec_rs_15_11 <= '0';
			o_en_fec_dec_rs_15_7 <= '0';
			o_en_fec_dec_rs_15_4 <= '0';
			o_en_fec_dec_rs_15_2 <= '0';
			o_en_fec_dec_rs_64_32 <= '0';
			o_en_fec_dec_rs_160_128 <= '0';
		else
			o_en_fec_enc <= '0';
			o_en_fec_dec <= '1';
			o_en_fec_enc_inner_code <= '0';
			o_en_fec_enc_outer_code <= '0';
			o_en_fec_dec_inner_code <= w_has_inner_code;
			o_en_fec_dec_outer_code <= w_has_outer_code;
			o_en_fec_enc_rs_15_11 <= '0';
			o_en_fec_enc_rs_15_7 <= '0';
			o_en_fec_enc_rs_15_4 <= '0';
			o_en_fec_enc_rs_15_2 <= '0';
			o_en_fec_enc_rs_64_32 <= '0';
			o_en_fec_enc_rs_160_128 <= '0';
			o_en_fec_dec_rs_15_11 <= w_has_rs_15_11;
			o_en_fec_dec_rs_15_7 <= w_has_rs_15_7;
			o_en_fec_dec_rs_15_4 <= w_has_rs_15_4;
			o_en_fec_dec_rs_15_2 <= w_has_rs_15_2;
			o_en_fec_dec_rs_64_32 <= w_has_rs_64_32;
			o_en_fec_dec_rs_160_128 <= w_has_rs_160_128;
		end if;
	end process;
end structure_vlc_phy_fec_pmc_enables;
