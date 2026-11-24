# CPU 基线：miniXiangShan 与 NutShell

本目录由原 `compare/` 迁入，保留双 CPU 比较作为系统研究的基线。
加速器与卸载研究从 `experiments/memory-offload/` 开始。

## 构建与运行

在仓库根目录分别构建应用和运行实验：

```bash
make app APP=coremark ITERATIONS=10
make cpu-baseline APP=coremark
```

也可以在本目录执行：

```bash
make build
make run APP=coremark
make run APP=hello RETIRE_TRACE=0
```

应用来自 `../../software/apps/<name>/`，按 `compare.json` 读取同一次编译的
BIN、HEX 和 ELF。缺少产物时先报错提示编译，构建仿真器不依赖具体应用。
性能仿真器输出到本目录 `build/`，运行结果到 `results/<app>/`。

CPU RTL 由主仓库 `hardware/platform/` 入口生成，CPU 源码来自固定子模块。
NutShell 由 `nutshell.lock` 固定，适配层与补丁保留在本目录。
方法与公平性边界见 [METHODOLOGY.md](METHODOLOGY.md)，补丁说明见
[patches/README.md](patches/README.md)。

## 参数与结果

`APP` 选择应用；`MAX_CYCLES` 限制仿真周期；`RETIRE_TRACE=0/1` 控制退休轨迹；
`TRACE_WINDOW` 控制分析窗口；`JOBS` 控制构建并行。
支持 `SBT`、`MILL`、`VERILATOR`、`CROSS_COMPILE` 与 `DEPS_DIR`。
应用迭代次数属于编译参数，运行时不会改变已有镜像。

结果包含原始日志、`summary.txt`、镜像/依赖指纹 `run-context.txt`，
以及可选的退休轨迹和窗口分析。运行会校验成功签名、计数器、校验和；
CoreMark 还会核对 host 与 RTL 的 CRC。原有实验输出已随目录保留。

共享外部平台位于 `platform/rtl/Axi4PerfPlatform.v`，使用简化 DRAM/MMIO 时序，
不是完整 DDR 模型。逐指令差分单独使用根目录的 `build/emu`。

## 清理

`make clean` 仅删除本目录构建；`make clean-results APP=<name>` 明确删除对应
应用的结果。根目录 `make clean-all` 保留结果和依赖。
