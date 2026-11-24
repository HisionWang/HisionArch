# 仿真

当前 `make emu` 复用 CPU 子模块中的 `difftest/csrc/` 和固定版本 NEMU，
生成主仓库的 `build/emu`。CPU 差分协议和检查范围见
[CPU 仓库说明](../hardware/cpu/miniXiangShan/difftest/README.md)。

现有双 CPU 实验使用 `experiments/cpu-baseline/platform/` 的共享外部模型。
后续加速器/SoC 仿真器、设备模型和任务级参考模型在本目录开发。
增加真实设备或 DMA 后，需要为设备行为和内存结果建立对应检查；当前 CPU
差分环境不覆盖这些尚未实现的设备。
