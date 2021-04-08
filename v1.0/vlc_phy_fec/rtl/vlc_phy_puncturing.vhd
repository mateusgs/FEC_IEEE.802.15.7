library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity vlc_phy_puncturing is
	generic (
	CONV_SEL : natural := 2);
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

    component puncturing_1_3 is
	     port (
		      i_consume : in std_logic;
		      i_valid : in std_logic;
		      i_data : in std_logic_vector (2 downto 0);
		      o_in_ready : out std_logic;
		      o_valid : out std_logic;
		      o_data : out std_logic_vector (3 downto 0));
    end component;
	 
	 component puncturing_1_4 is
	     port (
		      i_consume : in std_logic;
		      i_valid : in std_logic;
		      i_data : in std_logic_vector (2 downto 0);
		      o_in_ready : out std_logic;
		      o_valid : out std_logic;
		      o_data : out std_logic_vector (3 downto 0));
    end component;
	 
	 component puncturing_2_3 is
	     port (
	         clk : in std_logic;
		      rst : in std_logic;
		      i_consume : in std_logic;
		      i_valid : in std_logic;
		      i_data : in std_logic_vector (2 downto 0);
		      o_in_ready : out std_logic;
		      o_valid : out std_logic;
		      o_data : out std_logic_vector (3 downto 0));
    end component;

    signal w_puncturing_1_3 : std_logic_vector(5 downto 0);
    signal w_puncturing_1_4 : std_logic_vector(5 downto 0);
    signal w_puncturing_2_3 : std_logic_vector(5 downto 0);
	 signal w_puncturing : std_logic_vector(5 downto 0);

    begin
	      
			w_puncturing <= w_puncturing_2_3 when i_conv_sel = "11" else
			                w_puncturing_1_4 when i_conv_sel = "01" else
								 w_puncturing_1_3;
	 
         P13 : puncturing_1_3
	          port map (
		           i_consume => i_consume,
		           i_valid => i_valid,
		           i_data => i_data,
		           o_in_ready => w_puncturing_1_3(5),
		           o_valid => w_puncturing_1_3(0),
		           o_data => w_puncturing_1_3(4 downto 1));
					  
		    P14 : puncturing_1_4
	          port map (
		           i_consume => i_consume,
		           i_valid => i_valid,
		           i_data => i_data,
		           o_in_ready => w_puncturing_1_4(5),
		           o_valid => w_puncturing_1_4(0),
		           o_data => w_puncturing_1_4(4 downto 1));
		
		    P23 : puncturing_2_3
	          port map (
				     rst => rst,
					  clk => clk,
		           i_consume => i_consume,
		           i_valid => i_valid,
		           i_data => i_data,
		           o_in_ready => w_puncturing_2_3(5),
		           o_valid => w_puncturing_2_3(0),
		           o_data => w_puncturing_2_3(4 downto 1));
					  
			 --output assignments
			 o_data <= w_puncturing(4 downto 1);
		    o_in_ready <= w_puncturing(5);
		    o_last_data <= i_last_data;
		    o_valid <= w_puncturing(0);

end structure_vpp;