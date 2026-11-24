# Match the CPU's actual blackbox names and dimensions. Inferred FPGA BRAMs
# preserve 1-cycle L1/BPU reads and 2-cycle L2 reads without editing the CPU.
proc ::hision::cpu_memories {rtl_dir output} {
    set names {}
    foreach path [glob -directory $rtl_dir *.v] {
        set stream [open $path r]; set code [read $stream]; close $stream
        foreach name [regexp -all -inline {(?:BlockRAM|L2_bram|L2_meta)_[0-9]+x[0-9]+} $code] {
            dict set names $name 1
        }
    }
    if {![dict size $names]} { error "No CPU FPGA RAM blackboxes found in $rtl_dir; generate MODE=soc" }
    set stream [open $output w]
    puts $stream "// Generated from the elaborated CPU blackbox names."
    foreach name [lsort [dict keys $names]] {
        regexp {^(BlockRAM|L2_bram|L2_meta)_([0-9]+)x([0-9]+)$} $name -> family depth width
        set latency [expr {$family eq "BlockRAM" ? 1 : 2}]
        set addr_bits 0
        while {(1 << $addr_bits) < $depth} { incr addr_bits }
        set aw [expr {$addr_bits-1}]; set dw [expr {$width-1}]
        puts $stream "module $name (input wire clka,ena,wea, input wire \[$aw:0\] addra, input wire \[$dw:0\] dina, input wire clkb,rstb,enb, input wire \[$aw:0\] addrb, output wire \[$dw:0\] doutb);"
        puts $stream "  (* ram_style = \"block\" *) reg \[$dw:0\] mem \[0:[expr {$depth-1}]\];"
        puts $stream "  reg \[$dw:0\] rd0 = 0;"
        puts $stream "  integer i; initial for (i=0; i<$depth; i=i+1) mem\[i\]=0;"
        puts $stream {  always @(posedge clka) if (ena && wea) mem[addra] <= dina;}
        puts $stream {  always @(posedge clkb) if (rstb) rd0 <= 0; else if (enb) rd0 <= mem[addrb];}
        if {$latency == 2} {
            puts $stream "  reg \[$dw:0\] rd1 = 0;"
            puts $stream {  always @(posedge clkb) if (rstb) rd1 <= 0; else if (enb) rd1 <= rd0;}
            puts $stream {  assign doutb = rd1;}
        } else { puts $stream {  assign doutb = rd0;} }
        puts $stream "endmodule"
    }
    close $stream
    return [lsort [dict keys $names]]
}
