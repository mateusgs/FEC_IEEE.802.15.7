library IEEE;
use IEEE.std_logic_1164.all;

entity puncturing_rate_1_3_to_1_4 is
    port (
        i_data : in std_logic_vector(3 downto 0);
        o_data : out std_logic_vector(1 downto 0)
    );
end puncturing_rate_1_3_to_1_4;

architecture behavioral of puncturing_rate_1_3_to_1_4 is
begin
    o_data <= i_data(1) & i_data(1) & i_data(0) & i_data(0);
end behavioral;