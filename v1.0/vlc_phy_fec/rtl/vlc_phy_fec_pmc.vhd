library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_fec_pmc_enables;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_fec_pmc_fsm;

entity vlc_phy_fec_pmc is
	generic (
		CONV_SEL : natural := 2;
		RS_CODEC_SEL : natural := 3;
		PA_MODE : boolean := false);
	port (
		clk : in std_logic;
		rst : in std_logic;
		i_busy : in std_logic;
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
		o_en_fec_dec_rs_160_128 : out std_logic;
		o_iso_enc : out std_logic;
		o_iso_dec : out std_logic;
		o_pa_ready_state : out std_logic);
end vlc_phy_fec_pmc;

architecture structure_vlc_phy_fec_pmc of vlc_phy_fec_pmc is
	signal w_en_fec_enc : std_logic;
	signal w_en_fec_dec : std_logic;
	signal w_iso : std_logic;
begin

GEN_PA_MODE_TRUE : if PA_MODE = true generate
	PMC_FSM : vlc_phy_fec_pmc_fsm
		port map (
			clk => clk,
			rst => rst,
			i_busy => i_busy,
			o_iso => w_iso,
			o_pa_ready_state => o_pa_ready_state);
	PMC_SIGS : vlc_phy_fec_pmc_enables
		port map (
			i_mode => i_mode,
			i_conv_sel => i_conv_sel,
			i_rs_codec_sel => i_rs_codec_sel,
			o_en_fec_enc => w_en_fec_enc,
			o_en_fec_dec => w_en_fec_dec,
			o_en_fec_enc_inner_code => o_en_fec_enc_inner_code,
			o_en_fec_enc_outer_code => o_en_fec_enc_outer_code,
			o_en_fec_dec_inner_code => o_en_fec_dec_inner_code,
			o_en_fec_dec_outer_code => o_en_fec_dec_outer_code,
			o_en_fec_enc_rs_15_11 => o_en_fec_enc_rs_15_11,
			o_en_fec_enc_rs_15_7 => o_en_fec_enc_rs_15_7,
			o_en_fec_enc_rs_15_4 => o_en_fec_enc_rs_15_4,
			o_en_fec_enc_rs_15_2 => o_en_fec_enc_rs_15_2,
			o_en_fec_enc_rs_64_32 => o_en_fec_enc_rs_64_32,
			o_en_fec_enc_rs_160_128 => o_en_fec_enc_rs_160_128,
			o_en_fec_dec_rs_15_11 => o_en_fec_dec_rs_15_11,
			o_en_fec_dec_rs_15_7 => o_en_fec_dec_rs_15_7,
			o_en_fec_dec_rs_15_4 => o_en_fec_dec_rs_15_4,
			o_en_fec_dec_rs_15_2 => o_en_fec_dec_rs_15_2,
			o_en_fec_dec_rs_64_32 => o_en_fec_dec_rs_64_32,
			o_en_fec_dec_rs_160_128 => o_en_fec_dec_rs_160_128);
			o_iso_enc <= w_iso or not w_en_fec_enc;
			o_iso_dec <= w_iso or not w_en_fec_dec;
end generate GEN_PA_MODE_TRUE;

GEN_PA_MODE_FALSE : if PA_MODE = false generate
	o_iso_enc <= '0';
	o_iso_dec <= '0';
	o_pa_ready_state <= '1';
	o_en_fec_enc <= '1';
	o_en_fec_dec <= '1';
	o_en_fec_enc_inner_code <= '1';
	o_en_fec_enc_outer_code <= '1';
	o_en_fec_dec_inner_code <= '1';
	o_en_fec_dec_outer_code <= '1';
	o_en_fec_enc_rs_15_11 <= '1';
	o_en_fec_enc_rs_15_7 <= '1';
	o_en_fec_enc_rs_15_4 <= '1';
	o_en_fec_enc_rs_15_2 <= '1';
	o_en_fec_enc_rs_64_32 <= '1'; 
	o_en_fec_enc_rs_160_128 <= '1';
	o_en_fec_dec_rs_15_11 <= '1';
	o_en_fec_dec_rs_15_7 <= '1';
	o_en_fec_dec_rs_15_4 <= '1';
	o_en_fec_dec_rs_15_2 <= '1';
	o_en_fec_dec_rs_64_32 <= '1';
	o_en_fec_dec_rs_160_128 <= '1';
end generate GEN_PA_MODE_FALSE;

end structure_vlc_phy_fec_pmc;

