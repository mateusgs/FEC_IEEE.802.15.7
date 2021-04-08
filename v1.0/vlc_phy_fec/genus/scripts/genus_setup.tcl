date

set scriptDir ./SCRIPTS
set reportsDir ./REPORTS
set resultsDir ./RESULTS
set rtlDir ./RTL
set top_module "vlc_phy_fec"
set MODULE $top_module

set SUP

set SYN_EFFORT high
set MAP_EFFORT high
set INC_EFFORT high
set THE_DATE [exec date +%m%d.%H%M]
include load_etc.tcl
set iopt_stats 1
set map_fancy_nmaes

set_attr information_level 9/; #most vebose
set_attr tns_opto true /;#comment
set_attr delete_unloaded_seqs false /
set_attr optimize_constant_0_flops false /
set_attr optimize_constant_1_flops false /

set MSG {LBR-50 LBR-40 LBR-201 LBR-230 TUI-888}
suppress_messages
set_attr lp_power_unit uW /

