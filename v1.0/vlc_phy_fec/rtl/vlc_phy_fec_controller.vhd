library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.GENERIC_COMPONENTS.sync_ld_dff;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_fec_pmc;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_mcs_id_dec;

entity vlc_phy_fec_controller is
	generic (
		CONV_SEL : natural := 2;
		MCS_ID_LENGTH : natural := 6;
		RS_CODEC_SEL : natural := 3;
		PA_MODE : boolean := false);
	port (
		clk : in std_logic;
		rst : in std_logic;
		i_mode : in std_logic;
		i_release_fec : in std_logic;
		i_sync_fec : in std_logic;
		i_mcs_id : in std_logic_vector (MCS_ID_LENGTH-1 downto 0);
		o_busy : out std_logic;
		o_en_datapath : out std_logic;
		o_mode : out std_logic;
		o_conv_sel : out std_logic_vector (CONV_SEL-1 downto 0);
		o_rs_codec_sel : out std_logic_vector (RS_CODEC_SEL-1 downto 0)
	);
end vlc_phy_fec_controller;

architecture structure_vlc_phy_fec_controller of vlc_phy_fec_controller is
	signal w_busy : std_logic;
	signal w_mode : std_logic;
	signal w_pa_ready_state : std_logic;
	signal w_release_fec : std_logic;
	signal w_set_regs : std_logic;
	signal w_mcs_id : std_logic_vector (MCS_ID_LENGTH-1 downto 0);
	signal w_conv_sel : std_logic_vector (CONV_SEL-1 downto 0);
	signal w_rs_codec_sel : std_logic_vector (RS_CODEC_SEL-1 downto 0);
begin
	w_set_regs <= (NOT w_busy) AND i_sync_fec;

	process (i_release_fec, 
		 i_sync_fec, 
		 i_mode, 
		 w_mode, 
 		 i_mcs_id, 
		 w_mcs_id)
	begin
		if (i_release_fec = '1') then
			--Burst condition
			if (i_sync_fec = '1' and
			    i_mode = w_mode and
			    i_mcs_id = w_mcs_id) then
				w_release_fec <= '0';
			else
				w_release_fec <= '1';
			end if;
		else
			w_release_fec <= '0';
		end if;
	end process;

	BUSY_REG : sync_ld_dff
		generic map (
			WORD_LENGTH => 1)
		port map (
			rst => rst OR w_release_fec,
			clk => clk,
			ld => w_set_regs,
			i_data(0) => w_set_regs,
			o_data(0) => w_busy);
	
	MODE_REG : sync_ld_dff
		generic map (
			WORD_LENGTH => 1)
		port map (
			rst => rst,
			clk => clk,
			ld => w_set_regs,
			i_data(0) => i_mode,
			o_data(0) => w_mode);
	
	MCS_ID_REG : sync_ld_dff
		generic map (
			WORD_LENGTH => MCS_ID_LENGTH)
		port map (
		    rst => rst,
			clk => clk,
			ld => w_set_regs,
			i_data => i_mcs_id,
			o_data => w_mcs_id);

	MCS_ID_DEC : vlc_phy_mcs_id_dec
		port map (
			i_mcs_id => w_mcs_id,
			o_conv_sel => w_conv_sel,
			o_rs_codec_sel => w_rs_codec_sel);	

	PMC : vlc_phy_fec_pmc
		generic map (PA_MODE => PA_MODE)
		port map (
			clk => clk,
			rst => rst,
			i_busy => w_busy,
			i_mode => w_mode,
			i_conv_sel => w_conv_sel,
			i_rs_codec_sel => w_rs_codec_sel,
			o_en_fec_enc => open,
			o_en_fec_dec => open,
			o_en_fec_enc_inner_code => open,
			o_en_fec_enc_outer_code => open,
			o_en_fec_dec_inner_code => open,
			o_en_fec_dec_outer_code => open,
			o_en_fec_enc_rs_15_11 => open,
			o_en_fec_enc_rs_15_7 => open,
			o_en_fec_enc_rs_15_4 => open,
			o_en_fec_enc_rs_15_2 => open,
			o_en_fec_enc_rs_64_32 => open,
			o_en_fec_enc_rs_160_128 => open,
			o_en_fec_dec_rs_15_11 => open,
			o_en_fec_dec_rs_15_7 => open,
			o_en_fec_dec_rs_15_4 => open,
			o_en_fec_dec_rs_15_2 => open,
			o_en_fec_dec_rs_64_32 => open,
			o_en_fec_dec_rs_160_128 => open,
			o_iso_enc => open,
			o_iso_dec => open,
			o_pa_ready_state => w_pa_ready_state);

	o_busy <= w_busy;	
	o_en_datapath <= w_busy and w_pa_ready_state;	
	o_conv_sel <= w_conv_sel;
	o_mode <= w_mode;
	o_rs_codec_sel <= w_rs_codec_sel;
end structure_vlc_phy_fec_controller;
