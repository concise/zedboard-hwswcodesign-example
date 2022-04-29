source create_mmsystem.zc706.tcl
source create_mmipcore.zc706.tcl
source design_mmsystem.zc706.tcl
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

if {[version -short] < "2019.2"} {
  file mkdir mmsystem_zc706/mmsystem_zc706.sdk
  file copy -force mmsystem_zc706/mmsystem_zc706.runs/impl_1/system0_wrapper.sysdef mmsystem_zc706/mmsystem_zc706.sdk/system0_wrapper.hdf
} elseif {[version -short] >= "2019.2"} {
  set_property pfm_name {} [get_files -all {mmsystem_zc706/mmsystem_zc706.srcs/sources_1/bd/system0/system0.bd}]
  write_hw_platform -fixed -include_bit -force -file mmsystem_zc706/system0_wrapper.xsa
}
