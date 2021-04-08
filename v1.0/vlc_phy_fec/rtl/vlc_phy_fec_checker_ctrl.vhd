library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

entity vlc_phy_fec_checker_ctrl is
	generic (
        MCS_ID_LENGTH : natural := 6;
        MCS_ID_VALUE : natural := 0;
        IS_SIM : boolean := false
    );
	port (
		clk : in std_logic;
        rst : in std_logic;
        i_end_check_time : in std_logic;
        i_o_in_ready_enc : in std_logic;
        i_o_in_ready_dec : in std_logic;
        i_o_busy : in std_logic;
        i_end_enc_filling : in std_logic;
        i_end_dec_filling : in std_logic;
        o_mode : out std_logic;
        o_sync_fec : out std_logic;
        o_mcs_id : out std_logic_vector(MCS_ID_LENGTH-1 downto 0);
        o_i_valid_enc : out std_logic;
        o_i_valid_dec : out std_logic
    );
end vlc_phy_fec_checker_ctrl;

architecture structure_vlc_phy_fec_checker_ctrl of vlc_phy_fec_checker_ctrl is
    type State is (START_FLOW,
		           CONFIG_ENCODER,
                   ENC_FILLING,
                   ENC_TX,
                   CONFIG_DECODER,
                   DEC_FILLING,
                   DEC_TX,
                   END_FLOW);
    signal r_state : State;
begin
    process (clk, rst)
    begin
        if (rst = '1') then
            r_state <= START_FLOW;
        elsif rising_edge(clk) then
            case r_state is
                when START_FLOW =>
                    r_state <= CONFIG_ENCODER;
                when CONFIG_ENCODER =>
                    if (i_o_in_ready_enc = '1') then
                        r_state <= ENC_FILLING;
                    else
                        r_state <= CONFIG_ENCODER;
		    end if;
                when ENC_FILLING =>
                    if (i_end_enc_filling = '1' and i_o_in_ready_enc = '1') then
                        r_state <= ENC_TX;
                    else
                        r_state <= ENC_FILLING;
		    end if;
                when ENC_TX =>
                    if (i_o_busy = '0') then
                        r_state <= CONFIG_DECODER;
                    else
                        r_state <= ENC_TX;
		    end if;
                when CONFIG_DECODER =>
                    if (i_o_in_ready_dec = '1') then
                        r_state <= DEC_FILLING;
                    else
                        r_state <= CONFIG_DECODER;      
		    end if;
                when DEC_FILLING =>
                    if (i_end_dec_filling = '1' and i_o_in_ready_dec = '1') then
                        r_state <= DEC_TX;
                    else
                        r_state <= DEC_FILLING;
		    end if;
                when DEC_TX =>
                    if (i_o_busy = '0') then
                        r_state <= END_FLOW;
                    else
                        r_state <= DEC_TX;
		    end if;
                when END_FLOW =>
                    r_state <= END_FLOW;
            end case;
        end if;
    end process;

    process (rst, r_state)
    begin
        case r_state is
            when START_FLOW =>
                o_i_valid_enc <= '0';
                o_i_valid_dec <= '0';
                o_mode <= '0';
                o_sync_fec <= '0';
                o_mcs_id <= std_logic_vector(to_unsigned(MCS_ID_VALUE,6));
            when CONFIG_ENCODER =>
                o_i_valid_enc <= '0';
                o_i_valid_dec <= '0';
                o_mode <= '0';
                o_sync_fec <= '1';
                o_mcs_id <= std_logic_vector(to_unsigned(MCS_ID_VALUE,6));
            when ENC_FILLING =>
                o_i_valid_enc <= '1';
                o_i_valid_dec <= '0';
                o_mode <= '0';
                o_sync_fec <= '0';
                o_mcs_id <= std_logic_vector(to_unsigned(MCS_ID_VALUE,6));
            when ENC_TX =>
                o_i_valid_enc <= '0';
                o_i_valid_dec <= '0';
                o_mode <= '0';
                o_sync_fec <= '0';
                o_mcs_id <= std_logic_vector(to_unsigned(MCS_ID_VALUE,6));
            when CONFIG_DECODER =>
                o_i_valid_enc <= '0';
                o_i_valid_dec <= '0';
                o_mode <= '1';
                o_sync_fec <= '1';
                o_mcs_id <= std_logic_vector(to_unsigned(MCS_ID_VALUE,6));
            when DEC_FILLING =>
                o_i_valid_enc <= '0';
                o_i_valid_dec <= '1';
                o_mode <= '1';
                o_sync_fec <= '0';
		o_mcs_id <= std_logic_vector(to_unsigned(MCS_ID_VALUE,6));
            when DEC_TX =>
                o_i_valid_enc <= '0';
                o_i_valid_dec <= '0';
                o_mode <= '1';
                o_sync_fec <= '0';
                o_mcs_id <= std_logic_vector(to_unsigned(MCS_ID_VALUE,6));
            when END_FLOW =>
                o_i_valid_enc <= '0';
                o_i_valid_dec <= '0';
                o_mode <= '1';
                o_sync_fec <= '0';
                o_mcs_id <= std_logic_vector(to_unsigned(MCS_ID_VALUE,6));
        end case;
    end process;

    IS_SIM_GEN : if IS_SIM = true generate
        process(clk)
        begin
            if (rising_edge(clk)) then
                if (i_end_check_time = '1' and r_state /= END_FLOW) then
                    --assert false report "END_FLOW NOT reached" severity failure;
                end if;
            end if;
        end process;
    end generate;
end structure_vlc_phy_fec_checker_ctrl;
