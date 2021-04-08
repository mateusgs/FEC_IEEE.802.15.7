library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.VLC_TYPES.all;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_fec;

entity vlc_phy_fec_TX is
	generic (
		MCS_ID_LENGTH : natural := 6;
		WORD_LENGTH : natural := 8;
		PA_MODE : boolean := false);
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
		i_last_data : in std_logic;
		i_valid : in std_logic;
		i_data : in std_logic_vector(WORD_LENGTH-1 downto 0);
		o_in_ready : out std_logic;

		--output data interface
		i_consume : in std_logic;
		o_last_data : out std_logic;
		o_valid : out std_logic;
		o_data : out std_logic_vector(WORD_LENGTH-1 downto 0));

end vlc_phy_fec_TX;

architecture arch of vlc_phy_fec_TX is
begin
	
	VPF : vlc_phy_fec
	generic map(
		MCS_ID_LENGTH => MCS_ID_LENGTH,
		WORD_LENGTH => WORD_LENGTH,
		PA_MODE => PA_MODE,
		VLC_MODE => VLC_ENCODER)
	port map(
		--system interface
		clk => clk,
		rst => rst,
		--control interface
		i_mode => i_mode,
		i_sync_fec => i_sync_fec,
		i_mcs_id => i_mcs_id,
		o_busy => o_busy,
		o_mode => o_mode,
		--input data interface
		i_last_data_enc => i_last_data,
		i_valid_enc => i_valid,
		i_data_enc => i_data,
		o_in_ready_enc => o_in_ready,
		i_last_data_dec => '0',
		i_valid_dec => '0',
		i_data_dec => (others => '0'),
		o_in_ready_dec => open,
		--output data interface
		i_consume => i_consume,
		o_last_data_enc => o_last_data,
		o_valid_enc => o_valid,
		o_data_enc => o_data,
		o_last_data_dec => open,
		o_valid_dec => open,
		o_data_dec => open);

end arch;
