library IEEE;
--review: Mantenha os includes dos pacotes ordenados por ordem alfab�tica.
use IEEE.MATH_REAL.ceil;
use IEEE.MATH_REAL.log2;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.generic_components.sync_ld_dff;

entity wr_rd_status_selector is
	port (
		rst : in std_logic;							
		clk : in std_logic;							--Clock signal.
		
		i_start_rd_mode : in std_logic;			--Changes the status of FSM to read mode.
		i_en : in std_logic;							--Enables the load of the line counter and column counter registers.
		
		o_wr_rd_status : out std_logic;			--Changes the status of the data path between write (0) and read (1).
		o_ram_wr_en : out std_logic);				--Defines the period of enabling the ram.
end wr_rd_status_selector;

architecture structure_wrss of wr_rd_status_selector is 

	signal w_rd_mode : std_logic;		--Is set right after the last input has been received.

	begin
		
		REG0 : sync_ld_dff --Holds the status as read mode.
			generic map (
				WORD_LENGTH => 1)
			port map (
				rst => rst,
				clk => clk,
				ld => i_start_rd_mode,
				i_data => "1",
				o_data (0) => w_rd_mode);
				
		o_wr_rd_status <= w_rd_mode OR i_start_rd_mode;
		
		o_ram_wr_en <= (not (w_rd_mode) AND i_en) OR i_start_rd_mode;
		
end structure_wrss;