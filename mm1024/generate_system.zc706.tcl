source create_mmsystem.zc706.tcl
source create_mmipcore.zc706.tcl
source design_mmsystem.zc706.tcl
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

file mkdir mmsystem_zc706/mmsystem_zc706.sdk
file copy -force mmsystem_zc706/mmsystem_zc706.runs/impl_1/system0_wrapper.sysdef mmsystem_zc706/mmsystem_zc706.sdk/system0_wrapper.hdf
