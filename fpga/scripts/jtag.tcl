# Source in Vivado Hardware Manager after programming the FPGA.
source [file join [file dirname [info script]] common.tcl]
namespace eval hision::debug { variable axis {}; variable cfg {}; variable map {} }
proc ::hision::debug::attach {target_file {axis_name {}}} {
    variable cfg; variable map; variable axis
    set cfg [::hision::validate [::hision::load_target $target_file]]
    set map [::hision::load_map]
    set candidates [get_hw_axis -quiet]
    if {$axis_name ne {}} { set candidates [get_hw_axis -quiet $axis_name] }
    set axis [::hision::single $candidates {JTAG AXI master (pass its exact name if there are several)}]
    reset_hw_axi $axis
    set id [read32 [expr {[dict get $map sysctrl_base]+[dict get $map sys_id_offset]}]]
    if {$id != [dict get $map sys_id]} { error [format "Unexpected SoC ID: 0x%08x" $id] }
    puts "Attached to $axis; CPU state: [status]"
}
proc ::hision::debug::transaction {type address {value 0}} {
    variable axis
    if {$axis eq {}} { error "Call hision::debug::attach first" }
    if {$address < 0 || $address > 0xfffffffc || ($address & 3)} { error "Unaligned or out-of-range 32-bit AXI address" }
    set name hision_debug_word
    set old [get_hw_axi_txns -quiet $name]
    if {[llength $old]} { delete_hw_axi_txn $old }
    set options [list -type $type -address [format %08x $address] -len 1 -cache 0]
    if {$type eq "WRITE"} { lappend options -data [format %08x [expr {$value & 0xffffffff}]] }
    set txn [create_hw_axi_txn $name $axis {*}$options]
    set code [catch {
        run_hw_axi $txn
        set result {}
        if {$type eq "READ"} {
            set data [string map {_ {} { } {}} [get_property DATA $txn]]
            if {![regexp {^[0-9a-fA-F]{1,8}$} $data]} { error "Unexpected read data: $data" }
            set result [expr 0x$data]
        }
        set result
    } result options]
    delete_hw_axi_txn $txn
    if {$code} { return -options $options $result }
    return $result
}
proc ::hision::debug::read32 {address} { transaction READ $address }
proc ::hision::debug::write32 {address value} { transaction WRITE $address $value }
proc ::hision::debug::status {} {
    variable map
    set value [read32 [expr {[dict get $map sysctrl_base]+[dict get $map sys_status_offset]}]]
    return [dict create ddr_ready [expr {$value & 1}] cpu_in_reset [expr {($value>>1)&1}] \
        bus_busy [expr {($value>>2)&1}] run_requested [expr {($value>>3)&1}] bus_error [expr {($value>>4)&1}]]
}
proc ::hision::debug::stop {{timeout_ms 10000}} {
    variable map
    write32 [expr {[dict get $map sysctrl_base]+[dict get $map sys_control_offset]}] 0
    set deadline [expr {[clock milliseconds]+$timeout_ms}]
    while {![dict get [status] cpu_in_reset]} {
        if {[clock milliseconds] > $deadline} { error "CPU AXI drain timed out; inspect DDR/fabric or apply board reset" }
        after 10
    }
}
proc ::hision::debug::wait_ddr {{timeout_ms 30000}} {
    set deadline [expr {[clock milliseconds]+$timeout_ms}]
    while {![dict get [status] ddr_ready]} {
        if {[clock milliseconds] > $deadline} { error "DDR calibration timed out" }
        after 10
    }
}
proc ::hision::debug::load_bin {path} {
    variable map; variable cfg
    stop
    wait_ddr
    set stream [open $path rb]
    set image [read $stream]
    close $stream
    set bytes [string length $image]
    if {$bytes == 0 || (($bytes+3)&~3) > [dict get $cfg ddr_bytes]} { error "Empty image or image exceeds DDR aperture" }
    append image [string repeat \x00 [expr {(-$bytes)&3}]]
    set base [dict get $map ddr_base]
    # Explicit little-endian words, one transfer each; no burst word-order
    # assumptions. V1 favors straightforward download/readback over speed.
    for {set off 0} {$off < [string length $image]} {incr off 4} {
        binary scan [string range $image $off [expr {$off+3}]] c4 octets
        lassign $octets a b c d
        set value [expr {($a&255)|(($b&255)<<8)|(($c&255)<<16)|(($d&255)<<24)}]
        write32 [expr {$base+$off}] $value
        set actual [read32 [expr {$base+$off}]]
        if {$actual != $value} { error [format "Readback mismatch at 0x%x" [expr {$base+$off}]] }
    }
    puts "Loaded and read back $bytes bytes at [format 0x%x $base]; CPU remains in reset"
}
proc ::hision::debug::run {} {
    variable map
    wait_ddr
    if {![dict get [status] cpu_in_reset]} { error "Stop/reset the CPU before a cold start" }
    write32 [expr {[dict get $map sysctrl_base]+[dict get $map sys_control_offset]}] 1
    puts "CPU released at [format 0x%x [dict get $map reset_pc]]"
}
