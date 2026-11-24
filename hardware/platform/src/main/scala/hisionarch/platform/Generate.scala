package hisionarch.platform

import chisel3._
import java.io.File
import minixiangshan.config._

/** Project-owned elaboration boundary; CPU internals remain in the submodule. */
object Generate extends App {
  require(args.length <= 1, "Usage: Generate [emu|compare|fpga]")
  val mode = args.headOption.getOrElse("emu")
  require(Set("emu", "compare", "fpga").contains(mode), s"Unknown mode: $mode")
  val output = new File(sys.env.getOrElse("RTL_DIR", "build/rtl"),
    if (mode == "compare") "compare/mini" else mode)
  require(output.isDirectory || output.mkdirs(), s"Cannot create $output")

  implicit val parameters: Parameters = new Parameters(Map(
    DebugConfigKeys.EnableDifftest -> (mode == "emu"),
    DebugConfigKeys.DifftestUseDPI -> false,
    DebugConfigKeys.UseBehavioralMemories -> (mode != "fpga"),
    CoreConfigKeys.ResetPC -> (if (mode == "fpga") CoreConfigKeys.ResetPC.default
      else BigInt("80000000", 16)),
    CoreConfigKeys.XLEN -> 64
  ))

  def top: NSRawModule = if (mode == "compare") new minixiangshan.perf.MiniPerfTop
    else new minixiangshan.core_top

  emitVerilog(top, Array("--target-dir", output.getPath, "--emit-modules", "verilog"))
  println(s"HisionArch $mode RTL: ${output.getPath}")
}
