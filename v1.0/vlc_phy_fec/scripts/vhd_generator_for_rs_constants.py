#import rs_helper_functions as rs
import random

def main():
    generate_vlc_phy_fec_package()

def generate_vlc_phy_fec_package():
    f = open("vlc_phy_fec_constants.vhd", "w+")
    f.write("library IEEE;\n")
    f.write("use IEEE.STD_LOGIC_1164.all;\n")
    f.write("\n") 
    f.write("package VLC_PHY_FEC_CONSTANTS is\n\n")
    #f.write("\ttype std_logic_vector_array is array (natural range <>) of std_logic_vector;\n")
    f.write("\ttype INT_ARRAY is array (integer range <>) of integer;\n")

    f.write("\tconstant fec_frame: INT_ARRAY(0 to "+str(1023-1)+") := (")

    for x in range(0,1023):
        if x != 1022:
            f.write(str(random.randint(0,63))+", ")
        else:
            f.write(str(random.randint(0,63))+");\n")

    f.write("end package VLC_PHY_FEC_CONSTANTS;\n\n")

if __name__ == "__main__":
	main()
