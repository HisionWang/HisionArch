# 文档导航

| 想了解的内容 | 入口 |
| --- | --- |
| 当前已实现与尚未实现的能力 | [status.md](status.md) |
| 近期研究与系统建设任务 | [roadmap.md](roadmap.md) |
| 系统职责与数据路径 | [架构概览](architecture/overview.md) |
| CPU SoC、AXI 矩阵、启动和复位 | [CPU SoC 架构](architecture/cpu-soc.md) |
| Vivado Tcl、板卡配置、JTAG 下载 | [FPGA SoC 指南](howto/fpga-soc.md) |
| CPU 接入条件 | [CPU 接口](interfaces/cpu.md) |
| 当前地址空间与后续分配规则 | [地址映射](interfaces/memory-map.md) |
| 加速器控制/数据接口的设计起点 | [接口草案](interfaces/accelerator.md) |
| CPU 与 DMA 共享数据 | [缓存与 DMA 草案](interfaces/cache-dma.md) |
| 构建、编译应用和运行仿真 | [操作指南](howto/build-and-simulate.md) |
| 开始实现自己的加速器 | [增加加速器](howto/add-accelerator.md) |
| CPU 子项目初始化和版本更新 | [子项目与依赖管理](howto/dependencies.md) |
| 仓库布局与 CPU 子项目接入方式的理由 | [设计决策](decisions/0001-accelerator-platform.md) |
| 实验组织和 CPU 基线 | [experiments/](../experiments/README.md) |
| 阅读记录与研究线索 | [research/](research/README.md) |
| 临时调试和工作记录 | [notes/](notes/README.md) |

整机架构与跨模块接口在这里维护；模块内部设计随模块保存。
每个事实指定一个维护位置，其他文档通过链接引用。地址、参数与寄存器以实际
源码为准，后续若引入生成工具，再从同一配置生成硬件、软件和文档。

设计草案明确标记为规划，实际验证范围写入 `status.md`；实验结论与复现材料
放在对应的 `experiments/<name>/`。图片及可编辑框图在需要时放入 `assets/`。
