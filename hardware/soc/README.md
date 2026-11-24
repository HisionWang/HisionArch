# SoC 集成

第一版提供 CPU + JTAG AXI 双主设备、AXI 矩阵、DDR、系统控制、GPIO/LED 和 UART。
集成 RTL 位于 `rtl/`，板卡无关地址定义在 `config/base.json`。
CPU 保持在独立子项目中，主仓库实现总线与复位适配。

- `hision_cpu_axi.sv`：CPU AXI 接口和下载/重启的事务排空与复位控制。
- `hision_sysctrl.sv`：启动、DDR/总线状态、板卡 IO 参数和 scratch 寄存器。
- `hision_mmio32.sv`：一次 64 位逻辑事务到一次 32 位原生寄存器访问的适配。

系统设计、限制和后续加速器接入见 [CPU SoC 架构](../../docs/architecture/cpu-soc.md)。
地址表见 [地址映射](../../docs/interfaces/memory-map.md)，Tcl/板卡流程见
[FPGA 指南](../../docs/howto/fpga-soc.md)。当前尚无具体板卡或上板结果。
