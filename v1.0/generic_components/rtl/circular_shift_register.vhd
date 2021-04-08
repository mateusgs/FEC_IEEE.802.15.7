library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.generic_components.shifter_left;

use work.generic_functions.get_log_round;

entity circular_shift_register is
	generic (
		WORD_LENGTH : natural;
		OUTPUT_LENGTH : natural
        );
	port (
		rst : in std_logic;
		clk : in std_logic;
        ld : in std_logic;
		i_data : in std_logic_vector ((WORD_LENGTH - 1) downto 0);
		o_data : out std_logic_vector ((OUTPUT_LENGTH - 1) downto 0));
end circular_shift_register;

architecture bh_reg of circular_shift_register is

	constant SHIFT_ADDR_LENGTH : natural := get_log_round(OUTPUT_LENGTH + 1);
	signal w_i_data : std_logic_vector((WORD_LENGTH - 1) downto 0);
	signal w_shifted_data : std_logic_vector((WORD_LENGTH - 1) downto 0);
	signal w_o_data : std_logic_vector((WORD_LENGTH - 1) downto 0);
	signal w_shift_value : std_logic_vector(SHIFT_ADDR_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(OUTPUT_LENGTH, SHIFT_ADDR_LENGTH)); 

	begin

		store : process (rst, clk, ld, i_data)
			begin
				if (rising_edge (clk)) then	
					if (rst = '1') then 
						w_o_data <= i_data;
					elsif (ld = '1') then
						w_o_data <= w_i_data;
					end if;
				end if;
			end process;
		
		SHIFTER : shifter_left
		generic map (
				N => WORD_LENGTH,
				S => SHIFT_ADDR_LENGTH
			)
			port map(
					i => w_o_data,
					sel => w_shift_value,
					o => w_shifted_data
			);

		w_i_data <= w_shifted_data(WORD_LENGTH - 1 downto OUTPUT_LENGTH) & w_o_data(WORD_LENGTH - 1 downto (WORD_LENGTH - OUTPUT_LENGTH));
		o_data <= w_o_data(WORD_LENGTH - 1 downto (WORD_LENGTH - OUTPUT_LENGTH));
		
end bh_reg;