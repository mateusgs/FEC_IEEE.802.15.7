library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.GENERIC_TYPES.integer_array;
use work.GENERIC_FUNCTIONS.get_log_round;

package VLC_PHY_FEC_COMPONENTS is

	component vlc_phy_frame_mem is
		generic (
			NUMBER_OF_ELEMENTS : natural := 1023;
			WORD_LENGTH : natural := 8);

		port (
			i_ram_addr : in std_logic_vector(get_log_round(NUMBER_OF_ELEMENTS)-1 downto 0);
			o_ram_data : out std_logic_vector(WORD_LENGTH-1 downto 0)
		);
	end component;

	component vlc_phy_fec_checker_ctrl is
		generic (
			MCS_ID_LENGTH : natural := 6;
			MCS_ID_VALUE : natural := 0;
			IS_SIM : boolean := false
		);
		port (
			clk : in std_logic;
			rst : in std_logic;
			i_end_check_time : in std_logic;
			i_o_in_ready_enc : in std_logic;
			i_o_in_ready_dec : in std_logic;
			i_o_busy : in std_logic;
			i_end_enc_filling : in std_logic;
			i_end_dec_filling : in std_logic;
			o_mode : out std_logic;
			o_sync_fec : out std_logic;
			o_mcs_id : out std_logic_vector(MCS_ID_LENGTH-1 downto 0);
			o_i_valid_enc : out std_logic;
			o_i_valid_dec : out std_logic
		);
	end component;

    component vlc_phy_convolutional_encoder is
	     generic (
		      CONV_SEL : natural := 2);
	     port (
		      clk : in std_logic;
              rst : in std_logic;
              --Control interface
		      i_conv_sel : in std_logic_vector((CONV_SEL-1) downto 0);
              --Input data interface		
		      i_last_data : in std_logic;
		      i_valid : in std_logic;
              i_data : in std_logic_vector(3 downto 0);
		      o_in_ready : out std_logic;
              --Output data interface
              i_consume : in std_logic;
		      o_last_data : out std_logic;
		      o_valid : out std_logic;
              o_data : out std_logic_vector(3 downto 0));
    end component;
	
	component vlc_phy_fec_checker is
		generic (
			ENC_FRAME_SIZE : natural;
			DEC_FRAME_SIZE : natural;
			MCS_ID_VALUE : natural;
			CONSUME_AON : boolean := true;
			FRAME_CONSTANT_ZERO : boolean := true;
			MCS_ID_LENGTH : natural := 6;
			WORD_LENGTH : natural := 8;
			IS_SIM : boolean := false);
		port (
			--system interface
			clk : in std_logic;
			rst : in std_logic;
			i_end_check_time : in std_logic;
			--control interface
			i_busy : in std_logic;
			i_mode : in std_logic;
			o_mode : out std_logic;
			o_sync_fec : out std_logic;
			o_mcs_id : out std_logic_vector (MCS_ID_LENGTH-1 downto 0);
			--input data interface
			i_in_ready_enc : in std_logic;
			o_last_data_enc : out std_logic;
			o_valid_enc : out std_logic;
			o_data_enc : out std_logic_vector ((WORD_LENGTH - 1) downto 0);
			
			i_in_ready_dec : in std_logic;
			o_last_data_dec : out std_logic;
			o_valid_dec : out std_logic;
			o_data_dec : out std_logic_vector (WORD_LENGTH-1 downto 0);
			
			--output data interface
			i_last_data_enc : in std_logic;
			i_valid_enc : in std_logic;
			i_data_dec : in std_logic_vector (WORD_LENGTH-1 downto 0);
			i_last_data_dec : in std_logic;
			i_valid_dec : in std_logic;
			i_data_enc : in std_logic_vector (WORD_LENGTH-1 downto 0);
			o_consume : out std_logic);
	end component;

	component vlc_phy_fec_PA_MODE0 is
		-- generic (
		-- 	MCS_ID_LENGTH : natural := 6;
		-- 	WORD_LENGTH : natural := 8;
		-- 	PA_MODE : boolean := false);
		port (
			--system interface
			clk : in std_logic;
			rst : in std_logic;
			--control interface
			i_mode : in std_logic;
			i_sync_fec : in std_logic;
			--i_mcs_id : in std_logic_vector (MCS_ID_LENGTH-1 downto 0);
			i_mcs_id : in std_logic_vector (6-1 downto 0);
			o_busy : out std_logic;
			o_mode : out std_logic;
			--input data interface
			i_last_data_enc : in std_logic;
			i_valid_enc : in std_logic;
			--i_data_enc : in std_logic_vector ((WORD_LENGTH - 1) downto 0);
			i_data_enc : in std_logic_vector ((6 - 1) downto 0);
			o_in_ready_enc : out std_logic;
			i_last_data_dec : in std_logic;
			i_valid_dec : in std_logic;
			--i_data_dec : in std_logic_vector (WORD_LENGTH-1 downto 0);
			i_data_dec : in std_logic_vector (6-1 downto 0);
			o_in_ready_dec : out std_logic;
			--output data interface
			i_consume : in std_logic;
			o_last_data_enc : out std_logic;
			o_valid_enc : out std_logic;
			--o_data_dec : out std_logic_vector (WORD_LENGTH-1 downto 0);
			o_data_dec : out std_logic_vector (6-1 downto 0);
			o_last_data_dec : out std_logic;
			o_valid_dec : out std_logic;
			--o_data_enc : out std_logic_vector (WORD_LENGTH-1 downto 0));
			o_data_enc : out std_logic_vector (6-1 downto 0));
	end component;
	
	component vlc_phy_fec_controller is
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
			o_rs_codec_sel : out std_logic_vector (RS_CODEC_SEL-1 downto 0));
	end component;
	
    component vlc_phy_fec_decoder is
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
    end component;
	 
    component vlc_phy_depuncturing is
        port(
		      clk : in std_logic;
		      rst : in std_logic;
		      -- Control interface
		      i_conv_sel : in std_logic_vector(1 downto 0);
		      -- Input data interface
		      i_last_bit : in std_logic;
		      i_valid : in std_logic;
		      i_data_bit : in std_logic;
		      o_in_ready : out std_logic;
		      -- Output data interface
		      i_consume : in std_logic;
		      o_last_parity : out std_logic;
		      o_valid : out std_logic;
	          o_data : out std_logic_vector(31 downto 0));
    end component;
	
    component vlc_phy_fec_encoder is
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
    end component;
	
    component vlc_phy_fec_interleaver is
	     generic (
		      MODE : boolean); -- ENCODER=false and DECODER=true
	     port (
		      clk : in std_logic;
		      rst : in std_logic;
            --Input data interface
		      i_last_data : in std_logic;
		      i_valid : in std_logic;
		      i_data : in std_logic_vector (3 downto 0);
		      o_in_ready : out std_logic;
            --Output data interface
		      i_consume : in std_logic;
		      o_last_data : out std_logic;
		      o_valid : out std_logic;
		      o_data : out std_logic_vector (3 downto 0));
    end component;
	
	component vlc_phy_mcs_id_dec is
	generic (
		CONV_SEL : natural := 2;
		MCS_ID_LENGTH : natural := 6;
		RS_CODEC_SEL : natural := 3);
	port (
		i_mcs_id : in std_logic_vector (MCS_ID_LENGTH - 1 downto 0);
		o_conv_sel : out std_logic_vector (CONV_SEL - 1 downto 0);
		o_rs_codec_sel : out std_logic_vector (RS_CODEC_SEL - 1 downto 0));
	end component;
	
    component vlc_phy_puncturing is
	     generic (
	         CONV_SEL : natural);
	     port (
		      clk : in std_logic;
		      rst : in std_logic;
		      --Control interface
		      i_conv_sel : in std_logic_vector ((CONV_SEL-1) downto 0);
		      --Input data interface
		      i_last_data : in std_logic;
		      i_valid : in std_logic;
		      i_data : in std_logic_vector (2 downto 0);
		      o_in_ready : out std_logic;
		      --Output data interface
		      i_consume : in std_logic;
		      o_last_data : out std_logic;
		      o_valid : out std_logic;
		      o_data : out std_logic_vector (3 downto 0));
    end component;
	
    component vlc_phy_rs_codec is
	     generic (
            MODE : boolean := false ); -- ENCODER= false and DECODER= true
	     port (
		      clk : in std_logic;
		      rst : in std_logic;
		      -- Control interface
		      i_rs_codec_sel : in std_logic_vector(2 downto 0);
		      o_error : out std_logic;	
		      -- Input data interface
		      i_last_symbol : in std_logic;
         	  i_valid : in std_logic;
		      i_symbol : in std_logic_vector(7 downto 0); 
		      o_in_ready : out std_logic;
		      -- Output data interface
		      i_consume : in std_logic;
		      o_last_symbol : out std_logic;
		      o_valid : out std_logic;
	       	  o_symbol : out std_logic_vector(7 downto 0));
    end component;
	
    component vlc_phy_viterbi_decoder is
	     generic (
		      N : natural := 4
	     );
	     port(
		      clk : in std_logic;
		      rst : in std_logic;	
		      -- Control interface
		      i_conv_sel : in std_logic_vector(1 downto 0);	
		      -- Input data interface
		      i_data_bit : in std_logic;
		      i_last_bit : in std_logic;
		      i_valid : in std_logic;
		      o_in_ready : out std_logic;	
		      -- Output data interface
		      i_consume : in std_logic;
		      o_last_symbol : out std_logic;
		      o_valid : out std_logic;
		      o_symbol : out std_logic_vector(3 downto 0));
    end component;

	component vlc_phy_fec_pmc is
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
			o_iso_enc : out std_logic;
			o_iso_dec : out std_logic;
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
			o_pa_ready_state : out std_logic);
	end component;

	component vlc_phy_fec_pmc_fsm is
		generic (
			CONV_SEL : natural := 2;
			RS_CODEC_SEL : natural := 3);
		port (
			clk : in std_logic;
			rst : in std_logic;
			i_busy : in std_logic;
			o_iso : out std_logic;
			o_pa_ready_state : out std_logic);
	end component;

	component vlc_phy_fec_pmc_enables is
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
	end component;

	end package VLC_PHY_FEC_COMPONENTS;
