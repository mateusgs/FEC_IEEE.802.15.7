library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.GENERIC_COMPONENTS.parallel_to_serial;
use work.GENERIC_COMPONENTS.sync_ld_dff;
use work.GENERIC_TYPES.integer_array;
use work.convolutional_encoder_components.convolutional_encoder;
use work.VLC_PHY_FEC_COMPONENTS.VLC_PHY_PUNCTURING;

entity vlc_phy_convolutional_encoder is
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

end vlc_phy_convolutional_encoder;

architecture structure_vpce of vlc_phy_convolutional_encoder is
	--hold state of last data from input
	signal r_last_data : std_logic;

	--parallel to serial output signals
	signal w_ready_pts : std_logic;
	signal w_valid_pts : std_logic;
	signal w_data_pts : std_logic;	
	
	--convolutional encoder output signals
	signal w_ready_conv : std_logic;
	signal w_valid_conv : std_logic;
	signal w_last_data_conv : std_logic;
	signal w_data_conv : std_logic_vector(2 downto 0);

	--puncturing output signals
	signal w_ready_punc : std_logic;
	begin
	
		o_in_ready <= w_ready_pts;

		PTS : parallel_to_serial
		generic map (
			N => 4)
		port map (
			clk => clk,
			rst => rst,
			i_consume => w_ready_conv,
			i_valid => i_valid,
			i_data => i_data,
			o_in_ready => w_ready_pts,
			o_valid => w_valid_pts,
			o_data => w_data_pts);

		CE : convolutional_encoder
			generic map (
				CASCADE_LENGTH => 7,
				GENERATOR_POLY => (91, 121, 117),    
				RATE => 3)
			port map (
				clk => clk,
				rst => rst,
				i_consume => w_ready_punc,
				i_last_data => (r_last_data AND w_ready_pts),
				i_valid => w_valid_pts,
				i_data => w_data_pts,
				o_in_ready => w_ready_conv,
				o_last_data => w_last_data_conv,
				o_valid => w_valid_conv,
				o_data => w_data_conv);
							
		REG : sync_ld_dff
			generic map (
				WORD_LENGTH => 1)
			port map (
				rst => rst OR (w_ready_conv AND w_ready_pts AND r_last_data),
				clk => clk,
				ld => i_valid AND i_last_data AND w_ready_pts,	
				i_data(0) => '1',
				o_data(0) => r_last_data);
				
		VPP : VLC_PHY_PUNCTURING
			generic map (
				CONV_SEL => CONV_SEL)
			port map (
				clk => clk,
				rst => rst,
				i_consume => i_consume,
				i_last_data => w_last_data_conv,
				i_valid => w_valid_conv,
				i_conv_sel => i_conv_sel,
				i_data => w_data_conv,
				o_in_ready => w_ready_punc,
				o_last_data => o_last_data,
				o_valid => o_valid,
				o_data => o_data);

end structure_vpce;