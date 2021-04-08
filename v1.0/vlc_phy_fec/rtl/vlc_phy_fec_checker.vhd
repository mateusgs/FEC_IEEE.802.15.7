library IEEE;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.generic_functions.get_log_round;
use work.generic_components.single_port_linear_ram;
use work.generic_components.sync_ld_dff;
use work.generic_components.up_counter;
use work.vlc_phy_fec_components.vlc_phy_fec_checker_ctrl;
use work.vlc_phy_fec_components.vlc_phy_frame_mem;

entity vlc_phy_fec_checker is
	generic (
	ENC_FRAME_SIZE : natural;
	DEC_FRAME_SIZE : natural;
        MCS_ID_VALUE : natural;
	CONSUME_AON : boolean := true;
	FRAME_CONSTANT_ZERO : boolean := true;
        MCS_ID_LENGTH : natural := 6;
        WORD_LENGTH : natural := 8;
	IS_SIM : boolean := false);
	port (
		--system interface
        clk : in std_logic;
        rst : in std_logic;
        i_end_check_time : in std_logic;

        --control interface
        i_busy : in std_logic;
        i_mode : in std_logic;
        o_mode : out std_logic;
        o_sync_fec : out std_logic;
        o_mcs_id : out std_logic_vector (MCS_ID_LENGTH-1 downto 0);
        --input data interface
        i_in_ready_enc : in std_logic;
        o_last_data_enc : out std_logic;
        o_valid_enc : out std_logic;
        o_data_enc : out std_logic_vector (WORD_LENGTH-1 downto 0);
        
        i_in_ready_dec : in std_logic;
        o_last_data_dec : out std_logic;
        o_valid_dec : out std_logic;
        o_data_dec : out std_logic_vector (WORD_LENGTH-1 downto 0);
        
        --output data interface
        i_last_data_enc : in std_logic;
        i_valid_enc : in std_logic;
        i_data_dec : in std_logic_vector (WORD_LENGTH-1 downto 0);
        i_last_data_dec : in std_logic;
        i_valid_dec : in std_logic;
        i_data_enc : in std_logic_vector (WORD_LENGTH-1 downto 0);
        o_consume : out std_logic);
end vlc_phy_fec_checker;

architecture structure_vlc_phy_fec_checker of vlc_phy_fec_checker is
    signal w_end_enc_filling : std_logic;
    signal w_end_dec_filling : std_logic;
    signal r_rom_enc_output : std_logic_vector(7 downto 0);
    signal r_ram_dec_output : std_logic_vector(7 downto 0);
    signal r_rom_enc_addr : std_logic_vector(get_log_round(ENC_FRAME_SIZE)-1 downto 0);
    signal r_ram_dec_addr : std_logic_vector(get_log_round(DEC_FRAME_SIZE)-1 downto 0);
    signal r_dec_frame_size : std_logic_vector(get_log_round(DEC_FRAME_SIZE)-1 downto 0);
    signal w_valid_enc : std_logic;
    signal w_valid_dec : std_logic;
    signal w_consume : std_logic;
    signal r_bit_counter : std_logic_vector(2 downto 0);
    signal w_next_dec_word : std_logic;
    function get_cnt_bit_limit(mcs_id:natural) return std_logic_vector is
    begin
	if mcs_id = 0 then
		return "011";
	else
		return "010";
	end if;
    end function;

    constant cnt_bit_limit : std_logic_vector(2 downto 0) := get_cnt_bit_limit(MCS_ID_VALUE);

begin
    CONSUME_AON_GEN : if CONSUME_AON = true generate
	w_consume <= '1';
    end generate;
    o_consume <= w_consume;

    FSM_CHECKER : vlc_phy_fec_checker_ctrl
        generic map (MCS_ID_VALUE => MCS_ID_VALUE,
                     IS_SIM => IS_SIM)
        port map (clk => clk,
                  rst => rst,
                  i_end_check_time => i_end_check_time,
                  i_o_in_ready_enc => i_in_ready_enc,
                  i_o_in_ready_dec => i_in_ready_dec,
                  i_o_busy => i_busy,
                  i_end_enc_filling => w_end_enc_filling,
                  i_end_dec_filling => w_end_dec_filling,
                  o_mode => o_mode,
                  o_sync_fec => o_sync_fec,
                  o_mcs_id => o_mcs_id,
                  o_i_valid_enc => w_valid_enc,
                  o_i_valid_dec => w_valid_dec);

    o_valid_enc <= w_valid_enc;
    o_valid_dec <= w_valid_dec;

    ROM_ENC : vlc_phy_frame_mem
	    generic map (
		NUMBER_OF_ELEMENTS => ENC_FRAME_SIZE,
		WORD_LENGTH => 8
	    )
	    port map (
		i_ram_addr => r_rom_enc_addr,
		o_ram_data => r_rom_enc_output);
    o_data_enc <= r_rom_enc_output;

    RAM_ENC : single_port_linear_ram
            generic map (
               NUMBER_OF_ELEMENTS => DEC_FRAME_SIZE,
               WORD_LENGTH => 8)
            port map (
                clk => clk,
                i_ram_data => i_data_enc(7 downto 0),
                i_ram_wr_en => i_valid_enc,
                i_ram_addr => r_ram_dec_addr,
                o_ram_data => r_ram_dec_output);

    DECODER_OUTPUT_FOR_VITERBI_GEN : if MCS_ID_VALUE = 0 or MCS_ID_VALUE = 1 or MCS_ID_VALUE = 2 generate
	    w_next_dec_word <= '1' when (r_bit_counter = cnt_bit_limit) else '0';
	    CNT_BIT : up_counter
		    generic map (WORD_LENGTH => 3)
		    port map ( 
			clk => clk,
			rst => rst or w_next_dec_word,
			i_inc => w_valid_dec and i_in_ready_dec,
			o_counter => r_bit_counter);
	     o_data_dec <= "0000000" & r_ram_dec_output(to_integer(unsigned(r_bit_counter)));

	     w_end_dec_filling <= '1' when ((r_ram_dec_addr = r_dec_frame_size) and (w_next_dec_word = '1')) else '0';
    end generate;

    DECODER_OUTPUT_FOR_OTHERS_GEN : if MCS_ID_VALUE /= 0 and MCS_ID_VALUE /= 1 and MCS_ID_VALUE /= 2 generate
            o_data_dec <= r_ram_dec_output;
	    w_next_dec_word <= w_valid_dec and i_in_ready_dec and not w_end_dec_filling;
	    w_end_dec_filling <= '1' when (r_ram_dec_addr = r_dec_frame_size) else '0';
    end generate;
    
    w_end_enc_filling <= '1' when to_integer (unsigned (r_rom_enc_addr)) = ENC_FRAME_SIZE-1 else '0';
    o_last_data_dec <= w_end_dec_filling;
    o_last_data_enc <= w_end_enc_filling;

    CNT_ROM_ENC_ADDR : up_counter
            generic map (WORD_LENGTH => get_log_round(ENC_FRAME_SIZE))
            port map ( 
                clk => clk,
                rst => rst or (i_last_data_enc and i_valid_enc and w_consume),
                i_inc => (w_valid_enc and i_in_ready_enc) or (i_valid_dec and w_consume),
                o_counter => r_rom_enc_addr);

    CNT_RAM_DEC_ADDR : up_counter
        generic map (WORD_LENGTH => get_log_round(DEC_FRAME_SIZE))
        port map ( 
            clk => clk,
            rst => rst or (i_last_data_enc and i_valid_enc and w_consume),
            i_inc => (w_next_dec_word and not w_end_dec_filling) or (i_valid_enc and w_consume),
            o_counter => r_ram_dec_addr);

    DEC_FRAME_SIZE_DFF : sync_ld_dff
            generic map (
                WORD_LENGTH => get_log_round(DEC_FRAME_SIZE))
            port map (
                rst => rst,
                clk => clk,
                ld => i_last_data_enc and i_valid_enc,
                i_data => r_ram_dec_addr,
                o_data => r_dec_frame_size);



    IS_SIM_GEN : if IS_SIM = true generate
	process(clk)
	begin
		if (rising_edge(clk)) then
            if (i_valid_dec = '1') then
                if (o_data_dec /= r_rom_enc_output) then
                    --assert false report "dec != enc!!!" severity failure;
                end if;
			end if;
		end if;
	end process;
    end generate;

end structure_vlc_phy_fec_checker;
