library IEEE;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library work;
use work.RS_TYPES.all;
use work.RS_FUNCTIONS.get_word_length_from_rs_gf;
use WORK.RS_COMPONENTS.rs_codec;
use work.GENERIC_COMPONENTS.up_counter;
use work.GENERIC_COMPONENTS.sync_ld_dff;
use work.GENERIC_COMPONENTS.comparator;
use work.GENERIC_COMPONENTS.multiplexer_array;
use work.GENERIC_COMPONENTS.demultiplexer_array;
use work.GENERIC_TYPES.std_logic_vector_array;

entity vlc_phy_rs_codec is
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
		o_symbol : out std_logic_vector(7 downto 0)	
	  );
end vlc_phy_rs_codec;

architecture behavioral of vlc_phy_rs_codec is

-- MUX_ENC and MUX_DEC signals
signal w_i_codeword_length : std_logic_vector(7 downto 0);
signal w_i_array_mult_dec : std_logic_vector_array(6 downto 0)(7 downto 0);
signal w_i_array_mult_enc : std_logic_vector_array(6 downto 0)(7 downto 0);

-- UC signals
signal w_inc_counter : std_logic;
signal w_rst_counter : std_logic;
signal w_counter : std_logic_vector(7 downto 0);

-- COMP0 signals
signal w_i_start_codeword : std_logic;

-- COMP1 signals
signal w_o_comp1 : std_logic;

-- SLD signals
signal w_last_symbol : std_logic;

-- DEMUX0 signals
signal w_i_valid_concat : std_logic_vector_array(6 downto 0)(0 downto 0);

-- RS_15_2 signals
-- Control interface
signal w_error_15_2 : std_logic;
-- Input data interface
signal w_i_valid_15_2 : std_logic;
signal w_o_in_ready_15_2 : std_logic;
-- Output data interface
signal w_o_end_codeword_15_2 : std_logic;
signal w_o_valid_15_2 : std_logic;
signal w_symbol_15_2 : std_logic_vector(3 downto 0);

-- RS_15_4 signals
-- Control interface
signal w_error_15_4 : std_logic;
-- Input data interface
signal w_i_valid_15_4 : std_logic;
signal w_o_in_ready_15_4 : std_logic;
-- Output data interface
signal w_o_end_codeword_15_4 : std_logic;
signal w_o_valid_15_4 : std_logic;
signal w_symbol_15_4 : std_logic_vector(3 downto 0);

-- RS_15_7 signals
-- Control interface
signal w_error_15_7 : std_logic;
-- Input data interface
signal w_i_valid_15_7 : std_logic;
signal w_o_in_ready_15_7 : std_logic;
-- Output data interface
signal w_o_end_codeword_15_7 : std_logic;
signal w_o_valid_15_7 : std_logic;
signal w_symbol_15_7 : std_logic_vector(3 downto 0);

-- RS_15_11 signals
-- Control interface
signal w_error_15_11 : std_logic;
-- Input data interface
signal w_i_valid_15_11 : std_logic;
signal w_o_in_ready_15_11 : std_logic;
-- Output data interface
signal w_o_end_codeword_15_11 : std_logic;
signal w_o_valid_15_11 : std_logic;
signal w_symbol_15_11 : std_logic_vector(3 downto 0);

-- RS_64_32 signals
-- Control interface
signal w_error_64_32 : std_logic;
-- Input data interface
signal w_i_valid_64_32 : std_logic;
signal w_o_in_ready_64_32 : std_logic;
-- Output data interface
signal w_o_end_codeword_64_32 : std_logic;
signal w_o_valid_64_32 : std_logic;
signal w_symbol_64_32 : std_logic_vector(7 downto 0);

-- RS_160_128 signals
-- Control interface
signal w_error_160_128 : std_logic;
-- Input data interface
signal w_i_valid_160_128 : std_logic;
signal w_o_in_ready_160_128 : std_logic;
-- Output data interface
signal w_o_end_codeword_160_128 : std_logic;
signal w_o_valid_160_128 : std_logic;
signal w_symbol_160_128 : std_logic_vector(7 downto 0);

-- MUX1 signals
signal w_i_mux1 : std_logic_vector_array(6 downto 0)(11 downto 0);
signal w_o_mux1 : std_logic_vector(11 downto 0);

-- internal signals
signal w_i_end_codeword : std_logic;
signal w_o_end_codeword : std_logic;
signal w_o_15_2 : std_logic_vector(11 downto 0);
signal w_o_15_4 : std_logic_vector(11 downto 0);
signal w_o_15_7 : std_logic_vector(11 downto 0);
signal w_o_15_11 : std_logic_vector(11 downto 0);
signal w_o_64_32 : std_logic_vector(11 downto 0);
signal w_o_160_128 : std_logic_vector(11 downto 0);

-- internal signals for outputs
signal w_o_in_ready : std_logic;


begin		

	w_i_array_mult_enc <= ("01111111", "00011111", "00001010", "00000110", "00000011", "00000001", "11111111");
	w_i_array_mult_dec <= ("10011111", "00111111", "00001110", "00001110", "00001110", "00001110", "11111111");


	----- Mux that defines the codeword length -------
	GEN_MUX_ENC : if MODE = false generate
		MUX_ENC : multiplexer_array
			generic map (
				WORD_LENGTH => 8,
				NUM_OF_ELEMENTS => 7
			)
			port map(
				i_array => w_i_array_mult_enc,
				i_sel => i_rs_codec_sel,
				o => w_i_codeword_length
			);
	end generate;
	GEN_MUX_DEC : if MODE = true generate
		MUX_DEC : multiplexer_array
			generic map(
				WORD_LENGTH => 8,
				NUM_OF_ELEMENTS => 7
			)
			port map(
				i_array => w_i_array_mult_dec,
				i_sel => i_rs_codec_sel,
				o => w_i_codeword_length
			);
	end generate;	
	
	---------- Symbol counter -----------------------
	w_inc_counter <= i_valid AND w_o_in_ready;	-- AND w_o_in_ready
	w_rst_counter <= rst OR (w_i_end_codeword AND i_valid AND w_o_in_ready);	--i_valid AND w_o_in_ready AND 
		
	UC : up_counter
		generic map (WORD_LENGTH => 8)
		port map (
			clk => clk,
			rst => w_rst_counter,
			i_inc => w_inc_counter,
			o_counter => w_counter);	
	
	---------- Comparators --------------------------
	COMP0 : 	comparator
		generic map (WORD_LENGTH => 8)
		port map (
			i_r => std_logic_vector (to_unsigned (0, 8)),
			i => w_counter,
			lt => open,
			eq => w_i_start_codeword);
	
	COMP1 : comparator
		generic map (WORD_LENGTH => 8)
		port map (
			i_r => w_i_codeword_length,
			i => w_counter,
			lt => open,
			eq => w_o_comp1);	
			
	w_i_end_codeword <= w_o_comp1 OR i_last_symbol;
	
	------------ Register that indicates last_symbol ----------
	
	SLD : sync_ld_dff
		generic map (WORD_LENGTH => 1)
		port map (
			rst => rst,
			clk => clk,
			ld => i_last_symbol AND i_valid AND w_o_in_ready,
			i_data (0) => i_last_symbol,
			o_data (0) => w_last_symbol);	
	
	---------- Demux that defines i_valid for each rs_codec -----
	
	DEMUX0 : demultiplexer_array
		generic map (
			WORD_LENGTH => 1,
			NUM_OF_ELEMENTS => 7
		)
		port map(
			i (0) => i_valid,
			i_sel => i_rs_codec_sel,
			o_array => w_i_valid_concat
		);	
		
	w_i_valid_15_2 <= w_i_valid_concat(1)(0);
	w_i_valid_15_4 <= w_i_valid_concat(2)(0);
	w_i_valid_15_7 <= w_i_valid_concat(3)(0);
	w_i_valid_15_11 <= w_i_valid_concat(4)(0);
	w_i_valid_64_32 <= w_i_valid_concat(5)(0);
	w_i_valid_160_128 <= w_i_valid_concat(6)(0);
		
	-- RS(15,2)------------------------------------------		
	RS_15_2 : rs_codec
		generic map(N => 15, 
			K => 2,
			RS_GF => RS_GF_16,
			MODE => MODE)
		port map(clk => clk,
		rst => rst,
		i_end_codeword => w_i_end_codeword,
		i_start_codeword => w_i_start_codeword,
		i_valid => w_i_valid_15_2,
		i_consume => i_consume,
		i_symbol => i_symbol (3 downto 0),
		o_in_ready => w_o_in_ready_15_2,
		o_end_codeword => w_o_end_codeword_15_2,
		o_start_codeword => open,
		o_valid => w_o_valid_15_2,
		o_error => w_error_15_2,                                
		o_symbol => w_symbol_15_2);
	
	w_o_15_2 <= "0000" & w_symbol_15_2 & w_error_15_2 & w_o_valid_15_2 & w_o_end_codeword_15_2 & w_o_in_ready_15_2;
	
	-- RS(15,4)----------------------------------------		
	RS_15_4 : rs_codec
		generic map(N => 15, 
			K => 4,
			RS_GF => RS_GF_16,
			MODE => MODE)
		port map(clk => clk,
		rst => rst,
		i_end_codeword => w_i_end_codeword,
		i_start_codeword => w_i_start_codeword,
		i_valid => w_i_valid_15_4,
		i_consume => i_consume,
		i_symbol => i_symbol (3 downto 0),
		o_in_ready => w_o_in_ready_15_4,
		o_end_codeword => w_o_end_codeword_15_4,
		o_start_codeword => open,
		o_valid => w_o_valid_15_4,
		o_error => w_error_15_4,                                
		o_symbol => w_symbol_15_4);
					
	w_o_15_4 <= "0000" & w_symbol_15_4 & w_error_15_4 &w_o_valid_15_4 & w_o_end_codeword_15_4 & w_o_in_ready_15_4;				
					
	-- RS(15,7)--------------------------------------------			
	RS_15_7 : rs_codec
		generic map(N => 15, 
			K => 7,
			RS_GF => RS_GF_16,
			MODE => MODE)
		port map(clk => clk,
		rst => rst,
		i_end_codeword => w_i_end_codeword,
		i_start_codeword => w_i_start_codeword,
		i_valid => w_i_valid_15_7,
		i_consume => i_consume,
		i_symbol => i_symbol (3 downto 0),
		o_in_ready => w_o_in_ready_15_7,
		o_end_codeword => w_o_end_codeword_15_7,
		o_start_codeword => open,
		o_valid => w_o_valid_15_7,
		o_error => w_error_15_7,                                
		o_symbol => w_symbol_15_7);
					
	w_o_15_7 <= "0000" & w_symbol_15_7 & w_error_15_7 & w_o_valid_15_7 & w_o_end_codeword_15_7 & w_o_in_ready_15_7;			
		
	-- RS(15,11)------------------------------------------				
	RS_15_11 : rs_codec
		generic map(N => 15, 
			K => 11,
			RS_GF => RS_GF_16,
			MODE => MODE)
		port map(clk => clk,
		rst => rst,
		i_end_codeword => w_i_end_codeword,
		i_start_codeword => w_i_start_codeword,
		i_valid => w_i_valid_15_11,
		i_consume => i_consume,
		i_symbol => i_symbol (3 downto 0),
		o_in_ready => w_o_in_ready_15_11,
		o_end_codeword => w_o_end_codeword_15_11,
		o_start_codeword => open,
		o_valid => w_o_valid_15_11,
		o_error => w_error_15_11,                                
		o_symbol => w_symbol_15_11);
			
	w_o_15_11 <= "0000" & w_symbol_15_11 & w_error_15_11 & w_o_valid_15_11 & w_o_end_codeword_15_11 & w_o_in_ready_15_11;		

	-- RS(64,32)-----------------------------------------			
	RS_64_32 : rs_codec
		generic map(N => 64, 
			K => 32,
			RS_GF => RS_GF_256,
			MODE => MODE)
		port map(clk => clk,
		rst => rst,
		i_end_codeword => w_i_end_codeword,
		i_start_codeword => w_i_start_codeword, 
		i_valid => w_i_valid_64_32,
		i_consume => i_consume,
		i_symbol => i_symbol,
		o_in_ready => w_o_in_ready_64_32,
		o_end_codeword => w_o_end_codeword_64_32,
		o_start_codeword => open,
		o_valid => w_o_valid_64_32,
		o_error => w_error_64_32,                                
		o_symbol => w_symbol_64_32);
					
	w_o_64_32 <= w_symbol_64_32 & w_error_64_32 & w_o_valid_64_32 & w_o_end_codeword_64_32 & w_o_in_ready_64_32;					

	-- RS(160,128)---------------------------------			
	RS_160_128 : rs_codec
		generic map(N => 160, 
			K => 128,
			RS_GF => RS_GF_256,
			MODE => MODE)
		port map(clk => clk,
		rst => rst,
		i_end_codeword => w_i_end_codeword,
		i_start_codeword => w_i_start_codeword,
		i_valid => w_i_valid_160_128,
		i_consume => i_consume,
		i_symbol => i_symbol,
		o_in_ready => w_o_in_ready_160_128,
		o_end_codeword => w_o_end_codeword_160_128,
		o_start_codeword => open,
		o_valid => w_o_valid_160_128,
		o_error => w_error_160_128,                                
		o_symbol => w_symbol_160_128);	
					
	w_o_160_128 <= w_symbol_160_128 & w_error_160_128 & w_o_valid_160_128 & w_o_end_codeword_160_128 & w_o_in_ready_160_128;								
				
	--------- Mux that defines block outputs --------		
	w_i_mux1 <= (w_o_160_128, w_o_64_32, w_o_15_11, w_o_15_7, w_o_15_4, w_o_15_2, "111111111111");
	
	MUX1 : multiplexer_array
		generic map(
			WORD_LENGTH => 12,
			NUM_OF_ELEMENTS => 7
		)
		port map(
			i_array => w_i_mux1,
			i_sel => i_rs_codec_sel,
			o => w_o_mux1
		);
		
	--output assignments
	w_o_in_ready <= w_o_mux1(0);
	w_o_end_codeword <= w_o_mux1(1);
	o_in_ready <= w_o_in_ready;
	o_last_symbol <= w_o_end_codeword AND w_last_symbol;
	o_valid <= w_o_mux1(2);
	o_error <= w_o_mux1(3);
	o_symbol <= w_o_mux1(11 downto 4);
end behavioral;
