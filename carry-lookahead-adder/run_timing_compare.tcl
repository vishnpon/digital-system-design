#=====================================================================
# run_timing_compare.tcl
# Vishnupriya Ponnam
#
# Synthesizes, places and routes three 16-bit adder architectures under
# identical constraints on a Zynq-7010, then prints a comparison table of
# critical path delay and resource usage.
#
#   1. wrap_cla16 - hand-built two-level carry lookahead adder
#   2. wrap_rca16 - structural ripple carry adder
#   3. wrap_beh16 - behavioral X + Y + Cin (Vivado infers CARRY4)
#
# All three use register-in / register-out wrappers and the same .xdc, so the
# reported numbers describe the adder logic rather than the I/O ring.
#
# USAGE
#   cd into this directory, then:
#     vivado -mode batch -source run_timing_compare.tcl
#
#   Results print to the console and are written to:
#     timing_compare_out/comparison.txt        <- the summary table
#     timing_compare_out/<name>_timing.rpt     <- 10 worst paths per design
#     timing_compare_out/<name>_util.rpt       <- full utilization
#
# Runs place-and-route, not synthesis only. On FPGA, routing is a large part
# of the delay, so post-synthesis estimates would understate the differences.
# Expect a few minutes total for all three - these are tiny designs.
#=====================================================================

set PART   xc7z010clg400-1
set PERIOD 4.000

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set OUTDIR     [file join $SCRIPT_DIR timing_compare_out]
file mkdir $OUTDIR

#---------------------------------------------------------------------
# Source sets
#
# IMPORTANT: generate_propagate_unit.v is not a single module. It defines
# generate_propagate_unit, carry_lookahead_unit, summation_unit AND
# carry_lookahead_4bit. The standalone carry_lookahead_unit.v and
# summation_unit.v files in this folder define those same two modules again.
# Adding both sets is a duplicate-definition error, so only the monolith is
# listed here.
#---------------------------------------------------------------------
set SRC_COMMON [list timing_wrappers.v]

set SRC(cla) [list carry_lookahead_16bit.v \
                   generate_propagate_unit.v \
                   block_carrylookahead_unit.v]
set SRC(rca) [list ripple_carry_16bit.v]
set SRC(beh) [list behavioral_adder_16bit.v]

set TOP(cla) wrap_cla16
set TOP(rca) wrap_rca16
set TOP(beh) wrap_beh16

set LABEL(cla) "Two-level CLA (hand-built)"
set LABEL(rca) "Ripple carry (structural)"
set LABEL(beh) "Behavioral X + Y + Cin"

set ORDER {cla rca beh}

#---------------------------------------------------------------------
# Helper: count cells matching a REF_NAME pattern
#---------------------------------------------------------------------
proc count_cells {pattern} {
    return [llength [get_cells -hier -quiet -filter "REF_NAME =~ $pattern"]]
}

#---------------------------------------------------------------------
# Main loop
#---------------------------------------------------------------------
array set R {}

foreach k $ORDER {

    puts "\n=========================================================="
    puts " Building: $LABEL($k)   (top = $TOP($k))"
    puts "=========================================================="

    catch {close_project}
    create_project -in_memory -part $PART

    foreach f [concat $SRC_COMMON $SRC($k)] {
        set path [file join $SCRIPT_DIR $f]
        if {![file exists $path]} {
            error "Missing source file: $path"
        }
        read_verilog $path
    }

    read_xdc [file join $SCRIPT_DIR timing_compare.xdc]

    synth_design -top $TOP($k) -part $PART
    opt_design
    place_design
    phys_opt_design
    route_design

    #-----------------------------------------------------------------
    # Timing - worst register-to-register path through the adder
    #-----------------------------------------------------------------
    set regs [all_registers]
    set tp [get_timing_paths -quiet -delay_type max -max_paths 1 -nworst 1 \
                             -from $regs -to $regs]

    if {[llength $tp] == 0} {
        set R($k,slack) "n/a"
        set R($k,dpd)   "n/a"
        set R($k,fmax)  "n/a"
        set R($k,levels) "n/a"
        puts "WARNING: no register-to-register path found for $TOP($k)"
    } else {
        set R($k,slack) [get_property SLACK $tp]
        set R($k,dpd)   [get_property DATAPATH_DELAY $tp]
        set R($k,fmax)  [expr {1000.0 / ($PERIOD - $R($k,slack))}]
        set R($k,levels) "n/a"
        catch { set R($k,levels) [get_property LOGIC_LEVELS $tp] }
    }

    #-----------------------------------------------------------------
    # Area
    #-----------------------------------------------------------------
    set R($k,lut)   [count_cells "LUT*"]
    set R($k,carry) [count_cells "CARRY*"]
    set R($k,ff)    [count_cells "FD*"]

    #-----------------------------------------------------------------
    # Full reports for the record
    #-----------------------------------------------------------------
    report_timing -delay_type max -max_paths 10 -nworst 10 \
                  -from $regs -to $regs \
                  -file [file join $OUTDIR ${k}_timing.rpt]
    report_utilization -file [file join $OUTDIR ${k}_util.rpt]
    report_timing_summary -file [file join $OUTDIR ${k}_timing_summary.rpt]

    puts "  slack (WNS)        : $R($k,slack) ns"
    puts "  datapath delay     : $R($k,dpd) ns"
    puts "  LUTs / CARRY4 / FF : $R($k,lut) / $R($k,carry) / $R($k,ff)"
}

catch {close_project}

#---------------------------------------------------------------------
# Comparison table
#---------------------------------------------------------------------
proc fmt {v {dp 3}} {
    if {$v eq "n/a"} { return "n/a" }
    return [format "%.${dp}f" $v]
}

set lines {}
lappend lines ""
lappend lines "======================================================================================"
lappend lines " 16-bit adder architecture comparison"
lappend lines " Part: $PART      Clock target: $PERIOD ns      Post-route, register-to-register"
lappend lines "======================================================================================"
lappend lines [format " %-28s %10s %10s %8s %8s %8s %8s" \
                      "Implementation" "Path(ns)" "Fmax(MHz)" "WNS(ns)" "Levels" "LUTs" "CARRY4"]
lappend lines "--------------------------------------------------------------------------------------"

foreach k $ORDER {
    lappend lines [format " %-28s %10s %10s %8s %8s %8s %8s" \
        $LABEL($k) \
        [fmt $R($k,dpd)] \
        [fmt $R($k,fmax) 1] \
        [fmt $R($k,slack)] \
        $R($k,levels) \
        $R($k,lut) \
        $R($k,carry)]
}

lappend lines "--------------------------------------------------------------------------------------"
lappend lines ""
lappend lines " Path(ns)  = datapath delay of the worst register-to-register path (logic + routing)"
lappend lines " Fmax      = 1000 / (target period - WNS); the adder's own achievable frequency"
lappend lines " Levels    = logic levels on that path"
lappend lines " CARRY4    = dedicated fast-carry primitives used (0 means the design is pure LUT)"
lappend lines ""
lappend lines " Every FF count should be 33 (16 X + 16 Y + 1 Cin) + 17 (16 S + 1 Cout) = 50."
lappend lines " A different number means a register stage was optimized away - investigate before"
lappend lines " trusting the row."
lappend lines ""
lappend lines " Reading the result: if the behavioral version wins, that is the expected outcome and"
lappend lines " the interesting one. Vivado maps '+' onto the CARRY4 primitives hardwired into each"
lappend lines " 7-series slice, and dedicated silicon beats a LUT tree. The CLA's advantage over"
lappend lines " ripple carry is a gate-level property; on this fabric the dedicated carry chain"
lappend lines " outranks it. In an ASIC standard-cell flow, with no CARRY4 to inherit, the ordering"
lappend lines " would look different. Compare CLA against ripple carry to see the architecture"
lappend lines " argument hold, and both against behavioral to see the platform argument beat it."
lappend lines "======================================================================================"
lappend lines ""

set txt [join $lines "\n"]
puts $txt

set fh [open [file join $OUTDIR comparison.txt] w]
puts $fh $txt
close $fh

puts "Wrote [file join $OUTDIR comparison.txt]"
