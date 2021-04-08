library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.GENERIC_TYPES.integer_array;
use work.GENERIC_TYPES.std_logic_vector_array;
use work.GENERIC_FUNCTIONS.int_array_to_std_vector_array;
use work.GENERIC_COMPONENTS.sync_ld_dff;

entity puncturing_rate_1_3_to_2_3 is
    port (
        i_valid : in std_logic;
        i_data : in std_logic_vector(2 downto 0);
        o_valid : out std_logic;
        o_data : out std_logic_vector(2 downto 0)
    );
end puncturing_rate_1_3_to_2_3;

architecture behavioral of puncturing_rate_1_3_to_2_3 is
    signal r_wr_flop_selector : std_logic;
    signal r_first_data : std_logic;
begin
    SYNC_D_FLOP_DATA_1_INST: sync_ld_dff; 
                             generic map (WORD_LENGTH => 1) 
                             port map (clk => clk,
                                       rst => rst,
                                       ld => i_valid and not r_wr_flop_selector,
                                       d(0) => i_data(1),
                                       q(0) => r_first_data);

    SYNC_D_FLOP_WR_FLOP_SEL_INST: sync_ld_dff; 
                                  generic map (WORD_LENGTH => 1) 
                                  port map (clk => clk,
                                            rst => rst,
                                            ld => i_valid,
                                            d(0) => not r_wr_flop_selector,
                                            q(0) => r_wr_flop_selector;
          
    o_valid <= i_valid and r_wr_flop_selector;
    o_data <= r_first_data & i_data(2) & i_data(1);
end behavioral;