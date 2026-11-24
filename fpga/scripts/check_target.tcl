source [file join [file dirname [info script]] common.tcl]
if {$argc != 1} { puts stderr "Usage: tclsh check_target.tcl fpga/targets/<board>/target.tcl"; exit 1 }
if {[catch {hision::validate [hision::load_target [lindex $argv 0]]} result]} {
    puts stderr $result
    exit 1
}
puts "Board configuration is complete: [dict get $result name]"
puts "This checks configuration only; Vivado must validate IP, pins, clocks and timing."
