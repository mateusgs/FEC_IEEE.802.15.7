clear -all

cd ..
cd ..
cd ..
file mkdir conn_output_files
cd conn_output_files
source ../UFMG_digital_design/vlc_phy_fec/formal/compilation.tcl
compile_fec REGULAR
check_lpv -load_upf ../UFMG_digital_design/vlc_phy_fec/upf/vlc_phy_fec.upf -upf_version 2.1
