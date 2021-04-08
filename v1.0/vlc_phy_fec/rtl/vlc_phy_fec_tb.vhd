library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.VLC_TYPES.all;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_fec;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_fec_checker;

entity vlc_phy_fec_tb is
    generic (
	ENC_FRAME_SIZE : natural;
	DEC_FRAME_SIZE : natural;
        MCS_ID_VALUE : natural := 0;
        IS_SIM : boolean := true;
        PA_MODE : boolean := false;
        MCS_ID_LENGTH : natural := 6;
        WORD_LENGTH : natural := 8);
end vlc_phy_fec_tb;

architecture test_bench of vlc_phy_fec_tb is
    signal clk : std_logic;
    signal rst : std_logic;
    signal w_i_mode : std_logic;
    signal w_i_sync_fec : std_logic;
    signal w_i_mcs_id : std_logic_vector(MCS_ID_LENGTH-1 downto 0);
    signal w_o_busy :  std_logic;
    signal w_o_mode :  std_logic;

    --input data interface
    signal w_i_last_data_enc : std_logic;
    signal w_i_valid_enc : std_logic;
    signal w_i_data_enc : std_logic_vector(WORD_LENGTH-1 downto 0);
    signal w_o_in_ready_enc : std_logic;
    
    signal w_i_last_data_dec : std_logic;
    signal w_i_valid_dec : std_logic;
    signal w_i_data_dec : std_logic_vector(WORD_LENGTH-1 downto 0);
    signal w_o_in_ready_dec : std_logic;

    --output data interface
    signal w_i_consume : std_logic;

    signal w_o_last_data_enc : std_logic;
    signal w_o_valid_enc : std_logic;
    signal w_o_data_dec : std_logic_vector(WORD_LENGTH-1 downto 0);

    signal w_o_last_data_dec : std_logic;
    signal w_o_valid_dec : std_logic;
    signal w_o_data_enc : std_logic_vector(WORD_LENGTH-1 downto 0);
    signal w_end_check_time : std_logic;

begin
    SIM_WAVEFORM : if IS_SIM = true generate
        pulse : process
            begin
                clk <= '0';
                wait for 1 ns;
                clk <= '1';
                wait for 2 ns;
                clk <= '0';
                wait for 1 ns;
        end process;    
        rst <= '1', '0' after 20 ns;
        w_end_check_time <= '0', '1' after 100000 ns;
    end generate;

    FEC_CHECKER : vlc_phy_fec_checker
    generic map (
	ENC_FRAME_SIZE => ENC_FRAME_SIZE,
	DEC_FRAME_SIZE => DEC_FRAME_SIZE,
        MCS_ID_VALUE => MCS_ID_VALUE,
	IS_SIM => IS_SIM)
    port map (
        clk => clk,
		rst => rst,
        i_end_check_time => w_end_check_time,
        
		--control interface
		i_busy => w_o_busy,
        i_mode => w_o_mode,
        o_mode => w_i_mode,
		o_sync_fec => w_i_sync_fec,
		o_mcs_id => w_i_mcs_id,

        --input data interface
        i_in_ready_enc => w_o_in_ready_enc,
		o_last_data_enc => w_i_last_data_enc,
		o_valid_enc => w_i_valid_enc,
		o_data_enc => w_i_data_enc,
		
		i_in_ready_dec => w_o_in_ready_dec,
		o_last_data_dec => w_i_last_data_dec,
		o_valid_dec => w_i_valid_dec,
		o_data_dec => w_i_data_dec,
		
        --output data interface
        i_last_data_enc => w_o_last_data_enc,
		i_valid_enc => w_o_valid_enc,
		i_data_dec => w_o_data_dec,
		o_consume => w_i_consume,

		i_last_data_dec => w_o_last_data_dec,
		i_valid_dec => w_o_valid_dec,
		i_data_enc => w_o_data_enc);

    DUT: vlc_phy_fec
    generic map (
        MCS_ID_LENGTH => 6,
        WORD_LENGTH => 8,
        PA_MODE => PA_MODE,
        VLC_MODE => VLC_ENCODER_DECODER)
    port map (
		clk => clk,
		rst => rst,

		--control interface
		i_mode => w_i_mode,
		i_sync_fec => w_i_sync_fec,
		i_mcs_id => w_i_mcs_id,
		o_busy => w_o_busy,
		o_mode => w_o_mode,

		--input data interface
	        i_last_data_enc => w_i_last_data_enc,
		i_valid_enc => w_i_valid_enc,
		i_data_enc => w_i_data_enc,
		o_in_ready_enc => w_o_in_ready_enc,

		i_last_data_dec => w_i_last_data_dec,
		i_valid_dec => w_i_valid_dec,
		i_data_dec => w_i_data_dec,
		o_in_ready_dec => w_o_in_ready_dec,

		--output data interface
		i_consume => w_i_consume,
		o_last_data_enc => w_o_last_data_enc,
		o_valid_enc => w_o_valid_enc,
		o_data_dec => w_o_data_dec,
		o_last_data_dec => w_o_last_data_dec,
		o_valid_dec => w_o_valid_dec,
		o_data_enc => w_o_data_enc);

end test_bench;
