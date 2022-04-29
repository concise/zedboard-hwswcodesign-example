source create_mmsystem.microzed.tcl
source create_mmipcore.microzed.tcl
source design_mmsystem.microzed.tcl
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

if {[version -short] < "2019.2"} {
  file mkdir mmsystem_microzed/mmsystem_microzed.sdk
  file copy -force mmsystem_microzed/mmsystem_microzed.runs/impl_1/system0_wrapper.sysdef mmsystem_microzed/mmsystem_microzed.sdk/system0_wrapper.hdf
} elseif {[version -short] >= "2019.2"} {
  set_property pfm_name {} [get_files -all {mmsystem_microzed/mmsystem_microzed.srcs/sources_1/bd/system0/system0.bd}]
  write_hw_platform -fixed -include_bit -force -file mmsystem_microzed/system0_wrapper.xsa
}
