# 构建与仿真

以下命令均在仓库根目录执行。

## 环境

RTL：JDK、sbt；仿真器：Verilator、C++17 编译器、make、Python 3、Git、flock。
软件：`riscv64-unknown-elf-gcc` 和 binutils。NEMU 还需要 flex、bison、
readline/zlib/zstd 开发库；CPU 双边比较额外需要 mill。
sbt 版本由 `project/build.properties` 固定。

## 分别构建与运行

```bash
make deps
make emu
make app APP=hello
make run APP=hello
```

仿真器位于 `build/emu`，应用位于 `software/apps/<name>/build/`。
`make run` 使用已有产物，缺少时会提示先构建。

```bash
make emu WITH_DIFFTEST=0 WITH_WAVE=0 JOBS=8
./build/emu -i software/apps/hello/build/hello.bin --no-diff
./build/emu --help
```

带差分构建默认开启 NEMU 对比；无差分构建适合先检查工具链和集成。
BIN 供 emu 使用，HEX 供 CPU 性能平台使用。
完整仿真参数、错误诊断与差分边界见
[CPU 仓库文档](../../hardware/cpu/miniXiangShan/difftest/README.md)。

## RTL 与平台配置

```bash
make rtl MODE=emu
make rtl MODE=compare
make rtl MODE=fpga
```

生成入口在 `hardware/platform/`。CPU 内部默认参数随固定子模块维护；
项目级覆盖参数在 `Generate.scala` 中给出。生成结果包含 `build-context.txt`，
记录 CPU 版本、模式与源码指纹。

`fpga` 模式生成核 RTL，仍需补齐板卡、RAM IP、DDR 和外设。
它不输出整机 bitstream。

## 可选 CPU 基线实验

```bash
make app APP=coremark ITERATIONS=10
make cpu-baseline APP=coremark
```

详见 [CPU 基线目录](../../experiments/cpu-baseline/README.md)。

## 清理

`make clean` 删除根 `build/` 和 Scala 缓存。
`make clean-apps` 删除应用构建；`make clean-compare` 删除 CPU 比较构建；
`make clean-all` 执行以上三项。依赖、子模块、实验结果和固定 sbt 配置保留。
自定义到标准目录以外的构建路径由使用者单独管理。
