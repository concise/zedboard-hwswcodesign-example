source create_mmsystem.microzed.tcl
source create_mmipcore.microzed.tcl
source design_mmsystem.microzed.tcl
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

file mkdir mmsystem_microzed/mmsystem_microzed.sdk
file copy -force mmsystem_microzed/mmsystem_microzed.runs/impl_1/system0_wrapper.sysdef mmsystem_microzed/mmsystem_microzed.sdk/system0_wrapper.hdf
