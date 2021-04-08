library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.generic_components.comparator;
use work.generic_components.sync_ld_dff;
use work.generic_components.shifter_left;
use work.generic_components.up_counter;
use work.generic_components.multiplexer_array;
use work.GENERIC_TYPES.std_logic_vector_array;


entity vlc_phy_depuncturing is
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
		o_data : out std_logic_vector(31 downto 0)
		);
end vlc_phy_depuncturing;

architecture rtl of vlc_phy_depuncturing is


	component depuncturing_1_3 is
		port(
			i_data : in std_logic_vector(2 downto 0);
			o_data : out std_logic_vector(31 downto 0)
			);
	end component;

	component depuncturing_1_4 is
		port(
			i_data : in std_logic_vector(3 downto 0);
			o_data : out std_logic_vector(31 downto 0)
			);
	end component;

	component depuncturing_2_3 is
		port(
			i_data : in std_logic_vector(1 downto 0);
			i_parity_sel : in std_logic;
			o_data : out std_logic_vector(31 downto 0)
			);
	end component;

	-- UC signals
	signal w_counter : std_logic_vector(2 downto 0);

	-- COMP0 signals
	signal w_sel_input : std_logic;

	-- COMP1 signals
	signal w_o_valid : std_logic;
	signal w_max_counter : std_logic_vector(2 downto 0);

	-- MUX2 signals
	signal w_parity_sel : std_logic;
	signal w_max_2_3 : std_logic_vector(2 downto 0);
	signal w_i_mux2 : std_logic_vector_array(1 downto 0)(2 downto 0);

	-- MUX3 signals
	signal w_i_mux3 : std_logic_vector_array(3 downto 0)(2 downto 0);

	-- PARITY_SEL_REG signals
	signal w_parity_sel_d : std_logic;
	signal r_parity_sel : std_logic;

	-- MUX0 signals
	signal w_data : std_logic_vector(3 downto 0);
	signal w_i_mux0 : std_logic_vector_array(1 downto 0)(3 downto 0);

	-- DATA_REGISTER signals
	signal r_data : std_logic_vector(3 downto 0);

	-- SHIFTER signals
	signal r_data_shifted : std_logic_vector(3 downto 0);

	-- DEPUNC_1_3 signals
	signal w_data_1_3 : std_logic_vector(31 downto 0);

	-- DEPUNC_1_4 signals
	signal w_data_1_4 : std_logic_vector(31 downto 0);

	-- DEPUNC_2_3 signals
	signal w_data_2_3 : std_logic_vector(31 downto 0);

	-- MUX1 signals
	signal w_i_mux1 : std_logic_vector_array(3 downto 0)(31 downto 0);

	-- Internal signals for outputs
	signal r_o_valid : std_logic;
	signal w_o_in_ready : std_logic;
	signal w_o_last_parity : std_logic;


begin

-------- Control structure ---------
		UC : up_counter
		generic map (WORD_LENGTH => 3)
		port map (
			clk => clk,
			rst => w_o_valid OR rst,
			i_inc => i_valid and w_o_in_ready,
			o_counter => w_counter);

		COMP0 : comparator
		generic map (WORD_LENGTH => 3)
		port map (
			i_r => std_logic_vector (to_unsigned (0, 3)),
			i => w_counter,
			lt => open,
			eq => w_sel_input);
			
		COMP1 : comparator
		generic map (WORD_LENGTH => 3)
		port map (
			i_r => w_max_counter,
			i => w_counter,
			lt => open,
			eq => w_o_valid);		
		
		LAST_PARITY_REG : sync_ld_dff
		generic map (
			WORD_LENGTH => 1
		)
		port map (
			rst => (i_consume AND r_o_valid AND w_o_last_parity) OR rst,
			clk => clk,
			ld => i_last_bit AND w_o_in_ready AND i_valid,
			i_data(0) => '1',
			o_data(0) => w_o_last_parity
		);	
		
		o_last_parity <= w_o_last_parity AND r_o_valid;
		
		w_i_mux2 <= ("000", "001");
		
		MUX2 : multiplexer_array
		generic map(
			WORD_LENGTH => 3,
			NUM_OF_ELEMENTS => 2
		)
		port map(
			i_array => w_i_mux2,
			i_sel(0) => w_parity_sel AND i_valid AND w_o_in_ready,
			o => w_max_2_3
		);
		
		w_i_mux3 <= (w_max_2_3 , "010" ,"011" , "111");
		
		MUX3 : multiplexer_array
		generic map(
			WORD_LENGTH => 3,
			NUM_OF_ELEMENTS => 4
		)
		port map(
			i_array => w_i_mux3,
			i_sel => i_conv_sel,
			o => w_max_counter
		);
		
		O_VALID_REGISTER : sync_ld_dff
		generic map (
			WORD_LENGTH => 1
		)
		port map (
			rst => rst,
			clk => clk,
			ld => w_o_valid OR (i_consume AND r_o_valid),
			i_data(0) => w_o_valid,
			o_data(0) => r_o_valid
		);

		o_valid <= r_o_valid;
		w_o_in_ready <= (NOT r_o_valid) OR (i_consume AND r_o_valid);
		o_in_ready <= w_o_in_ready;
	
------- Parity selector structure ------
		w_parity_sel_d <= NOT r_parity_sel;
		PARITY_SEL_REG : sync_ld_dff
		generic map (
			WORD_LENGTH => 1
		)
		port map (
			rst => rst,
			clk => clk,
			ld => i_consume and r_o_valid,
			i_data(0) => w_parity_sel_d,
			o_data(0) => r_parity_sel
		);	
	
		w_parity_sel <= NOT r_parity_sel when (i_consume = '1' and r_o_valid = '1') else r_parity_sel;
      	
------- Input structure -----------
		w_i_mux0(1) <= "000" & i_data_bit;
		w_i_mux0(0) <= r_data_shifted(3 downto 1) & i_data_bit;

		MUX0 : multiplexer_array
		generic map(
			WORD_LENGTH => 4,
			NUM_OF_ELEMENTS => 2
		)
		port map(
			i_array => w_i_mux0,
			i_sel(0) => w_sel_input,
			o => w_data
		);
	
		DATA_REGISTER : sync_ld_dff
		generic map (
			WORD_LENGTH => 4
		)
		port map (
			rst => rst,
			clk => clk,
			ld => i_valid AND w_o_in_ready,
			i_data => w_data,
			o_data => r_data
		);	
	
		SHIFTER : shifter_left
		generic map (
      		  	N => 4,
      		  	S => 1
    		)
    		port map(
     	  	 	i => r_data,
     		   	sel => std_logic_vector(to_unsigned(1,1)),
        		o => r_data_shifted
    		);
	 
-------- Depuncturing blocks -----------
		
		DEPUNC_1_3 : depuncturing_1_3
		port map(
			i_data => r_data(2 downto 0),
			o_data => w_data_1_3
		);
	
		DEPUNC_1_4 : depuncturing_1_4 
		port map(
			i_data => r_data,
			o_data => w_data_1_4
			);
			
		DEPUNC_2_3: depuncturing_2_3
		port map(
			i_data => r_data(1 downto 0),
			i_parity_sel => r_parity_sel,
			o_data => w_data_2_3
			);
		
--------- Output structure ------
		w_i_mux1 <= (w_data_2_3, w_data_1_3 , w_data_1_4 ,"11111111111111111111111111111111");
	
		MUX1 : multiplexer_array
		generic map(
			WORD_LENGTH => 32,
			NUM_OF_ELEMENTS => 4
		)
		port map(
			i_array => w_i_mux1,
			i_sel => i_conv_sel,
			o => o_data
		);

end rtl;		
