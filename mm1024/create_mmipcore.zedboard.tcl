create_peripheral user.org user mmipcore 1.0 -dir mmsystem_zedboard/ip_repo
add_peripheral_interface S00_AXI -interface_mode slave -axi_type lite [ipx::find_open_core user.org:user:mmipcore:1.0]
set_property VALUE 129 [ipx::get_bus_parameters WIZ_NUM_REG -of_objects [ipx::get_bus_interfaces S00_AXI -of_objects [ipx::find_open_core user.org:user:mmipcore:1.0]]]
generate_peripheral -driver -bfm_example_design -debug_hw_example_design [ipx::find_open_core user.org:user:mmipcore:1.0]
write_peripheral [ipx::find_open_core user.org:user:mmipcore:1.0]
set_property  ip_repo_paths  mmsystem_zedboard/ip_repo/mmipcore_1.0 [current_project]
update_ip_catalog -rebuild
ipx::edit_ip_in_project -upgrade true -name edit_mmipcore_v1_0 -directory mmsystem_zedboard/ip_repo mmsystem_zedboard/ip_repo/mmipcore_1.0/component.xml
update_compile_order -fileset sim_1

file copy -force interface/mmipcore_v1_0_S00_AXI.v mmsystem_zedboard/ip_repo/mmipcore_1.0/hdl/

file copy -force interface/mmipcore_v1_0.v mmsystem_zedboard/ip_repo/mmipcore_1.0/hdl/

file copy -force rtl/dsquare1040.v mmsystem_zedboard/ip_repo/mmipcore_1.0/hdl/
ipx::add_file hdl/dsquare1040.v [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]
set_property type verilogSource [ipx::get_files hdl/dsquare1040.v -of_objects [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]]
set_property library_name xil_defaultlib [ipx::get_files hdl/dsquare1040.v -of_objects [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]]
ipx::add_file hdl/dsquare1040.v [ipx::get_file_groups xilinx_verilogbehavioralsimulation -of_objects [ipx::current_core]]

file copy -force rtl/invPD65.v mmsystem_zedboard/ip_repo/mmipcore_1.0/hdl/
ipx::add_file hdl/invPD65.v [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]
set_property type verilogSource [ipx::get_files hdl/invPD65.v -of_objects [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]]
set_property library_name xil_defaultlib [ipx::get_files hdl/invPD65.v -of_objects [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]]
ipx::add_file hdl/invPD65.v [ipx::get_file_groups xilinx_verilogbehavioralsimulation -of_objects [ipx::current_core]]

file copy -force rtl/ma1040_65.v mmsystem_zedboard/ip_repo/mmipcore_1.0/hdl/
ipx::add_file hdl/ma1040_65.v [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]
set_property type verilogSource [ipx::get_files hdl/ma1040_65.v -of_objects [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]]
set_property library_name xil_defaultlib [ipx::get_files hdl/ma1040_65.v -of_objects [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]]
ipx::add_file hdl/ma1040_65.v [ipx::get_file_groups xilinx_verilogbehavioralsimulation -of_objects [ipx::current_core]]

file copy -force rtl/minusP1040.v mmsystem_zedboard/ip_repo/mmipcore_1.0/hdl/
ipx::add_file hdl/minusP1040.v [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]
set_property type verilogSource [ipx::get_files hdl/minusP1040.v -of_objects [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]]
set_property library_name xil_defaultlib [ipx::get_files hdl/minusP1040.v -of_objects [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]]
ipx::add_file hdl/minusP1040.v [ipx::get_file_groups xilinx_verilogbehavioralsimulation -of_objects [ipx::current_core]]

ipx::merge_project_changes hdl_parameters [ipx::current_core]

ipx::add_bus_interface interrupt_ready [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:signal:interrupt_rtl:1.0 [ipx::get_bus_interfaces interrupt_ready -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:signal:interrupt:1.0 [ipx::get_bus_interfaces interrupt_ready -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces interrupt_ready -of_objects [ipx::current_core]]
set_property display_name interrupt_ready [ipx::get_bus_interfaces interrupt_ready -of_objects [ipx::current_core]]
set_property description interrupt [ipx::get_bus_interfaces interrupt_ready -of_objects [ipx::current_core]]
ipx::add_port_map INTERRUPT [ipx::get_bus_interfaces interrupt_ready -of_objects [ipx::current_core]]
set_property physical_name interrupt_ready [ipx::get_port_maps INTERRUPT -of_objects [ipx::get_bus_interfaces interrupt_ready -of_objects [ipx::current_core]]]

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete
update_ip_catalog -rebuild -repo_path mmsystem_zedboard/ip_repo/mmipcore_1.0

