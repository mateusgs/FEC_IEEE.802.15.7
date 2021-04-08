library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.GENERIC_COMPONENTS.serial_to_parallel;
use work.GENERIC_COMPONENTS.sync_ld_dff;
use work.VLC_PHY_FEC_COMPONENTS.vlc_phy_depuncturing;

entity vlc_phy_viterbi_decoder is
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
		o_symbol : out std_logic_vector(3 downto 0)	
	);
end vlc_phy_viterbi_decoder;

architecture rtl of vlc_phy_viterbi_decoder is

	component dec_viterbi_wrapper is
		port(
		clk : in std_logic;
		rst : in std_logic;
		
		-- Input data interface
		i_last_symbol : in std_logic;
		i_valid : in std_logic;
		i_symbol : in std_logic_vector(31 downto 0);
		o_in_ready : out std_logic;
		
		-- Output data interface
		i_consume : in std_logic;
		o_data_bit : out std_logic;
		o_last_bit : out std_logic;
		o_valid : out std_logic
		);
	end component;
	
	-- VLC_PHY_DEPUNC signals
	signal w_last_parity : std_logic;
	signal w_valid_depunc : std_logic;
	signal w_data_depunc : std_logic_vector(31 downto 0);
	
	-- VIT_WRAPPER signals
	signal w_last_bit_vit : std_logic;
	signal w_o_in_ready_vit : std_logic;
	signal w_symbol_vit : std_logic;
	signal w_valid_vit : std_logic;
	
	-- BUFFER_SERIAL_TO_PARALLEL signals
	signal w_consume : std_logic;
	signal w_o_in_ready_buffer : std_logic;
	signal w_valid : std_logic;
	
	-- LAST_SYMBOL_REG signals
	signal r_last_symbol_reg : std_logic;
	signal w_last_symbol : std_logic;
	
begin
	
	VLC_PHY_DEPUNC : vlc_phy_depuncturing 
	port map(
		clk => clk,
		rst => rst,
		i_conv_sel => i_conv_sel,
		i_last_bit => i_last_bit,
		i_valid => i_valid,
		i_data_bit => i_data_bit,
		o_in_ready => o_in_ready,
		i_consume => w_o_in_ready_vit,
		o_last_parity => w_last_parity,
		o_valid => w_valid_depunc,
		o_data => w_data_depunc
	);
	
	VIT_WRAPPER: dec_viterbi_wrapper
	port map(
		clk => clk,
		rst => rst,
		i_last_symbol => w_last_parity,
		i_valid => w_valid_depunc,
		i_symbol => w_data_depunc,
		o_in_ready => w_o_in_ready_vit,
		i_consume => w_o_in_ready_buffer,
		o_data_bit => w_symbol_vit,
		o_last_bit => w_last_bit_vit,	
		o_valid => w_valid_vit
	);
	
	w_consume <= i_consume; 	
		
	BUFFER_SERIAL_TO_PARALLEL : serial_to_parallel 
	generic map(
		N => 4
	)
	port map(
		clk => clk,
		rst => rst,
		i_consume => w_consume,
		i_valid => w_valid_vit,
		i_data => w_symbol_vit,
		o_data => o_symbol,
		o_in_ready => w_o_in_ready_buffer,
		o_valid => w_valid
	);	
	
	o_valid <= w_valid;
	
	LAST_SYMBOL_REG : sync_ld_dff
	generic map (
		WORD_LENGTH => 1
	)
	port map (
		rst => rst OR (w_consume AND w_last_symbol),
		clk => clk,
		ld => w_last_bit_vit AND w_valid_vit AND w_o_in_ready_buffer,
		i_data(0) => '1',
		o_data(0) => r_last_symbol_reg
	);
	
	w_last_symbol <= r_last_symbol_reg AND w_valid;
	o_last_symbol <= w_last_symbol;


end rtl;	
