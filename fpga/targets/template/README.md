# 待选板卡模板

这里有意保留器件、工具版本、时钟、DDR、LED、串口、XDC 和 memory provider 空值。
复制到真实目标目录后填写；`make fpga-check` 会列出所有缺项。

详细字段、MIG7 可选适配、自定义 DDR 契约和 Tcl 操作流程见
[FPGA SoC 指南](../../../docs/howto/fpga-soc.md)。

本目录不提供占位引脚或虚构时钟约束。实体板卡规格、原理图、供电和修订记录放在
`boards/<board>/`，这里维护与 Vivado 工程重建直接相关的输入。
