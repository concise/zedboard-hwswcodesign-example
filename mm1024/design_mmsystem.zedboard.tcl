create_bd_design "system0"

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

startgroup
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {25} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1}] [get_bd_cells processing_system7_0]
endgroup

startgroup
create_bd_cell -type ip -vlnv user.org:user:mmipcore:1.0 mmipcore_0
endgroup

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins mmipcore_0/S00_AXI]
connect_bd_net [get_bd_pins mmipcore_0/interrupt_ready] [get_bd_pins processing_system7_0/IRQ_F2P]

regenerate_bd_layout
save_bd_design

close_bd_design [get_bd_designs system0]

make_wrapper -files [get_files mmsystem_zedboard/mmsystem_zedboard.srcs/sources_1/bd/system0/system0.bd] -top
import_files -force -norecurse mmsystem_zedboard/mmsystem_zedboard.srcs/sources_1/bd/system0/hdl/system0_wrapper.v
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

add_files -fileset constrs_1 -norecurse zedboard_master_XDC_RevC_D_v2.xdc
import_files -fileset constrs_1 zedboard_master_XDC_RevC_D_v2.xdc

