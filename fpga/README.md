# FPGA 工程

工程、Block Design、IP 和 wrapper 全部通过 `scripts/` 下的 Tcl 创建。
`targets/<board>/` 保存实际板卡参数、DDR IP 的配置输入和 XDC；生成工程位于
仓库根 `build/fpga/<name>/`，不提交生成物。

当前基础 SoC：miniXiangShan、JTAG to AXI、2×4 AXI 矩阵、DDR、系统控制、LED GPIO、
UART Lite。板卡尚未选择，默认 `targets/template/target.tcl` 保留所有资源空值。

```bash
make soc-rtl
make soc-app
make fpga-check                  # 模板预期报缺项
make fpga-project TARGET=fpga/targets/<board>/target.tcl
make fpga-bitstream TARGET=fpga/targets/<board>/target.tcl
```

每个 Vivado 构建入口要求新的生成目录；详见
[构建和上板指南](../docs/howto/fpga-soc.md) 与 [架构](../docs/architecture/cpu-soc.md)。
`memory_mig7.tcl` 是可选的 7 系列适配，不指定任何具体器件或 DDR 参数。
原 `make rtl MODE=fpga` 保留 CPU 子项目原复位地址；新 SoC 使用 `make soc-rtl`。
