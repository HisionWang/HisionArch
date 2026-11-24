# Optional provider for a board explicitly using 7-series MIG.
# Select this file in target.tcl ONLY after choosing the device and generating
# its real MIG .prj (DDR part, pinout, input clocks, UI rate and reset polarity).
proc ::hision::create_memory {cfg} {
    if {![dict exists $cfg mig_prj] || [dict get $cfg mig_prj] eq {}} {
        error "The MIG7 provider requires the board's actual mig_prj file"
    }
    set mig [ip mig_7series memory]
    set_property CONFIG.XML_INPUT_FILE [target_path $cfg [dict get $cfg mig_prj]] $mig
    # MIG owns physical DDR ports and its input clock/reset topology. Expose
    # unconnected physical interfaces and inputs instead of guessing pin types.
    foreach intf [get_bd_intf_pins -of_objects $mig -filter {MODE == Master}] {
        make_bd_intf_pins_external $intf
    }
    foreach intf [get_bd_intf_pins -of_objects $mig -filter {VLNV =~ *:diff_clock*:*}] {
        if {![llength [get_bd_intf_nets -quiet -of_objects $intf]]} { make_bd_intf_pins_external $intf }
    }
    foreach name {sys_clk_i sys_clk_p sys_clk_n clk_ref_i clk_ref_p clk_ref_n sys_rst} {
        set pin [get_bd_pins -quiet memory/$name]
        if {[llength $pin] && ![llength [get_bd_nets -quiet -of_objects $pin]]} { make_bd_pins_external $pin }
    }
    set rst [ip proc_sys_reset reset]
    set_property CONFIG.C_EXT_RESET_HIGH 1 $rst
    ip xlconstant zero
    set_property -dict [list CONFIG.CONST_WIDTH 1 CONFIG.CONST_VAL 0] [get_bd_cells zero]
    ip xlconstant one
    set_property -dict [list CONFIG.CONST_WIDTH 1 CONFIG.CONST_VAL 1] [get_bd_cells one]
    net [get_bd_pins memory/ui_clk] reset/slowest_sync_clk
    net [get_bd_pins memory/ui_clk_sync_rst] reset/ext_reset_in
    net [get_bd_pins zero/dout] reset/aux_reset_in reset/mb_debug_sys_rst
    net [get_bd_pins one/dout] reset/dcm_locked
    net [get_bd_pins reset/peripheral_aresetn] memory/aresetn
    return [dict create \
        axi memory/S_AXI \
        clk memory/ui_clk \
        aresetn reset/peripheral_aresetn \
        calibrated memory/init_calib_complete \
        segment [single [get_bd_addr_segs -of_objects [get_bd_intf_pins memory/S_AXI]] {MIG DDR segment}]]
}
