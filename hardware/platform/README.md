# 平台配置与生成入口

`src/main/scala/hisionarch/platform/Generate.scala` 是 HisionArch 的 RTL 生成入口。

| 模式 | 顶层 | 用途 |
| --- | --- | --- |
| `emu` | CPU 仓库 `core_top` | NEMU 差分仿真基线，复位 PC 为 `0x80000000` |
| `compare` | CPU 仓库 `MiniPerfTop` | 既有 CPU 对比平台，复位 PC 为 `0x80000000` |
| `soc` | CPU 仓库 `core_top` | 新 SoC CPU，DDR 起始地址复位，FPGA RAM 黑盒 |
| `fpga` | CPU 仓库 `core_top` | CPU RTL，使用 CPU 仓库复位 PC 与 RAM 黑盒 |

```bash
make rtl MODE=emu
make rtl MODE=fpga
```

输出位于 `build/rtl/`。`fpga` 模式只生成核 RTL，板卡工程、RAM IP、DDR
与外设采用新的 `soc` 模式和 `hardware/soc/rtl/` 集成，通过 `fpga/scripts/` 创建完整
Block Design。新 SoC 使用 `make soc-rtl`；具体板卡参数尚待填写。
