library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity puncturing_1_3 is
	port (
		i_consume : in std_logic;
		i_valid : in std_logic;
		i_data : in std_logic_vector (2 downto 0);
		o_in_ready : out std_logic;
		o_valid : out std_logic;
		o_data : out std_logic_vector (3 downto 0));
end puncturing_1_3;

architecture dataflow_p13 of puncturing_1_3 is
    begin
	     o_data <= '0' & i_data(0) & i_data(1) & i_data(2);
	     o_in_ready <= i_consume;
		  o_valid <= i_valid;
end dataflow_p13;
