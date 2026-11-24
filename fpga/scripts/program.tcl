# Hardware programming is explicit; no build target invokes this script.
if {$argc < 1 || $argc > 4} { error "Usage: program.tcl file.bit ?target-name? ?device-name? ?hw-server-url?" }
set bit [file normalize [lindex $argv 0]]
if {![file isfile $bit]} { error "Bitstream not found: $bit" }
open_hw_manager
if {$argc == 4} { connect_hw_server -url [lindex $argv 3] } else { connect_hw_server }
set targets [get_hw_targets -quiet]
if {$argc >= 2 && [lindex $argv 1] ne {}} { set targets [get_hw_targets -quiet [lindex $argv 1]] }
if {[llength $targets] != 1} { error "Select one hardware target explicitly; available: [get_hw_targets]" }
current_hw_target [lindex $targets 0]
open_hw_target
set devices [get_hw_devices -quiet]
if {$argc >= 3 && [lindex $argv 2] ne {}} { set devices [get_hw_devices -quiet [lindex $argv 2]] }
if {[llength $devices] != 1} { error "Select one FPGA device explicitly; available: [get_hw_devices]" }
set device [lindex $devices 0]
current_hw_device $device
set_property PROGRAM.FILE $bit $device
program_hw_devices $device
refresh_hw_device $device
