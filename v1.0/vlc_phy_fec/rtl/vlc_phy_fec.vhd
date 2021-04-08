library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.VLC_TYPES.all;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_fec_controller;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_fec_decoder;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_fec_encoder;

entity vlc_phy_fec is
	generic (
		MCS_ID_LENGTH : natural := 6;
		WORD_LENGTH : natural := 8;
		PA_MODE : boolean := false;
		VLC_MODE : VLC_MODE := VLC_ENCODER_DECODER);
	port (
		--system interface
		clk : in std_logic;
		rst : in std_logic;

		--control interface
		i_mode : in std_logic;
		i_sync_fec : in std_logic;
		i_mcs_id : in std_logic_vector(MCS_ID_LENGTH-1 downto 0);
		o_busy : out std_logic;
		o_mode : out std_logic;

		--input data interface
		i_last_data_enc : in std_logic;
		i_valid_enc : in std_logic;
		i_data_enc : in std_logic_vector(WORD_LENGTH-1 downto 0);
		o_in_ready_enc : out std_logic;

		i_last_data_dec : in std_logic;
		i_valid_dec : in std_logic;
		i_data_dec : in std_logic_vector(WORD_LENGTH-1 downto 0);
		o_in_ready_dec : out std_logic;


		--output data interface
		i_consume : in std_logic;
		o_last_data_enc : out std_logic;
		o_valid_enc : out std_logic;
		o_data_enc : out std_logic_vector(WORD_LENGTH-1 downto 0);

		o_last_data_dec : out std_logic;
		o_valid_dec : out std_logic;
		o_data_dec : out std_logic_vector(WORD_LENGTH-1 downto 0));

end vlc_phy_fec;

architecture structure_vlc_phy_fec of vlc_phy_fec is
	constant RS_CODEC_SEL : natural := 3;
	constant CONV_SEL : natural := 2;

	--VPCF signals
	signal w_release_fec : std_logic;
	signal w_busy : std_logic;
	signal w_en_datapath : std_logic;
	signal w_conv_sel : std_logic_vector(CONV_SEL-1 downto 0);
	signal w_mode : std_logic;
	signal w_rs_codec_sel : std_logic_vector(RS_CODEC_SEL-1 downto 0);

	--VPFE signals
	signal w_i_valid_enc : std_logic;
	signal w_o_in_ready_enc : std_logic;
	signal w_o_last_data_enc : std_logic;
	signal w_o_valid_enc : std_logic;

	--VPFD signals
	signal w_i_valid_dec : std_logic;
	signal w_o_in_ready_dec : std_logic;
	signal w_o_last_data_dec : std_logic;
	signal w_o_valid_dec : std_logic;

begin
	
	w_release_fec <= ((w_o_last_data_enc AND w_o_valid_enc) OR (w_o_last_data_dec AND w_o_valid_dec)) AND i_consume;
	w_i_valid_enc <= w_en_datapath AND (NOT w_mode) AND i_valid_enc;
	w_i_valid_dec <= w_en_datapath AND w_mode AND i_valid_dec;

	VPFC : vlc_phy_fec_controller
	generic map(PA_MODE => PA_MODE)
	port map(
		clk => clk,
		rst => rst,
		i_mode => i_mode,
		i_release_fec => w_release_fec,
		i_sync_fec => i_sync_fec,
		i_mcs_id => i_mcs_id,
		o_busy => w_busy,
		o_en_datapath => w_en_datapath,
		o_mode => w_mode,
		o_conv_sel => w_conv_sel,
		o_rs_codec_sel => w_rs_codec_sel);
		

	GEN_ENCODER: if (VLC_MODE = VLC_ENCODER) generate
	begin
		
		VPFE : vlc_phy_fec_encoder
		port map (
			clk => clk,
			rst => rst,
			--Control interface
			i_conv_sel => w_conv_sel,
			i_rs_codec_sel => w_rs_codec_sel,
			--Input data interface
			i_last_data => i_last_data_enc,
			i_valid => w_i_valid_enc,
			i_data => i_data_enc,
			o_in_ready => w_o_in_ready_enc,
			--Output data interface
			i_consume => i_consume,
			o_last_data => w_o_last_data_enc,
			o_valid => w_o_valid_enc,
			o_data => o_data_enc);	
			
		-- Outputs	
		o_in_ready_enc <= w_en_datapath AND w_o_in_ready_enc AND (NOT w_mode);
		o_valid_enc <= w_o_valid_enc;
		o_last_data_enc <= w_o_last_data_enc;	
		
		o_in_ready_dec <= '0';
		o_last_data_dec <= '0';
		o_valid_dec <= '0';
		o_data_dec <= (others => '0');
		
		-- Wires
		w_o_last_data_dec <= '0';
		w_o_valid_dec <= '0';
		
	end generate;
	
	GEN_DECODER: if (VLC_MODE = VLC_DECODER) generate
	begin
		
		VPFD : vlc_phy_fec_decoder
		port map (
			clk => clk,
			rst => rst,
			--Control interface
			i_conv_sel => w_conv_sel,
			i_rs_codec_sel => w_rs_codec_sel,
			--Input data interface
			i_last_data => i_last_data_dec,
			i_valid => w_i_valid_dec,
			i_data => i_data_dec,
			o_in_ready => w_o_in_ready_dec,
			--Output data interface
			i_consume => i_consume,
			o_last_data => w_o_last_data_dec,
			o_valid => w_o_valid_dec,
			o_data => o_data_dec);	
			
		-- Outputs	
		o_in_ready_dec <= w_en_datapath AND w_o_in_ready_dec AND w_mode;
		o_last_data_dec <= w_o_last_data_dec;
		o_valid_dec <= w_o_valid_dec;
		
		o_in_ready_enc <= '0';
		o_valid_enc <= '0';
		o_last_data_enc <= '0';
		o_data_enc <= (others => '0');	
		
		-- Wires
		w_o_last_data_enc <= '0';
		w_o_valid_enc <= '0';	

	end generate;
	
	GEN_ENCODER_DECODER: if (VLC_MODE = VLC_ENCODER_DECODER) generate
	begin

		-- Encoder
		VPFE : vlc_phy_fec_encoder
		port map (
			clk => clk,
			rst => rst,
			--Control interface
			i_conv_sel => w_conv_sel,
			i_rs_codec_sel => w_rs_codec_sel,
			--Input data interface
			i_last_data => i_last_data_enc,
			i_valid => w_i_valid_enc,
			i_data => i_data_enc,
			o_in_ready => w_o_in_ready_enc,
			--Output data interface
			i_consume => i_consume,
			o_last_data => w_o_last_data_enc,
			o_valid => w_o_valid_enc,
			o_data => o_data_enc);	
			
		-- Encoder outputs	
		o_in_ready_enc <= w_en_datapath AND w_o_in_ready_enc AND (NOT w_mode);
		o_valid_enc <= w_o_valid_enc;
		o_last_data_enc <= w_o_last_data_enc;	
		
		-- Decoder	
		VPFD : vlc_phy_fec_decoder
		port map (
			clk => clk,
			rst => rst,
			--Control interface
			i_conv_sel => w_conv_sel,
			i_rs_codec_sel => w_rs_codec_sel,
			--Input data interface
			i_last_data => i_last_data_dec,
			i_valid => w_i_valid_dec,
			i_data => i_data_dec,
			o_in_ready => w_o_in_ready_dec,
			--Output data interface
			i_consume => i_consume,
			o_last_data => w_o_last_data_dec,
			o_valid => w_o_valid_dec,
			o_data => o_data_dec);	
			
		-- Decoder outputs	
		o_in_ready_dec <= w_en_datapath AND w_o_in_ready_dec AND w_mode;
		o_last_data_dec <= w_o_last_data_dec;
		o_valid_dec <= w_o_valid_dec;

	end generate;

	o_busy <= w_busy;
	o_mode <= w_mode;


end structure_vlc_phy_fec;
