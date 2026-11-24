# SoC 集成

这里负责 CPU、加速器、存储和外设的连接，包括总线适配、地址解码、中断、
时钟复位与系统顶层。当前尚未实现完整 SoC。

CPU 固定版本的接口约束见 [CPU 接口](../../docs/interfaces/cpu.md)。
地址空间见 [地址映射](../../docs/interfaces/memory-map.md)。
板卡专用时钟、引脚和厂商 IP 适配放在 `fpga/`。
