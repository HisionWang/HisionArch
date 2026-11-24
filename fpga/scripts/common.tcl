namespace eval hision {
    variable root [file normalize [file join [file dirname [info script]] ../..]]
}
proc ::hision::root {} { variable root; return $root }
proc ::hision::load_target {path} {
    set path [file normalize $path]
    if {![file isfile $path]} { error "Target config not found: $path" }
    set cfg [source $path]
    dict set cfg target_dir [file dirname $path]
    dict set cfg target_file $path
    return $cfg
}
proc ::hision::target_path {cfg value} {
    if {[file pathtype $value] eq "absolute"} { return $value }
    return [file normalize [file join [dict get $cfg target_dir] $value]]
}
proc ::hision::validate {cfg} {
    set missing {}
    foreach key {name part vivado_version axi_clock_hz ddr_bytes led_width led_active_low uart_baud xdc_files memory_provider_tcl} {
        if {![dict exists $cfg $key] || [dict get $cfg $key] eq {}} { lappend missing $key }
    }
    if {[llength $missing]} { error "Board configuration is incomplete: [join $missing {, }]. No FPGA part or board resources are assumed." }
    if {![regexp {^[a-zA-Z0-9_-]+$} [dict get $cfg name]]} { error "Use a simple target name (letters, digits, underscore, hyphen)" }
    foreach key {axi_clock_hz ddr_bytes led_width uart_baud} {
        set value [dict get $cfg $key]
        if {![string is entier -strict $value] || $value <= 0} { error "$key must be a positive integer (hex accepted)" }
    }
    set bytes [dict get $cfg ddr_bytes]
    if {$bytes < 4096 || $bytes > 0x80000000 || ($bytes & ($bytes-1)) != 0} {
        error "V1 requires a power-of-two DDR aperture from 4 KiB to 2 GiB, based at 0x80000000"
    }
    if {[dict get $cfg led_width] > 32} { error "AXI GPIO supports at most 32 LEDs" }
    if {[dict get $cfg led_active_low] ni {0 1}} { error "led_active_low must be 0 or 1" }
    foreach path [concat [dict get $cfg xdc_files] [list [dict get $cfg memory_provider_tcl]]] {
        if {![file isfile [target_path $cfg $path]]} { error "Board input does not exist: $path" }
    }
    if {[dict exists $cfg mig_prj] && [dict get $cfg mig_prj] ne {} && ![file isfile [target_path $cfg [dict get $cfg mig_prj]]]} {
        error "MIG configuration file not found"
    }
    return $cfg
}
proc ::hision::load_map {} {
    set out [file join [root] build soc]
    exec python3 [file join [root] scripts soc-config.py] --out $out
    source [file join $out soc-map.tcl]
    return $::hision_map
}
proc ::hision::ip {name instance} {
    # Resolve the IP present in this target's explicitly pinned Vivado release.
    set choices [lsort -dictionary [get_ipdefs -all -filter "VLNV =~ xilinx.com:ip:$name:*"]]
    if {![llength $choices]} { error "Required Vivado IP is unavailable: $name" }
    return [create_bd_cell -type ip -vlnv [lindex $choices end] $instance]
}
proc ::hision::net {driver args} {
    connect_bd_net $driver {*}[get_bd_pins $args]
}
proc ::hision::intf {left right} {
    connect_bd_intf_net [get_bd_intf_pins $left] [get_bd_intf_pins $right]
}
proc ::hision::single {objects label} {
    if {[llength $objects] != 1} { error "Expected exactly one $label, got: $objects" }
    return [lindex $objects 0]
}
