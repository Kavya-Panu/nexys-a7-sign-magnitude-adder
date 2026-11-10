set root [file dirname [file dirname [file normalize [info script]]]]
set build_dir [file join $root build]
file mkdir $build_dir
cd $build_dir

read_verilog -sv [lsort [glob -directory [file join $root rtl] *.sv]]
read_xdc [file join $root constraints nexys_a7_100t.xdc]

synth_design -top sign_mag_test -part xc7a100tcsg324-1
opt_design
place_design
route_design

report_drc -file drc.rpt
report_io -file io.rpt
report_timing_summary -file timing.rpt
write_bitstream -force sign_mag_test.bit
