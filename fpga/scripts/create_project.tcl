source [file join [file dirname [info script]] common.tcl]
source [file join [file dirname [info script]] cpu_memories.tcl]
source [file join [file dirname [info script]] build_bd.tcl]
if {$argc < 1 || $argc > 3} { error "Usage: create_project.tcl target.tcl ?project|synth|bitstream? ?jobs?" }
set cfg [hision::validate [hision::load_target [lindex $argv 0]]]
set action [expr {$argc >= 2 ? [lindex $argv 1] : "project"}]
set jobs [expr {$argc >= 3 ? [lindex $argv 2] : 4}]
if {$action ni {project synth bitstream}} { error "Unknown action $action" }
if {![string is integer -strict $jobs] || $jobs < 1} { error "jobs must be positive" }
if {[version -short] ne [dict get $cfg vivado_version]} {
    error "Target pins Vivado [dict get $cfg vivado_version]; current tool is [version -short]"
}
set root [hision::root]
set rtl [file join $root build rtl soc]
if {![file isfile [file join $rtl core_top.v]]} { error "Run make soc-rtl first" }
set map [hision::load_map]
set dir [file join $root build fpga [dict get $cfg name]]
if {[file exists [file join $dir hision_soc.xpr]]} {
    error "Generated project already exists: $dir. Remove that generated directory before recreating it."
}
file mkdir $dir
create_project hision_soc $dir -part [dict get $cfg part]
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set memories [hision::cpu_memories $rtl [file join $dir cpu_memories.v]]
add_files -norecurse [glob -directory $rtl *.v]
add_files -norecurse [glob -directory [file join $root hardware soc rtl] *.sv]
add_files -norecurse [file join $dir cpu_memories.v]
set_property include_dirs [list [file join $root build soc]] [get_filesets sources_1]
foreach xdc [dict get $cfg xdc_files] { add_files -fileset constrs_1 [hision::target_path $cfg $xdc] }
update_compile_order -fileset sources_1
hision::build_bd $cfg $map
set bd [get_files */hision_soc.bd]
generate_target all $bd
add_files -norecurse [make_wrapper -files $bd -top]
set_property top hision_soc_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1
set stream [open [file join $dir build-manifest.txt] w]
puts $stream "Vivado: [version -short]"
puts $stream "Target: $cfg"
puts $stream "Map: $map"
puts $stream "CPU revision: [exec git -C [file join $root hardware cpu miniXiangShan] rev-parse HEAD]"
puts $stream "CPU memories: $memories"
foreach cell [get_bd_cells -hier -filter {TYPE == ip}] { puts $stream "$cell [get_property VLNV $cell]" }
close $stream
puts "Created [file join $dir hision_soc.xpr]"
if {$action eq "project"} { close_project; exit }
launch_runs synth_1 -jobs $jobs
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} { error "Synthesis failed; inspect synth_1 logs" }
if {$action eq "synth"} { close_project; exit }
launch_runs impl_1 -to_step route_design -jobs $jobs
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} { error "Implementation failed; inspect impl_1 logs" }
open_run impl_1
report_timing_summary -file [file join $dir timing.rpt]
report_utilization -file [file join $dir utilization.rpt]
report_drc -file [file join $dir drc.rpt]
foreach delay {max min} {
    set path [get_timing_paths -delay_type $delay -max_paths 1]
    if {![llength $path] || [get_property SLACK $path] < 0} {
        error "Timing is missing or failed ($delay); inspect timing.rpt before producing a bitstream"
    }
}
write_bitstream [file join $dir hision_soc.bit]
close_project
puts "Bitstream: [file join $dir hision_soc.bit]"
