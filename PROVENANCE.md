# 项目与依赖来源

## 自研 CPU 子项目

miniXiangShan 是作者独立维护的自研 CPU，仓库地址为
`https://github.com/XiangShanLab/miniXiangShan.git`，
以 `hardware/cpu/miniXiangShan` Git submodule 接入，版本以父仓库 gitlink 为准。
本次接入版本为 `d74cd2250d3def52471cc410d4cc9fef4d320fed`。

重组前本地 CPU 源码、差分驱动、构建脚本和应用与该提交的同名文件逐字节一致。
主仓库已移除原独立 CPU 源码树，直接编译子模块源码，并复用其差分驱动和
NEMU 构建逻辑。原始代码的更早来源记录保留在子模块 `PROVENANCE.md` 中。

HisionArch 自有平台入口位于 `hardware/platform/`，构建集成位于根目录
`build.sbt` 与 `scripts/`。CPU 内部接口与配置随固定版本维护。

## 仿真参考

NEMU URL 和固定版本取自子模块 `difftest/deps.lock`。
`scripts/build-ref.sh` 调用 CPU 仓库中该版本的构建脚本，使用主仓库 `.deps/` 和
`build/ref/`。主仓库不另外复制 NEMU ABI 定义或 CPU 差分实现。

## 应用和运行库

`software/apps/`、`software/runtime/` 从重组前的 `apps/` 迁入，最初与上述
miniXiangShan 提交一致。迁移调整了路径与 hello 的平台名称，CoreMark 算法
仍由官方仓库的固定版本获取。

CoreMark 依赖由 `software/apps/coremark/deps.lock` 固定，原始算法文件由
`checksums.sha256` 检查。`report-results.patch` 的适配边界保留在补丁及
CPU 基线实验文档中。应用构建信息位于各自 `build/build-info.txt`。

## CPU 基线实验

`experiments/cpu-baseline/` 由原 `compare/` 迁入，保留原方法、适配层、补丁
和已有结果。NutShell 依赖固定在该目录的 `nutshell.lock`，并保留上游记录的
difftest 子模块版本。

补丁原因见 `experiments/cpu-baseline/patches/README.md`。后续实验的
`run-context.txt` 记录应用/仿真器指纹、CPU 和 NutShell 的版本以及运行配置。
已有结果中的旧绝对路径保留为历史记录，不代表迁移后的构建验证。
