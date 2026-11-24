# 增加一个加速器

## 确定任务和接口

先在 `hardware/accelerators/docs/<name>.md` 写清输入/输出、数据格式、边界条件、
本地存储容量和任务完成语义。跨模块寄存器和共享缓冲约定放在
`docs/interfaces/`，并明确哪些内容仍是草案。

## 放置实现

| 内容 | 位置 |
| --- | --- |
| 加速器 Chisel 实现 | `hardware/accelerators/src/main/scala/hisionarch/accelerators/<name>/` |
| 可复用 DMA/调度 | `hardware/memory/src/main/scala/hisionarch/memory/` |
| 系统连接与 MMIO 解码 | `hardware/soc/src/main/scala/hisionarch/soc/` |
| 平台配置与生成模式 | `hardware/platform/src/main/scala/hisionarch/platform/` |
| 软件驱动 | `software/drivers/<name>/` |
| CPU 参考与实际应用 | `software/apps/<name>/` |
| 实验配置、分析和结论 | `experiments/<study>/` |

根 `build.sbt` 已包含这些硬件区域的 Scala 源目录。
增加新的系统顶层时，在平台入口中显式选择，并更新构建脚本所用顶层名称；
现有 `emu` 仍以 CPU `core_top` 为顶层，其 C++ 驱动不能自动识别新设备。

## 逐步连接

先完成计算单元和 CPU 参考，再接入本地缓冲、控制接口与数据搬运。
应用当前包含 `../../runtime/app.mk`；驱动源文件和头文件需显式加入应用的
`SRCS` 与 `HEADERS`，才能参与编译和输入指纹计算。

完整路径运行后，实验分别记录启动、搬运、计算、同步和总时间，保存准确配置。
能力实现和验证完成后更新 `docs/status.md`，测量结论写入对应实验报告。
