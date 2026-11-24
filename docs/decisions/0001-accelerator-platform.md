# 0001：以加速器与系统集成为主的仓库布局

状态：已采用。

## 背景

研究重点为加速器与近存计算，需要稳定 CPU 基线、可修改的系统边界和可复现
实验。原工作区同时包含 CPU、差分、应用与双 CPU 性能工程，尚无父仓库提交。
原非忽略源码与 miniXiangShan 的 `d74cd2250d3def52471cc410d4cc9fef4d320fed`
完全一致，适合直接接入该仓库。

## 决策

miniXiangShan 是作者独立维护的自研 CPU，使用
`hardware/cpu/miniXiangShan` Git submodule 接入，父仓库固定提交。
主仓库 `build.sbt` 直接编译其源码，自有硬件放在 `hardware/`，自有配置入口
放在 `hardware/platform/`。CPU 仿真驱动与 NEMU ABI 从同一 CPU 版本复用。

原应用迁到 `software/apps/`，公共运行库迁到 `software/runtime/`。
原 `compare/` 迁到 `experiments/cpu-baseline/`，保留适配补丁、方法与已有结果。
加速器卸载实验在 `experiments/memory-offload/` 逐步实现。

全局架构、接口、指南与决策在 `docs/`；局部设计随模块维护，结果随实验维护。
保留固定的 `project/build.properties`，常规清理保留依赖、结果与源配置。

## 影响

CPU 升级作为明确依赖变更处理。自有 Chisel 代码需兼容当前 CPU 使用的工具链。
现阶段没有实现完整 SoC 或加速器，目录说明与接口草案不构成已实现能力。
迁移前原始文件在仓库外备份；重复 CPU 源码和差分实现已退出父仓库源码树。
