library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity vlc_phy_fec_pmc_fsm is
	generic (
		CONV_SEL : natural := 2;
		RS_CODEC_SEL : natural := 3);
	port (
		clk : in std_logic;
		rst : in std_logic;
		i_busy : in std_logic;
		o_iso : out std_logic;
		o_pa_ready_state : out std_logic);
end vlc_phy_fec_pmc_fsm;

architecture structure_vlc_phy_fec_pmc_fsm of vlc_phy_fec_pmc_fsm is
    type State is (PWR_DOWN_ISO,
		   PWR_DOWN_RESET,
		   PWR_DOWN_SUPPLY,
		   SLEEP,
		   PWR_UP_SUPPLY,
		   PWR_UP_RESET,
		   PWR_UP_ISO,
		   ON_STATE);
    signal r_state : State;
begin
    process (clk, rst)
    begin
	if (rst = '1') then
		r_state <= PWR_DOWN_RESET;
	elsif rising_edge(clk) then
		case r_state is
			when PWR_DOWN_ISO =>
				r_state <= PWR_DOWN_RESET;
			when PWR_DOWN_RESET =>
				r_state <= PWR_DOWN_SUPPLY;
			when PWR_DOWN_SUPPLY =>
				r_state <= SLEEP;
			when SLEEP =>
				if i_busy = '1' then
					r_state <= PWR_UP_SUPPLY;
				else
					r_state <= SLEEP;
				end if;
			when PWR_UP_SUPPLY =>
				r_state <= PWR_UP_RESET;
			when PWR_UP_RESET =>
				r_state <= PWR_UP_ISO;
			when PWR_UP_ISO =>
				r_state <= ON_STATE;
			when ON_STATE =>
				--check_new state is comming
				if i_busy = '0' then
					r_state <= PWR_DOWN_ISO;
				else
					r_state <= ON_STATE;
				end if;
		end case;
	end if;
    end process;

    process (rst, r_state)
    begin
	case r_state is
		when PWR_DOWN_ISO =>
			o_iso <= '1';
			o_pa_ready_state <= '0';
		when PWR_DOWN_RESET =>
			o_iso <= '1';
			o_pa_ready_state <= '0';
		when PWR_DOWN_SUPPLY =>
			o_iso <= '1';
			o_pa_ready_state <= '0';
		when SLEEP =>
			o_iso <= '1';
			o_pa_ready_state <= '0';
		when PWR_UP_SUPPLY =>
			o_iso <= '1';
			o_pa_ready_state <= '0';
		when PWR_UP_RESET =>
			o_iso <= '1';
			o_pa_ready_state <= '0';
		when PWR_UP_ISO =>
			o_iso <= '0';
			o_pa_ready_state <= '0';
		when ON_STATE =>
			o_iso <= '0';
			o_pa_ready_state <= '1';
	end case;
    end process;
end structure_vlc_phy_fec_pmc_fsm;
