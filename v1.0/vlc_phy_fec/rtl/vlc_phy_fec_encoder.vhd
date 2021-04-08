library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.GENERIC_TYPES.integer_array;
use work.GENERIC_COMPONENTS.reg_fifo;
use work.GENERIC_COMPONENTS.sync_ld_dff;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_convolutional_encoder;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_fec_interleaver;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_rs_codec;

entity vlc_phy_fec_encoder is
	generic (
		WORD_LENGTH : natural := 8);
	port (
		clk : in std_logic;
		rst : in std_logic;

		--Control interface
		i_conv_sel : in std_logic_vector (1 downto 0);
		i_rs_codec_sel : in std_logic_vector (2 downto 0);

		--Input data interface
		i_last_data : in std_logic;
		i_valid : in std_logic;
		i_data : in std_logic_vector (WORD_LENGTH-1 downto 0);
		o_in_ready : out std_logic;

		--Output data interface
		i_consume : in std_logic;
		o_last_data : out std_logic;
		o_valid : out std_logic;
		o_data : out std_logic_vector (WORD_LENGTH-1 downto 0));
end vlc_phy_fec_encoder;

architecture structure_vlc_phy_fec_encoder of vlc_phy_fec_encoder is

	--control signals
	signal w_fec_enable : std_logic;
	signal w_inner_code_enable : std_logic;
	--TODO: Parece que não precisa de ter o w_full_fec. Pode usar o w_inner_code_enable no lugar dele.
	signal w_full_fec : std_logic;
	signal w_rs_only : std_logic;

	--RS_ENCODER_UNIT signals
	signal w_rs_last_data : std_logic;
	signal w_rs_valid : std_logic;
	signal w_rs_data : std_logic_vector (WORD_LENGTH-1 downto 0);
	signal w_rs_ready : std_logic;
	signal w_rs_consume : std_logic;
	signal r_rs_data_fifo : std_logic_vector (5 downto 0);
	signal w_rs_data_fifo_empty : std_logic;
	signal w_rs_data_fifo_full : std_logic;

	--INTERLEAVER_UNIT signals
	signal w_int_last_data : std_logic;
	signal w_int_valid : std_logic;
	signal w_int_data : std_logic_vector (3 downto 0);
	signal w_int_ready : std_logic;
	signal r_int_data_fifo : std_logic_vector (5 downto 0);
	signal w_int_data_fifo_empty : std_logic;
	signal w_int_data_fifo_full : std_logic;

	--CONVOLUTIONAL_ENCODER_UNIT signals
	signal w_conv_last_data : std_logic;
	signal w_conv_valid : std_logic;
	signal w_conv_data : std_logic_vector (3 downto 0);
	signal w_conv_ready : std_logic;

	--FRAME_RECEIVED signals
	signal r_frame_received : std_logic;
	signal w_o_in_ready : std_logic;

begin
	--FEC encoder is only disabled when i_rs_codec_sel = "000"
	w_fec_enable <= i_rs_codec_sel(2) OR i_rs_codec_sel(1) OR i_rs_codec_sel(0);
	--TODO: Not needed.
	w_full_fec <= w_fec_enable AND w_inner_code_enable;
	--Determines if inner code (interleaver + convolutional codec) is enabled or not.
	--It is disabled when i_conv_set = "00"
	w_inner_code_enable <= i_conv_sel(1) OR i_conv_sel(0);

	w_rs_only <= w_fec_enable AND NOT w_inner_code_enable;

	w_rs_consume <= i_consume when (w_rs_only = '1') else
				    (NOT w_rs_data_fifo_full);

	RS_ENCODER_UNIT : vlc_phy_rs_codec
		generic map (
			MODE => false) --Encoder=false and Decoder=true
		port map (
			clk => clk,
			rst => rst,
			--Control interface
			i_rs_codec_sel => i_rs_codec_sel,
			--Input data interface
			i_last_symbol => i_last_data,
			i_valid => i_valid AND w_fec_enable,
			i_symbol => i_data,
			o_in_ready => w_rs_ready,
			--Output data interface
			i_consume => w_rs_consume,
			o_valid => w_rs_valid,
			o_last_symbol => w_rs_last_data,
			o_symbol => w_rs_data);	

	RS_ENCODER_DATA_OUTPUT : reg_fifo
		generic map(NUM_OF_ELEMENTS => 2, 
					WORD_LENGTH => 6)
		port map(clk => clk,
				 rst => rst,
				 i_wr_en => NOT w_rs_data_fifo_full,
				 i_wr_data => w_rs_valid & w_rs_last_data & w_rs_data(3 downto 0),
				 o_full => w_rs_data_fifo_full,
				 i_rd_en => (NOT w_rs_data_fifo_empty) AND w_int_ready,
				 o_rd_data => r_rs_data_fifo,
				 o_empty => w_rs_data_fifo_empty);                                 

	INTERLEAVER_UNIT : vlc_phy_fec_interleaver
		generic map (
			MODE => false)
		port map (
			clk => clk,
			rst => rst,
			--Input data interface
			i_last_data => r_rs_data_fifo(4),
			i_valid => (NOT w_rs_data_fifo_empty) AND r_rs_data_fifo(5) AND w_full_fec,
			i_data => r_rs_data_fifo(3 downto 0),
			o_in_ready => w_int_ready,
			--Output data interface
			i_consume => NOT w_int_data_fifo_full,
			o_last_data => w_int_last_data,
			o_valid => w_int_valid,
			o_data => w_int_data);

	RS_INTERLEAVER_DATA_OUTPUT : reg_fifo
		generic map(NUM_OF_ELEMENTS => 2, 
					WORD_LENGTH => 6)
		port map(clk => clk,
				 rst => rst,
				 i_wr_en => NOT w_int_data_fifo_full,
				 i_wr_data => w_int_valid & w_int_last_data & w_int_data,
				 o_full => w_int_data_fifo_full,
				 i_rd_en => NOT w_int_data_fifo_empty AND w_conv_ready,
				 o_rd_data => r_int_data_fifo,
				 o_empty => w_int_data_fifo_empty);   

	CONV0 : VLC_PHY_CONVOLUTIONAL_ENCODER
		port map (
			clk => clk,
			rst => rst,
			--Control interface
			i_conv_sel => i_conv_sel,
			--Input data interface
			i_last_data => r_int_data_fifo(4),
			i_valid => (NOT w_int_data_fifo_empty) AND r_int_data_fifo(5),
			o_in_ready => w_conv_ready,
			i_data => r_int_data_fifo(3 downto 0),
			--Output data interface
			i_consume => i_consume,
			o_last_data => w_conv_last_data,
			o_valid => w_conv_valid,
			o_data => w_conv_data);
	
	o_last_data <= w_conv_last_data when (w_full_fec = '1') else
				   w_rs_last_data when (w_rs_only = '1') else
				   i_last_data;
						
	o_valid <= w_conv_valid when (w_full_fec = '1') else
	   		   w_rs_valid when (w_rs_only = '1') else
			   i_valid;
	
	o_data <= "0000" & w_conv_data when (w_full_fec = '1') else
			  w_rs_data when (w_rs_only = '1') else
			  i_data;

	FRAME_RECEIVED : sync_ld_dff
					 generic map (WORD_LENGTH => 1)
					 port map (
					 		rst => rst OR (o_last_data AND o_valid AND i_consume),
							clk => clk,
							ld => w_o_in_ready AND i_last_data AND i_valid,
							i_data(0) => '1',
							o_data(0) => r_frame_received);

	w_o_in_ready <= w_rs_ready when (w_fec_enable = '1') else
				  i_consume;	
	o_in_ready <= w_o_in_ready AND NOT r_frame_received;

end structure_vlc_phy_fec_encoder;
