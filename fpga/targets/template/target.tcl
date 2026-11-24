# Copy this directory to fpga/targets/<your-board>/ and fill measured/verified values.
# Relative file paths are resolved against this file, not the shell directory.
return [dict create \
    name {} \
    part {} \
    vivado_version {} \
    axi_clock_hz {} \
    ddr_bytes {} \
    led_width {} \
    led_active_low {} \
    uart_baud {} \
    xdc_files {} \
    memory_provider_tcl {} \
    mig_prj {} \
]
