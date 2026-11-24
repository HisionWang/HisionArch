# 当前状态

## 已接入

- CPU：自研 miniXiangShan 位于 `hardware/cpu/miniXiangShan`，以固定 Git submodule
  维护独立版本；父仓库直接编译其源码。
- 平台：独立生成入口支持 `emu`、`compare`、`fpga`、`soc`。新 `soc` 模式从 DDR
  起始地址复位，采用 FPGA RAM 黑盒，不引入仿真差分接口。
- 仿真：CPU 差分驱动和 NEMU 固定版本构建逻辑。
- 软件：hello/CoreMark 与仿真裸机运行环境；真实 SoC 独立启动、UART/LED 驱动和
  `soc_demo` 程序（串口回显、LED 心跳）。
- 实验：CPU 对比在 `experiments/cpu-baseline/`；memory-offload 仍为实验草案。

## CPU SoC：已有实现，待板卡集成

已写入 CPU AXI/复位控制、系统寄存器、64→32 位外设寄存器适配 RTL，以及 Tcl 创建的
2 主 4 从 AXI 矩阵、JTAG AXI、DDR 接口、GPIO 和 UART 连接。
地址由统一 JSON 生成。Tcl 流程包括目标配置校验、工程/BD/IP 创建、BRAM 适配、综合、
实现、报告、bitstream、显式硬件配置和 JTAG 下载/读回/启动。

默认目标刻意不填写 FPGA part、Vivado 版本、DDR、时钟、LED、串口或引脚。
提供 MIG7 的可选适配，需要实际 `.prj` 和 XDC。没有具体板卡工程或可烧录 bitstream。
架构和限制见 [CPU SoC](architecture/cpu-soc.md)，接板流程见
[FPGA 指南](howto/fpga-soc.md)。

## 构建与静态检查范围

既有构建记录：默认/轻量 `make emu`、hello/CoreMark、双 CPU 性能仿真器编译成功。
这些记录只说明相应构建过程完成，不代表新 SoC 的功能结果。

本次 CPU SoC 工作完成：

- `make soc-rtl`：CPU FPGA RTL 生成成功，复位地址为 `0x80000000`。
- `make soc-app`：RV64 裸机程序编译、链接、BIN 与反汇编生成成功。
- 使用生成的 RAM 适配对 CPU 包装和 CPU RTL 作 Verilator 静态编译检查；系统控制与
  外设适配 RTL 语法检查通过。保留仅使用低地址位/部分总线字段的未使用信号提示。
- Tcl 库加载、脚本结构和 shell 语法检查完成；空模板正确报告缺少板卡配置。

当前环境未发现 Vivado；没有执行 IP/BD 生成、综合、实现、Hardware Manager 或上板。
没有新增或运行功能测试。AXI 协议行为、BRAM 推断、DDR 配置/校准、时序和程序执行
均待后续验证，不能将 RTL 静态检查视为完整 SoC 验证。

## 后续

优先补齐真实板卡配置，完成 CPU SoC 综合、时序收敛与 JTAG/DDR/UART/LED 上板。
之后接入加速器、DMA、共享数据协议和性能观测。
持久存储启动、操作系统、PCB 与外壳尚未实现。

CPU 仿真差分的检查范围见
[CPU 仓库 difftest 说明](../hardware/cpu/miniXiangShan/difftest/README.md)。
