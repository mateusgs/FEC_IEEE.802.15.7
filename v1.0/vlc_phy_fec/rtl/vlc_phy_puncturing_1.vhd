library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity vlc_phy_puncturing is
	generic (
	CONV_SEL : natural);
	port (
		clk : in std_logic;
		rst : in std_logic;

		--Control interface
		i_conv_sel : in std_logic_vector ((CONV_SEL-1) downto 0);

		--Input data interface
		i_last_data : in std_logic;
		i_valid : in std_logic;
		i_data : in std_logic_vector (2 downto 0);
		o_in_ready : out std_logic;

		--Output data interface
		i_consume : in std_logic;
		o_last_data : out std_logic;
		o_valid : out std_logic;
		o_data : out std_logic_vector (3 downto 0));
end vlc_phy_puncturing;

architecture structure_vpp of vlc_phy_puncturing is

	signal r_23_data : std_logic_vector (1 downto 0);
	signal r_full : std_logic;
	signal w_and_conv_sel : std_logic;
	signal w_23_in_ready : std_logic;
	signal w_in_ready : std_logic;
	signal w_23_valid : std_logic;
	signal w_valid : std_logic;

	begin
	
		o_data (0) <= i_data (1) when i_conv_sel (0) = '1' else
					  i_data (0);
									  
		o_data (2 downto 1) <= r_23_data when w_and_conv_sel = '1' else
							   i_data (2 downto 1);
									  
		o_data (3) <= '0' when i_conv_sel (1) = '1' else
					  i_data (2);

		w_and_conv_sel <= i_conv_sel (1) AND i_conv_sel (0);
		
		w_23_in_ready <= NOT (r_full) OR i_consume;
		w_in_ready <= w_23_in_ready when w_and_conv_sel = '1' else
					  i_consume;
						  
		w_23_valid <= i_valid AND r_full;
		w_valid <= w_23_valid when w_and_conv_sel = '1' else
				   i_valid;
					  
		to_2_3 : process (clk, rst, i_consume, i_valid, r_full)
			begin
				if (rising_edge (clk)) then
					if (rst = '1') then
						r_full <= '0';
					elsif (i_valid = '1') then
						if (r_full = '0') then
							r_23_data <= i_data (2 downto 1);
							r_full <= '1';
						elsif (i_consume = '1') then
							r_full <= '0';
						end if;						
					end if;
				end if;
		end process;

		--output assignments
		o_in_ready <= w_in_ready;
		o_last_data <= i_last_data;
		o_valid <= w_valid;
end structure_vpp;