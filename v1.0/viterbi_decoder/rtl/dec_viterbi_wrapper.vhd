library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.generic_components.sync_ld_dff;

entity dec_viterbi_wrapper is
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
end dec_viterbi_wrapper;	

architecture rtl of dec_viterbi_wrapper is
	component dec_viterbi is
	port(
		aclk: in std_logic;
		aresetn: in std_logic;
	
		s_axis_input_tvalid : in std_logic;
		s_axis_input_tdata  : in std_logic_vector(31 downto 0);
		s_axis_input_tlast  : in std_logic;
		s_axis_input_tready : out std_logic;
	
		m_axis_output_tvalid : out std_logic;
		m_axis_output_tdata  : out std_logic;
		m_axis_output_tlast  : out std_logic;
		m_axis_output_tready : in  std_logic;

		s_axis_ctrl_tvalid : in std_logic;
		s_axis_ctrl_tdata  : in std_logic_vector(31 downto 0);
		s_axis_ctrl_tlast  : in std_logic;
		s_axis_ctrl_tready : out std_logic
	);
	end component;
	
	-- DEC_VITERBI_INST signals
	signal w_s_axis_ctrl_tready : std_logic;
	signal r_s_axis_ctrl_tdata : std_logic_vector(31 downto 0);
	
	-- REG0 signals
	signal r_busy : std_logic := '0';
	
	-- internal signals
	signal w_o_last_bit : std_logic;
	
	
	begin
	
	-- 1/3, 2/3:
	r_s_axis_ctrl_tdata <= "00000001010111000000000101011100"; -- upper 16: window length, lower 16: acquisition length	

	-- 1/4:
	--r_s_axis_ctrl_tdata <= "00000010000111000000001000011100"; -- upper 16: window length, lower 16: acquisition length


	DEC_VITERBI_INST : dec_viterbi
	port map(
		aclk => clk,
		aresetn => not rst,
		s_axis_input_tvalid => i_valid,
		s_axis_input_tdata => i_symbol,
		s_axis_input_tlast => i_last_symbol,
		s_axis_input_tready => o_in_ready,
		m_axis_output_tvalid => o_valid,
		m_axis_output_tdata => o_data_bit,
		m_axis_output_tlast => w_o_last_bit,
		m_axis_output_tready => i_consume,
		s_axis_ctrl_tvalid => (not r_busy) and w_s_axis_ctrl_tready and (not rst),
		s_axis_ctrl_tdata => r_s_axis_ctrl_tdata,
		s_axis_ctrl_tlast => '0',
		s_axis_ctrl_tready => w_s_axis_ctrl_tready
	);
	
	o_last_bit <= w_o_last_bit;
	
	REG0 : sync_ld_dff
	generic map (
		WORD_LENGTH => 1)
	port map (
		rst => w_o_last_bit or rst,
		clk => clk,
		ld => i_valid,
		i_data(0) => '1',
		o_data(0) => r_busy);
		
	
end architecture rtl;
