proc ::hision::build_bd {cfg map} {
    create_bd_design hision_soc
    uplevel #0 [list source [target_path $cfg [dict get $cfg memory_provider_tcl]]]
    if {![llength [info procs ::hision::create_memory]]} { error "Provider must define hision::create_memory cfg" }
    set memory [create_memory $cfg]
    foreach key {axi clk aresetn calibrated segment} {
        if {![dict exists $memory $key]} { error "Memory provider did not return $key" }
    }
    create_bd_cell -type module -reference hision_cpu_axi cpu
    create_bd_cell -type module -reference hision_sysctrl sysctrl
    set_property -dict [list CONFIG.AXI_CLOCK_HZ [dict get $cfg axi_clock_hz] \
        CONFIG.LED_WIDTH [dict get $cfg led_width] CONFIG.LED_ACTIVE_LOW [dict get $cfg led_active_low]] [get_bd_cells sysctrl]
    create_bd_cell -type module -reference hision_mmio32 gpio_regs
    create_bd_cell -type module -reference hision_mmio32 uart_regs
    set_property CONFIG.REGISTER_COUNT 2 [get_bd_cells gpio_regs]
    set xbar [ip axi_interconnect matrix]
    set_property -dict [list CONFIG.NUM_SI 2 CONFIG.NUM_MI 4 CONFIG.STRATEGY 2 CONFIG.XBAR_DATA_WIDTH 64] $xbar
    set jtag [ip jtag_axi jtag]
    # PG174: AXI4 protocol, 32-bit debug transfers. Do not use deprecated -size
    # in Hardware Manager; transfer size is selected here in the IP.
    set_property CONFIG.PROTOCOL 0 $jtag
    foreach property {CONFIG.M_AXI_DATA_WIDTH CONFIG.M_AXI_ADDR_WIDTH} {
        if {$property in [list_property $jtag]} { set_property $property 32 $jtag }
    }
    set gpio [ip axi_gpio leds]
    set_property -dict [list CONFIG.C_GPIO_WIDTH [dict get $cfg led_width] CONFIG.C_ALL_OUTPUTS 1 \
        CONFIG.C_IS_DUAL 0 CONFIG.C_INTERRUPT_PRESENT 0 \
        CONFIG.C_DOUT_DEFAULT [format 0x%08x [expr {[dict get $cfg led_active_low] ? 0xffffffff : 0}]]] $gpio
    set uart [ip axi_uartlite uart]
    set_property -dict [list CONFIG.C_BAUDRATE [dict get $cfg uart_baud] CONFIG.C_DATA_BITS 8 CONFIG.C_USE_PARITY 0 CONFIG.C_ODD_PARITY 0 \
        CONFIG.C_S_AXI_ACLK_FREQ_HZ [dict get $cfg axi_clock_hz]] $uart
    intf cpu/M_AXI matrix/S00_AXI
    intf jtag/M_AXI matrix/S01_AXI
    intf matrix/M00_AXI [dict get $memory axi]
    intf matrix/M01_AXI sysctrl/S_AXI
    intf matrix/M02_AXI gpio_regs/S_AXI
    intf matrix/M03_AXI uart_regs/S_AXI
    intf gpio_regs/M_AXI leds/S_AXI
    intf uart_regs/M_AXI uart/S_AXI
    set clk [get_bd_pins [dict get $memory clk]]
    set resetn [get_bd_pins [dict get $memory aresetn]]
    net $clk cpu/aclk sysctrl/aclk gpio_regs/aclk uart_regs/aclk jtag/aclk leds/s_axi_aclk uart/s_axi_aclk \
        matrix/ACLK matrix/S00_ACLK matrix/S01_ACLK matrix/M00_ACLK matrix/M01_ACLK matrix/M02_ACLK matrix/M03_ACLK
    net $resetn cpu/aresetn sysctrl/aresetn gpio_regs/aresetn uart_regs/aresetn jtag/aresetn leds/s_axi_aresetn uart/s_axi_aresetn \
        matrix/ARESETN matrix/S00_ARESETN matrix/S01_ARESETN matrix/M00_ARESETN matrix/M01_ARESETN matrix/M02_ARESETN matrix/M03_ARESETN
    net [get_bd_pins [dict get $memory calibrated]] cpu/calibrated sysctrl/calibrated
    net [get_bd_pins sysctrl/run_requested] cpu/run_requested
    foreach signal {cpu_in_reset bus_busy bus_error} { net [get_bd_pins cpu/$signal] sysctrl/$signal }
    set led_port [create_bd_port -dir O -from [expr {[dict get $cfg led_width]-1}] -to 0 led]
    connect_bd_net $led_port [get_bd_pins leds/gpio_io_o]
    set tx [create_bd_port -dir O uart_tx]
    set rx [create_bd_port -dir I uart_rx]
    connect_bd_net $tx [get_bd_pins uart/tx]
    connect_bd_net $rx [get_bd_pins uart/rx]

    # Decode terminates at the stride adapters. Their native GPIO/UART address
    # spaces map to zero separately; CPU-visible register strides are 8 bytes.
    foreach entry {{gpio_regs leds} {uart_regs uart}} {
        lassign $entry bridge device
        set space [single [get_bd_addr_spaces -of_objects [get_bd_intf_pins $bridge/M_AXI]] "$bridge address space"]
        set seg [single [get_bd_addr_segs -of_objects [get_bd_intf_pins $device/S_AXI]] "$device segment"]
        assign_bd_address -offset 0 -range [dict get $map peripheral_span] -target_address_space $space $seg
    }
    set slaves [list \
        [list [dict get $memory segment] [dict get $map ddr_base] [dict get $cfg ddr_bytes]] \
        [list [single [get_bd_addr_segs -of_objects [get_bd_intf_pins sysctrl/S_AXI]] sysctrl] [dict get $map sysctrl_base] [dict get $map peripheral_span]] \
        [list [single [get_bd_addr_segs -of_objects [get_bd_intf_pins gpio_regs/S_AXI]] gpio_regs] [dict get $map gpio_base] [dict get $map peripheral_span]] \
        [list [single [get_bd_addr_segs -of_objects [get_bd_intf_pins uart_regs/S_AXI]] uart_regs] [dict get $map uart_base] [dict get $map peripheral_span]]]
    foreach master {cpu/M_AXI jtag/M_AXI} {
        set space [single [get_bd_addr_spaces -of_objects [get_bd_intf_pins $master]] "$master address space"]
        foreach slave $slaves {
            lassign $slave seg base size
            assign_bd_address -offset $base -range $size -target_address_space $space $seg
        }
    }
    validate_bd_design
    foreach property {DATA_WIDTH ADDR_WIDTH} {
        if {[get_property CONFIG.$property [get_bd_intf_pins jtag/M_AXI]] != 32} {
            error "JTAG $property must be 32 for the supplied Hardware Manager scripts"
        }
    }
    set actual_hz [get_property CONFIG.FREQ_HZ $clk]
    if {$actual_hz eq {} || $actual_hz != [dict get $cfg axi_clock_hz]} {
        error "Memory UI clock ($actual_hz Hz) disagrees with target axi_clock_hz"
    }
    save_bd_design
}
