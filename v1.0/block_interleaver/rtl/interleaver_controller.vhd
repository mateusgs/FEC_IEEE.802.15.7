library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity interleaver_controller is
	port (
		clk : in std_logic;
		rst : in std_logic;
		i_start_interleaver : in std_logic;		--Indicates that the first input has been sent.	
		i_valid : in std_logic;						--Validates the incoming data.
		i_end_interleaver : in std_logic;		--Indicates that the last input has been sent.
		i_consume : in std_logic;					--Requires an output from the interleaver.
		i_full_ram : in std_logic;					--Indicates that the ram has reached its capacity.
		i_first_out : in std_logic;				--Indicates that the first output is to be sent.
		i_last_out : in std_logic;					--Indicates that the last output is to be sent.
		o_rst_indexer : out std_logic;			--Resets the registers of the counter.
		o_start_rd_mode : out std_logic;			--Selects the status of process (read/write).
		o_en : out std_logic;						--Enables the registers of the counters.
		o_end_interleaver : out std_logic;		--Sets if the last output is sent. 
		o_error : out std_logic;					--Sets in case of an error.
		o_in_ready : out std_logic;				--Enables the ram to store data.
		o_start_interleaver : out std_logic;	--Sets if the first output is sent.
		o_valid : out std_logic);					--Sets if the output sent is valid.
	

end interleaver_controller;

architecture behaviour_ict of interleaver_controller is

	type state_type is (START, RECEIVE, STALL, ERROR, LAST_INPUT, CONSUMING, LAST_OUTPUT);
	signal w_current_state, w_next_state : state_type;

		begin

			sequential_process : process (clk, rst, w_next_state)
			begin
				if (rising_edge(CLK)) then	--Synchronous process;
					if (rst = '1') then	--When rsest is on, the next state must be START. That includes the start off.
						w_current_state <= START;
					elsif (rst = '0') then
						w_current_state <= w_next_state;	--Chnages to the next satate.
					end if;
				end if;
			end process;

			conbinational_process : process (w_current_state, i_start_interleaver, i_valid, i_end_interleaver, i_consume, i_full_ram, i_first_out, i_last_out)
			begin
				case w_current_state is
					when START =>	--Starting condition. Ready to receive data.
						o_rst_indexer <= '1';
						o_start_rd_mode <= '0';
						o_en <= '0';
						o_end_interleaver <= '0';
						o_error <= '0';
						o_in_ready <= '1';
						o_start_interleaver <= '0';
						o_valid <= '0';
						
						if (i_end_interleaver = '0' AND i_valid = '1' AND i_start_interleaver = '1') then
							w_next_state <= RECEIVE;
						elsif(i_valid = '0') then
							w_next_state <= START;
						else
							w_next_state <= ERROR;
						end if;
						
					when RECEIVE =>	--Receiving data.
						o_rst_indexer <= '0';
						o_start_rd_mode <= '0';
						o_en <= '1';
						o_end_interleaver <= '0';
						o_error <= '0';
						o_in_ready <= '1';
						o_start_interleaver <= '0';
						o_valid <= '0';
						
						if (i_full_ram = '1') then
							w_next_state <= ERROR;
						elsif (i_valid = '0') then
							w_next_state <= STALL;
						elsif (i_start_interleaver = '0' AND i_valid = '1' AND i_end_interleaver = '1') then
							w_next_state <= LAST_INPUT;
						elsif (i_start_interleaver = '0' AND i_valid = '1' AND i_end_interleaver = '0') then
							w_next_state <= RECEIVE;
						else
							w_next_state <= ERROR;
						end if;
						
					when STALL =>	--Waiting for valid data.
						o_rst_indexer <= '0';
						o_start_rd_mode <= '0';
						o_en <= '0';
						o_end_interleaver <= '0';
						o_error <= '0';
						o_in_ready <= '1';
						o_start_interleaver <= '0';
						o_valid <= '0';
						
						if (i_full_ram = '1') then
							w_next_state <= ERROR;
						elsif (i_valid = '0') then
							w_next_state <= STALL;
						elsif (i_start_interleaver = '0' AND i_valid = '1' AND i_end_interleaver = '1') then
							w_next_state <= LAST_INPUT;
						elsif (i_start_interleaver = '0'AND i_valid = '1' AND i_end_interleaver = '0') then
							w_next_state <= RECEIVE;
						else
							w_next_state <= ERROR;
						end if;
						
					when ERROR =>	--Indictes something wrong has happened.
						o_rst_indexer <= '1';
						o_start_rd_mode <= '0';
						o_en <= '0';
						o_end_interleaver <= '0';
						o_error <= '1';
						o_in_ready <= '0';
						o_start_interleaver <= '0';
						o_valid <= '0';

						w_next_state <= ERROR;
						
					when LAST_INPUT =>	--Happens when the i_end_interleaver is received.
						o_rst_indexer <= '0';
						o_start_rd_mode <= '1';
						o_en <= '0';
						o_end_interleaver <= '0';
						o_error <= '0';
						o_in_ready <= '0';
						o_start_interleaver <= '0';
						o_valid <= '0';
						
						if (i_full_ram = '1' OR i_valid = '1') then
							w_next_state <= ERROR;
						else
							w_next_state <= CONSUMING;
						end if;
					when CONSUMING =>	--Keeps sending outputs while i_consume is on.
						o_rst_indexer <= '0';
						o_start_rd_mode <= '0';
						o_en <= i_consume;
						o_end_interleaver <= '0';
						o_error <= '0';
						o_in_ready <= '0';
						o_start_interleaver <= i_first_out;
						o_valid <= '1';
						
						if (i_valid = '1') then
							w_next_state <= ERROR;
						elsif (i_last_out = '1' and i_consume = '1') then
							w_next_state <= LAST_OUTPUT;
						else
							w_next_state <= CONSUMING;
						end if;
						
					when LAST_OUTPUT =>	--Sends the last output and all control signals associated with it.
						o_rst_indexer <= '0';
						o_start_rd_mode <= '0';
						o_en <= '0';
						o_end_interleaver <= '1';
						o_error <= '0';
						o_in_ready <= '0';
						o_start_interleaver <= i_first_out;
						o_valid <= '1';
						
						if (i_valid = '1') then
							w_next_state <= ERROR;
						elsif (i_consume = '1') then
							w_next_state <= START;
						else
							w_next_state <= LAST_OUTPUT;
						end if;
						
					when others =>
						o_rst_indexer <= '1';
						o_start_rd_mode <= '0';
						o_en <= '0';
						o_end_interleaver <= '0';
						o_error <= '1';
						o_in_ready <= '0';
						o_start_interleaver <= '0';
						o_valid <= '0';
						w_next_state <= ERROR;
				
				end case;							
		end process;
		
end behaviour_ict;
