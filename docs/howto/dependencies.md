# CPU 子项目与依赖管理

miniXiangShan 是独立维护的自研 CPU，位于 `hardware/cpu/miniXiangShan`。
Git submodule 用于分别维护 CPU 与系统平台的版本，并固定实验所用的 CPU 提交。

## 初始化

```bash
git submodule update --init --recursive
make deps
```

CPU 地址保存在 `.gitmodules`，固定提交保存在父仓库 gitlink。
`make deps` 初始化缺失的 CPU，并检查工作区版本与 gitlink 一致、源码没有本地修改。
构建入口也执行此检查。

NEMU、CoreMark、NutShell 按各自锁文件进入被忽略的 `.deps/` 缓存。
`make clean` 保留依赖与源配置；删除缓存需要单独执行明确的维护操作。

## 恢复父仓库固定版本

先保存对子模块的本地修改，再执行：

```bash
git submodule update --init --recursive -- hardware/cpu/miniXiangShan
make deps
```

## 有意升级 CPU

以下命令在 HisionArch 根目录执行，切换到 CPU 仓库的 `master` 最新提交：

```bash
git -C hardware/cpu/miniXiangShan fetch origin
git -C hardware/cpu/miniXiangShan log --oneline HEAD..origin/master
git -C hardware/cpu/miniXiangShan checkout --detach origin/master
git -C hardware/cpu/miniXiangShan submodule update --init --recursive
git add hardware/cpu/miniXiangShan
make deps
make emu
```

要固定某个版本，将 `origin/master` 替换为选定的提交号或标签。
`git add` 要在 `make deps` 前执行：检查脚本以父仓库暂存区记录的 gitlink 为准。
随后将 CPU 版本更新作为主仓库变更提交保存。

父仓库 gitlink 更新后，检查接口、差分 ABI 和内存属性变化，再重建平台并根据
升级范围验证。升级前后的实验使用不同版本记录。
日常运行按固定提交进行，避免把分支最新状态作为隐含实验输入。

## 继续开发自研 CPU

CPU 内部修改在 miniXiangShan 仓库中使用开发分支维护。CPU 修改形成提交后，
在 HisionArch 根目录执行 `git add hardware/cpu/miniXiangShan`，再构建平台并
记录新的 CPU 提交。平台和加速器实现继续在各自目录维护。
