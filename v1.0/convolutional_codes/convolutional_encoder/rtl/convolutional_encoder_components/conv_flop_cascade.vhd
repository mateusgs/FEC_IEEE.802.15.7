library IEEE;
	use IEEE.numeric_std.all;
	use IEEE.std_logic_1164.all;
	
library work;
	use work.GENERIC_TYPES.integer_array;
--	use work.GENERIC_TYPES.std_logic_vector_array;
--	use work.GENERIC_FUNCTIONS.int_array_to_std_vector_array;
	use work.GENERIC_FUNCTIONS.xor_reducer_from_select_bits;
	use work.GENERIC_COMPONENTS.sync_ld_dff;

entity conv_flop_cascade is
	generic (
		CASCADE_LENGTH : natural;				
		GENERATOR_POLY : integer_array (2 downto 0);
      --GENERATOR_POLY: array_of_integers(RATE-1 downto 0)
      --This is because Quartus compiler does not support using generic terms
      --to define other generic terms. So, for this case, it will be considered
      --the first 'k' terms of generator poly where 'k' = RATE.        
      RATE : integer);
	port (
		clk : in std_logic;
      rst : in std_logic;
		i_consume : in std_logic;
      i_data : in std_logic;
--    i_valid : in std_logic;
--    o_valid : out std_logic;		
      o_data : out std_logic_vector((RATE - 1) downto 0));
end conv_flop_cascade;

architecture structure_cfc of conv_flop_cascade is
   --constant c_polynomial : std_logic_vector_array(RATE-1 downto 0)(CASCADE_LENGTH-1 downto 0) := int_array_to_std_vector_array(GENERATOR_POLY, RATE, CASCADE_LENGTH);
   signal q_vector : std_logic_vector ((CASCADE_LENGTH - 1) downto 0);
	
	begin
	
		GEN_CONVOLUTIONAL_PATH: for I in 0 to (CASCADE_LENGTH - 1) generate
			GEN_FIRST_TERM: if I = 0 generate
				q_vector(CASCADE_LENGTH - 1) <= i_data;
			end generate;
			GEN_NOT_FIRST_TERM: if I /= 0 generate
				SYNC_D_FLOP_INST: sync_ld_dff 
					generic map (WORD_LENGTH => 1) 
					port map (rst => rst,
								 clk => clk,
								 ld => i_consume,
								 i_data (0) => q_vector(CASCADE_LENGTH - I),
								 o_data (0) => q_vector(CASCADE_LENGTH - 1 - I));
        end generate;   
    end generate;

    GEN_REDUCER_ADDERS: for I in 0 to RATE-1 generate
        o_data(I) <= xor_reducer_from_select_bits(q_vector, std_logic_vector (to_unsigned (GENERATOR_POLY (I), CASCADE_LENGTH)));
    end generate;

--    o_valid <= i_valid;
end structure_cfc;
