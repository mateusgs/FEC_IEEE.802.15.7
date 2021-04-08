library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity puncturing_2_3 is
	port (
	   clk : in std_logic;
		rst : in std_logic;
		i_consume : in std_logic;
		i_valid : in std_logic;
		i_data : in std_logic_vector (2 downto 0);
		o_in_ready : out std_logic;
		o_valid : out std_logic;
		o_data : out std_logic_vector (3 downto 0));
end puncturing_2_3;

architecture dataflow_p23 of puncturing_2_3 is

    signal r_data : std_logic_vector (1 downto 0);
	 signal r_full : std_logic;

    begin
	     o_data <= '0' & i_data(1) & r_data(0) & r_data(1);
	     o_in_ready <= NOT (r_full) OR i_consume;
		  o_valid <= i_valid AND r_full;
		  
		  load_data : process (clk, rst, i_consume, i_valid, r_full)
		      begin
				    if (rising_edge (clk)) then
					     if (rst = '1') then
						      r_full <= '0';
					     elsif (i_valid = '1') then
						      if (r_full = '0') then
							       r_data <= i_data (2 downto 1);
							       r_full <= '1';
						      elsif (i_consume = '1') then
							       r_full <= '0';
						      end if;						
					     end if;
			       end if;
		  end process;
end dataflow_p23;
