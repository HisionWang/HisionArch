# 硬件

| 目录 | 职责 |
| --- | --- |
| `cpu/` | 独立维护的自研 miniXiangShan CPU 子项目 |
| `accelerators/` | 加速器计算单元、本地存储、任务执行逻辑 |
| `soc/` | CPU/加速器集成、地址解码、中断、外设、系统顶层 |
| `memory/` | DMA、仲裁、访存调度、内存侧计算等研究组件 |
| `common/` | 多模块共用的硬件接口与工具组件 |
| `platform/` | 平台配置与 RTL 生成入口 |

平台与加速器的 Chisel 源码使用 `<area>/src/main/scala/hisionarch/...`，模块测试使用
`<area>/src/test/scala/hisionarch/...`。根目录 `build.sbt` 已包含这五个源码区域。
原生 Verilog/SystemVerilog 在对应模块的 `rtl/` 保存，并由具体构建入口显式纳入。

加速器、SoC 和访存区域目前只有职责说明；现有可运行平台仍为 CPU 仿真基线。
自研 CPU 源码通过 `hardware/cpu/miniXiangShan` 子模块维护，使用其独立源码布局。
