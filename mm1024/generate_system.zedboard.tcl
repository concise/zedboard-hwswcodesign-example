source create_mmsystem.zedboard.tcl
source create_mmipcore.zedboard.tcl
source design_mmsystem.zedboard.tcl
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

file mkdir mmsystem_zedboard/mmsystem_zedboard.sdk
file copy -force mmsystem_zedboard/mmsystem_zedboard.runs/impl_1/system0_wrapper.sysdef mmsystem_zedboard/mmsystem_zedboard.sdk/system0_wrapper.hdf
