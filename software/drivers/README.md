# 驱动

`soc/soc.h`、`soc/soc.c` 提供首版 SoC 的 32 位 MMIO、UART 轮询、LED 逻辑掩码和
周期计数访问。寄存器地址来自生成的 `hision_soc_map.h`，GPIO/UART 逻辑寄存器间隔
为 8 字节；它与默认 Vivado 裸机驱动的偏移不同。

示例为 `software/apps/soc_demo/`。后续在这里增加加速器控制、DMA 和数据所有权协议。
