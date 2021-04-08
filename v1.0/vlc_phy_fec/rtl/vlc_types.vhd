library IEEE;
use IEEE.STD_LOGIC_1164.all;

package VLC_TYPES is
    type VLC_MODE is (VLC_ENCODER,
                      VLC_DECODER,
                      VLC_ENCODER_DECODER);
end package VLC_TYPES;