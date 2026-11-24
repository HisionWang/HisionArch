# 自研 CPU 子项目

miniXiangShan 是作者独立维护的 CPU 项目，通过 Git submodule 接入：
[XiangShanLab/miniXiangShan](https://github.com/XiangShanLab/miniXiangShan)。
固定版本由父仓库的 gitlink 保存，`.gitmodules` 保存仓库地址。

```bash
make deps
git submodule status
```

主仓库直接编译本目录 `miniXiangShan/src/main/scala/`，仿真器复用该版本的 C++
驱动和 NEMU 构建脚本。CPU 内部文档和测试由子模块维护。
HisionArch 的平台配置、适配与加速器实现放在 `hardware/`。

初始化、恢复固定版本和有意升级的步骤见
[CPU 子项目与依赖管理](../../docs/howto/dependencies.md)。
