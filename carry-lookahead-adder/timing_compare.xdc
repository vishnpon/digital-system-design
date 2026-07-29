#=====================================================================
# timing_compare.xdc
# Vishnupriya Ponnam
#
# Shared constraints for the three-way adder timing comparison. This exact
# file is applied to wrap_cla16, wrap_rca16 and wrap_beh16 with no changes,
# so the only variable between runs is the adder architecture.
#
# Target: Zynq-7010, xc7z010clg400-1 (Zybo Z7-10)
#=====================================================================

#---------------------------------------------------------------------
# Clock
#
# 4 ns (250 MHz) is deliberately aggressive for this part. The point is not
# to meet it - it is to keep the optimizer working equally hard on all three
# designs. If the target were slack-positive and easy, the tool would stop
# optimizing early and the comparison would measure "good enough" rather
# than "as fast as this architecture goes."
#
# Fmax is derived afterwards from the reported slack:
#     Fmax = 1000 / (4.000 - WNS)   [MHz, with WNS in ns]
#---------------------------------------------------------------------
create_clock -period 4.000 -name Clk -waveform {0.000 2.000} [get_ports Clk]

#---------------------------------------------------------------------
# Exclude the I/O ring
#
# This is the reason the wrappers exist. Without these, the worst path in the
# design is pad -> IBUF -> input register (or output register -> OBUF -> pad),
# which on 7-series is dominated by buffer and package delay and would swamp
# the adder logic we are actually trying to compare.
#
# False-pathing every port leaves the register-to-register paths through the
# adder as the only timed paths, so WNS is a clean measure of the adder.
#---------------------------------------------------------------------
set_false_path -from [get_ports {X_d[*]}]
set_false_path -from [get_ports {Y_d[*]}]
set_false_path -from [get_ports Cin_d]
set_false_path -to   [get_ports {S_q[*]}]
set_false_path -to   [get_ports Cout_q]

#---------------------------------------------------------------------
# No pin assignments on purpose
#
# Placement of the I/O is irrelevant to a register-to-register measurement,
# and pinning the ports would only constrain the placer for no benefit. This
# design is never meant to be programmed onto the board - it exists to be
# synthesized, placed, routed and measured.
#---------------------------------------------------------------------
