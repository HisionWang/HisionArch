# HisionArch

围绕 RISC-V CPU 构建的加速器与存储系统研究平台。当前重点是加速器计算、
任务卸载、数据搬运、共享存储与 FPGA 系统集成。

CPU 为作者自研的 [miniXiangShan](https://github.com/XiangShanLab/miniXiangShan)，
作为独立维护的 CPU 子项目，通过 `hardware/cpu/miniXiangShan` Git submodule 固定版本接入。
本仓库维护平台配置、加速器与 SoC 集成、软件和实验。

## 当前能力

已有 CPU 仿真构建、NEMU 差分接入、裸机 hello/CoreMark 与双 CPU 基线实验。
加速器、DMA、完整 SoC、板卡工程、PCB 与外壳目前处于规划阶段。
具体范围见 [当前状态](docs/status.md) 与 [路线图](docs/roadmap.md)。

## 开始使用

克隆时带上子模块；已有工作区执行 `make deps`：

```bash
git clone --recurse-submodules <HisionArch-repository-url>
cd HisionArch
make deps
make emu
make app APP=hello
make run APP=hello
```

`make emu` 默认启用 NEMU 差分和波形支持。只构建轻量 CPU 仿真器可使用
`make emu WITH_DIFFTEST=0 WITH_WAVE=0`。应用与仿真器分别构建。
根目录直接执行 `make` 显示帮助。环境要求和详细命令见
[构建与仿真](docs/howto/build-and-simulate.md)。

## 开发位置

| 路径 | 内容 |
| --- | --- |
| [hardware/cpu/](hardware/cpu/README.md) | 自研 CPU 子项目与版本管理 |
| [hardware/accelerators/](hardware/accelerators/README.md) | 自有加速器硬件 |
| [hardware/soc/](hardware/soc/README.md) | CPU、加速器、外设与互联集成 |
| [hardware/memory/](hardware/memory/README.md) | DMA、访存调度与内存侧组件 |
| [hardware/common/](hardware/common/README.md) | 公共硬件接口与组件 |
| [hardware/platform/](hardware/platform/README.md) | 平台配置和 RTL 生成入口 |
| [software/](software/README.md) | 运行库、驱动、应用和 CPU 参考实现 |
| [sim/](sim/README.md) | 仿真接入与后续系统模型 |
| [experiments/](experiments/README.md) | 研究方法、配置、分析与报告 |
| [fpga/](fpga/README.md) | FPGA 目标、约束与 IP 配置 |
| [boards/](boards/README.md)、[mechanical/](mechanical/README.md) | 实体板卡与机械设计 |
| [docs/](docs/README.md) | 架构、接口、操作指南、决策与研究记录 |

`build.sbt` 直接编译各 `hardware/<area>/src/main/scala/` 和 CPU 子模块源码。
现有运行库位于 `software/runtime/`，应用位于 `software/apps/`。
原 `compare/` 已迁为 `experiments/cpu-baseline/`，作为可选基线保留。

## 常用入口

```bash
make help
make rtl MODE=emu
make rtl MODE=fpga
make app APP=coremark ITERATIONS=10
make cpu-baseline APP=coremark
```

`MODE=fpga` 仅生成核 RTL，尚未提供可烧录的整机工程。
双 CPU 比较的计时与公平性边界见
[实验方法](experiments/cpu-baseline/METHODOLOGY.md)。

`make clean` 清理根构建产物和 Scala 缓存；`make clean-all` 还清理应用和
CPU 对比构建。子模块、依赖缓存、实验结果和 `project/build.properties` 保留。
依赖来源见 [PROVENANCE.md](PROVENANCE.md)。
