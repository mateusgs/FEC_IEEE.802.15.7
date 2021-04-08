library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.GENERIC_COMPONENTS.reg_fifo;
use work.GENERIC_COMPONENTS.sync_ld_dff;
use work.GENERIC_TYPES.integer_array;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_fec_interleaver;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_rs_codec;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_viterbi_decoder;

entity vlc_phy_fec_decoder is
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
		i_data : in std_logic_vector ((WORD_LENGTH-1) downto 0);
		o_in_ready : out std_logic;

		--Output data interface
		i_consume : in std_logic;
		o_last_data : out std_logic;
		o_valid : out std_logic;
		o_data : out std_logic_vector ((WORD_LENGTH-1) downto 0));
end vlc_phy_fec_decoder;

architecture structure_VPFD of vlc_phy_fec_decoder is
    --control signals
    signal w_fec_enable : std_logic;
	signal w_inner_code_enable : std_logic;
	--TODO: Parece que não precisa de ter o w_full_fec. Pode usar o w_inner_code_enable no lugar dele.
	signal w_full_fec : std_logic;
	signal w_rs_only : std_logic;

	--RS_ENCODER_UNIT signals
	signal w_rs_last_data_i : std_logic;
	signal w_rs_last_data_o : std_logic;
	signal w_rs_valid_i : std_logic;
	signal w_rs_valid_o : std_logic;
	signal w_rs_data_i : std_logic_vector (WORD_LENGTH-1 downto 0);
	signal w_rs_data_o : std_logic_vector (WORD_LENGTH-1 downto 0);
	signal w_rs_ready : std_logic;

	--INTERLEAVER_UNIT signals
	signal w_deint_last_data : std_logic;
	signal w_deint_valid : std_logic;
	signal w_deint_data : std_logic_vector (3 downto 0);
	signal w_deint_ready : std_logic;
	signal r_deint_data_fifo : std_logic_vector (5 downto 0);	
	signal w_deint_data_fifo_empty : std_logic;
	signal w_deint_data_fifo_full : std_logic;

	--CONVOLUTIONAL_ENCODER_UNIT signals
	signal w_viterbi_last_data : std_logic;
	signal w_viterbi_valid : std_logic;
	signal w_viterbi_data : std_logic_vector (3 downto 0);
	signal w_viterbi_ready : std_logic;
	signal r_viterbi_data_fifo : std_logic_vector (5 downto 0);	
	signal w_viterbi_data_output_empty : std_logic;
	signal w_viterbi_data_output_full : std_logic;

	--FRAME_RECEIVED signals
	signal r_frame_received : std_logic;
	signal w_o_in_ready : std_logic;

	begin

    --FEC encoder is only disabled when i_rs_codec_sel = "000"
	w_fec_enable <= i_rs_codec_sel (2) OR i_rs_codec_sel (1) OR i_rs_codec_sel (0);
	w_full_fec <= w_fec_enable AND w_inner_code_enable;
	--Determines if inner code (interleaver + convolutional codec) is enabled or not.
	--It is disabled when i_conv_set = "00"
	w_inner_code_enable <= i_conv_sel (1) OR i_conv_sel (0);

	w_rs_only <= w_fec_enable AND NOT (w_inner_code_enable);

	VIT : vlc_phy_viterbi_decoder
		port map (
			clk => clk,
			rst => rst,
			--Control interface
			i_conv_sel => i_conv_sel,
			--Input data interface
			i_last_bit => i_last_data,
			i_valid => i_valid,
			i_data_bit => i_data(0),
			o_in_ready => w_viterbi_ready,
			--Output data interface
			i_consume => NOT w_viterbi_data_output_full,
			o_last_symbol => w_viterbi_last_data,
			o_valid => w_viterbi_valid,
			o_symbol => w_viterbi_data);

	VITERBI_DATA_OUTPUT : reg_fifo
		generic map(NUM_OF_ELEMENTS => 2, 
					WORD_LENGTH => 6)
		port map(clk => clk,
				 rst => rst,
				 i_wr_en => NOT w_viterbi_data_output_full,
				 i_wr_data => w_viterbi_valid & w_viterbi_last_data & w_viterbi_data,
				 o_full => w_viterbi_data_output_full,
				 i_rd_en => (NOT w_viterbi_data_output_empty) AND w_deint_ready,
				 o_rd_data => r_viterbi_data_fifo,
				 o_empty => w_viterbi_data_output_empty);     

	DEINT : VLC_PHY_FEC_INTERLEAVER
		generic map (
			MODE => true)
		port map (
			clk => clk,
			rst => rst,
			--Input data interface
			i_last_data => r_viterbi_data_fifo(4),
			i_valid => (NOT w_viterbi_data_output_empty) AND r_viterbi_data_fifo(5),
			i_data => r_viterbi_data_fifo(3 downto 0),
			o_in_ready => w_deint_ready,
			--Outout data interface
			i_consume => NOT w_deint_data_fifo_full,
			o_last_data => w_deint_last_data,
			o_valid => w_deint_valid,
			o_data => w_deint_data);

	DEINT_DATA_OUTPUT : reg_fifo
		generic map(NUM_OF_ELEMENTS => 2, 
					WORD_LENGTH => 6)
		port map(clk => clk,
				 rst => rst,
				 i_wr_en => NOT w_deint_data_fifo_full,
				 i_wr_data => w_deint_valid & w_deint_last_data & w_deint_data,
				 o_full => w_deint_data_fifo_full,
				 i_rd_en => (NOT w_deint_data_fifo_empty) and w_rs_ready,
				 o_rd_data => r_deint_data_fifo,
				 o_empty => w_deint_data_fifo_empty);

	w_rs_last_data_i <= i_last_data when (w_rs_only = '1') else
						r_deint_data_fifo(4);
	w_rs_valid_i <= i_valid when (w_rs_only = '1') else
					((NOT w_deint_data_fifo_empty) AND r_deint_data_fifo(5));
	w_rs_data_i <= i_data when (w_rs_only = '1') else
					 "0000" & r_deint_data_fifo(3 downto 0);
					 
	RS : vlc_phy_rs_codec
		generic map (
			MODE => true)
		port  map (
			clk => clk,
			rst => rst,
			--Control data
			i_rs_codec_sel => i_rs_codec_sel,
			--Input data interface
			i_last_symbol => w_rs_last_data_i,
         	i_valid => w_rs_valid_i AND w_fec_enable,
			i_symbol => w_rs_data_i,
			o_in_ready => w_rs_ready,
			--Output data interface
         	i_consume => i_consume,
			o_valid => w_rs_valid_o,
			o_last_symbol => w_rs_last_data_o,
			o_symbol => w_rs_data_o);

	--Output assignments			
	o_data <= w_rs_data_o when (w_fec_enable = '1') else
			  i_data;

	FRAME_RECEIVED : sync_ld_dff
		     		 generic map (WORD_LENGTH => 1)
			  		 port map (
					 		   rst => rst OR (o_last_data AND o_valid AND i_consume),
					 		   clk => clk,
					 		   ld => w_o_in_ready AND i_last_data AND i_valid,
					 		   i_data(0) => '1',
					 		   o_data(0) => r_frame_received);

    w_o_in_ready <= w_viterbi_ready when (w_full_fec = '1') else
				  w_rs_ready when (w_rs_only = '1') else
				  i_consume;
	o_in_ready <= w_o_in_ready AND NOT r_frame_received;

    o_last_data <= w_rs_last_data_o when (w_fec_enable = '1') else
				   i_last_data;
	o_valid <= w_rs_valid_o when (w_fec_enable = '1') else
			   i_valid;
end structure_VPFD;
