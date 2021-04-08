library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
library WORK;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.GENERIC_COMPONENTS.reg_fifo;
use work.GENERIC_COMPONENTS.up_counter;
use work.generic_components.up_down_counter;
use WORK.RS_COMPONENTS.rs_adder;
use WORK.RS_COMPONENTS.rs_decoder;
use WORK.RS_COMPONENTS.rs_syndrome_unit;

use work.RS_TYPES.all;
--Quartus
--use work.RS_TYPES.RSGFSize;
use work.RS_FUNCTIONS.get_word_length_from_rs_gf;

entity rs_decoder_plus_syndrome is
        generic (
            N : natural range 2 to 1023;
		    K : natural range 1 to 1022;
            RS_GF : RSGFSize := RS_GF_NONE
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            i_end_codeword : in std_logic;
            i_start_codeword : in std_logic;
            i_valid : in std_logic;
            i_consume : in std_logic;
            i_symbol : in std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0);
            o_end_codeword : out std_logic;
            o_error : out std_logic;
            o_in_ready : out std_logic;
            o_start_codeword : out std_logic;
            o_valid : out std_logic;
            o_symbol : out std_logic_vector(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0);   
            --Verification signals
            i_save_symbol : in std_logic;         
            o_syndrome : out std_logic_vector_array(N-K-1 downto 0)(get_word_length_from_rs_gf(N, RS_GF)-1 downto 0)
        );
end rs_decoder_plus_syndrome;

architecture behavior of rs_decoder_plus_syndrome is
    
constant WORD_LENGTH : natural := get_word_length_from_rs_gf(N, RS_GF);
constant TWO_TIMES_T : natural := N - K;

--quartus
signal w_inc_error_counter : std_logic;
signal w_decoder_symbol : std_logic_vector(WORD_LENGTH-1 downto 0); 
signal w_disturb_input : std_logic_vector(WORD_LENGTH-1 downto 0); 
signal w_error_counter : std_logic_vector(WORD_LENGTH-1 downto 0); 
signal w_position_counter : std_logic_vector(WORD_LENGTH-1 downto 0); 
signal w_position_counter_fifo : std_logic_vector(WORD_LENGTH-1 downto 0); 
signal w_original_symbol : std_logic_vector(WORD_LENGTH-1 downto 0); 
signal w_erroneous_symbol : std_logic_vector(WORD_LENGTH-1 downto 0); 
signal w_syndrome_input :std_logic_vector(WORD_LENGTH-1 downto 0);
signal w_symbol : std_logic_vector(WORD_LENGTH-1 downto 0); 
signal w_o_valid : std_logic;

--for verification
signal w_consume_error : std_logic;
signal w_empty_erroneous_symbol : std_logic;
signal w_save_control : std_logic;
signal r_save_control : std_logic;
signal w_saved_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);
signal r_saved_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);
signal w_saved_id_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);
signal r_saved_id_symbol : std_logic_vector(WORD_LENGTH-1 downto 0);
signal r_id_counter : std_logic_vector(WORD_LENGTH-1 downto 0);


begin

	assert (K < N) 
	    report "ASSERT FAILURE - K cannot be >= N" 
		 severity failure;
    
    w_syndrome_input <= i_symbol when i_valid else (others => '0');
    RS_SYNDROME_UNIT_INST: rs_syndrome_unit
                           generic map(WORD_LENGTH => WORD_LENGTH, 
                                       TWO_TIMES_T => TWO_TIMES_T)
                           port map(clk => clk,
                                    rst => rst,
                                    i_select_feedback => not (i_start_codeword and i_valid),
                                    i_stall => not i_valid,
                                    i_symbol => w_syndrome_input,
                                    o_syndrome => o_syndrome);   	
    SYMBOL_FIFO_ORIGINAL_SYMBOL : reg_fifo
                       generic map(NUM_OF_ELEMENTS => 3*N+1, 
                                   WORD_LENGTH => WORD_LENGTH)
                       port map(clk => clk,
                                rst => rst,
                                i_wr_en => i_valid,
                                i_wr_data => i_symbol,
                                o_full => open,
                                i_rd_en => o_valid,
                                o_rd_data => w_original_symbol,
                                o_empty => open);
    w_consume_error <= (o_valid and i_consume and not w_empty_erroneous_symbol) when (w_position_counter = w_position_counter_fifo) else '0';
    --w_consume_error <= '1' when (o_valid and i_consume and (w_position_counter = w_position_counter_fifo)) else '0';
    --w_consume_error <= '1';
    SYMBOL_FIFO_ERRONEOUS_SYMBOL : reg_fifo
                       generic map(NUM_OF_ELEMENTS => (N-K)/2, 
                                   WORD_LENGTH => WORD_LENGTH)
                       port map(clk => clk,
                                rst => rst,
                                i_wr_en => w_inc_error_counter,
                                i_wr_data => i_symbol,
                                o_full => open,
                                i_rd_en => w_consume_error,
                                o_rd_data => w_erroneous_symbol,
                                o_empty => w_empty_erroneous_symbol);
    SYMBOL_FIFO_POSITION : reg_fifo
                       generic map(NUM_OF_ELEMENTS => (N-K)/2, 
                                   WORD_LENGTH => WORD_LENGTH)
                       port map(clk => clk,
                                rst => rst,
                                i_wr_en => w_inc_error_counter,
                                i_wr_data => w_position_counter,
                                o_full => open,
                                i_rd_en => w_consume_error,
                                o_rd_data => w_position_counter_fifo,
                                o_empty => open);

    DECODER_CHECK_ADDER_INST: rs_adder 
                              generic map (WORD_LENGTH => WORD_LENGTH)
                              port map (i1 => i_symbol,
                                        i2 => w_disturb_input,
                                        o => w_decoder_symbol);

    process (w_disturb_input, i_valid)
    begin
        if ((i_valid = '1') and (w_disturb_input /= (w_disturb_input'range => '0'))) then
            w_inc_error_counter <= '1';
        else
            w_inc_error_counter <= '0';
        end if;
    end process;

    ERROR_COUNTER_INST : up_counter
                         generic map (WORD_LENGTH => WORD_LENGTH)
                         port map (clk => clk,
                                   rst => rst, 
                                   i_inc => w_inc_error_counter,
                                   o_counter => w_error_counter);
    POSITION_COUNTER_INST : up_down_counter
                         generic map (WORD_LENGTH => WORD_LENGTH)
                         port map (clk => clk,
                                   rst => rst or (i_valid and i_end_codeword),
				   i_dir => '0', 
                                   i_en => (o_valid and i_consume) or i_valid,
                                   o_counter => w_position_counter);
	DUT: rs_decoder
		 generic map(N => N, 
		   			 K => K,
                     RS_GF => RS_GF)
		 port map(clk => clk,
				  rst => rst,
				  i_end_codeword => i_end_codeword,
				  i_start_codeword => i_start_codeword,
				  i_valid => i_valid,
				  i_consume => i_consume,
			 	  i_symbol => w_decoder_symbol,
				  o_start_codeword => o_start_codeword,
			 	  o_end_codeword => o_end_codeword,
				  o_error => o_error,
				  o_in_ready => o_in_ready,
				  o_valid => w_o_valid,
				  o_symbol => w_symbol);

    o_valid <= w_o_valid;
	o_symbol <=	w_symbol;
end behavior;
