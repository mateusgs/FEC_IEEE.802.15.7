library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

library work;
use work.block_interleaver_components.rectangular_deinterleaver;
use work.block_interleaver_components.rectangular_interleaver;
use work.generic_components.sync_ld_dff;

entity vlc_phy_fec_interleaver is
	generic (
		MODE : boolean := false); -- ENCODER=false and DECODER=true
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
end vlc_phy_fec_interleaver;

architecture structure_vpfi of vlc_phy_fec_interleaver is

   signal w_start_interleaver : std_logic;

	begin
	
	--------------------------------------------------
	-------------------INTERLEAVER--------------------	
	--Generates  the  main   block  responsible  for--
	--interleaving or deinterleaving the data.--------
	
		GEN_INTERLEAVER : if MODE = false generate
			RIT : rectangular_interleaver
				generic map (
					NUMBER_OF_ELEMENTS => 4385,
					NUMBER_OF_LINES => 15,
					WORD_LENGTH => 4)
				port map (
					clk => clk,
					rst => rst,
					i_consume => i_consume,
					i_end_interleaver => i_last_data,
					i_start_interleaver => w_start_interleaver,
					i_valid => i_valid,
					i_data => i_data,
					o_end_interleaver => o_last_data,
					o_error => open,
					o_in_ready => o_in_ready,
					o_start_interleaver => open,
					o_valid => o_valid,
					o_data => o_data);
		end generate;
		GEN_DEINTERLEAVER : if MODE = true generate
			RDI : rectangular_deinterleaver
				generic map (
					NUMBER_OF_ELEMENTS => 4385,
					NUMBER_OF_LINES => 15,
					WORD_LENGTH => 4)
				port map (
					clk => clk,
					rst => rst,
					i_consume => i_consume,
					i_end_interleaver => i_last_data,
					i_start_interleaver => w_start_interleaver,
					i_valid => i_valid,
					i_data => i_data,
					o_end_interleaver => o_last_data,
					o_error => open,
					o_in_ready => o_in_ready,
					o_start_interleaver => open,
					o_valid => o_valid,
					o_data => o_data);
	end generate;	
	
    --------------------REGISTER----------------------

	 REG0 : sync_ld_dff
	     generic map (
			    WORD_LENGTH => 1)		
	     port map (
			    rst => i_valid,
			    clk => clk,
			    ld => rst,
			    i_data (0) => '1',
			    o_data (0) => w_start_interleaver);


    --------------------------------------------------

end structure_vpfi;
