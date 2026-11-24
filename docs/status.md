# 当前状态

## 已接入

- CPU：自研 miniXiangShan 位于 `hardware/cpu/miniXiangShan`，以固定 Git submodule
  维护独立版本；父仓库直接编译其源码。
- 平台：HisionArch 独立生成入口支持 `emu`、`compare`、`fpga` 三种 RTL 配置。
- 仿真：复用 CPU 差分驱动和 NEMU 固定版本构建逻辑。
- 软件：独立构建的 hello/CoreMark 与公共裸机运行环境。
- 实验：原 CPU 对比迁入 `experiments/cpu-baseline/`，原有输出保留。

## 规划中

加速器、DMA、共享数据协议的硬件实现、完整 SoC、真实 DDR/外设、板卡工程、
持久存储启动、操作系统、PCB 和外壳均尚未实现。
`experiments/memory-offload/` 是实验设计草案。

## 验证范围

本次重组前，已逐字节确认本地原始非忽略源码与选定 CPU 仓库版本一致。
目录重组后已完成以下构建：

- `make emu WITH_DIFFTEST=0 WITH_WAVE=0 JOBS=8`：RTL 生成与轻量仿真器编译成功。
- `make emu JOBS=8`：默认 NEMU 参考、差分与波形支持的仿真器编译成功。
- `make app APP=hello` 与 `make app APP=coremark ITERATIONS=10`：应用编译成功。
- `make -C experiments/cpu-baseline build JOBS=8`：双 CPU 性能仿真器编译成功。

CPU 子项目迁入 `hardware/cpu/` 后，已重新通过 `make deps`、默认 `make emu`
与双 CPU 性能仿真器构建。

脚本语法、文档本地链接与忽略规则已检查；本次未运行功能测试或性能实验。
FPGA 模式尚未在本次重组中生成、综合或上板。
历史实验输出中的路径和计数属于此前运行，不能作为新结构的验证结果。

现有 CPU 仿真差分的检查范围、设备模型限制和异常边界见
[CPU 仓库 difftest 说明](../hardware/cpu/miniXiangShan/difftest/README.md)。
