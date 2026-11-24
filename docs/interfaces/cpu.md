# CPU 接入约束

CPU 版本由 `hardware/cpu/miniXiangShan` gitlink 决定。接口细节以该版本的
[myCPU_top.scala](../../hardware/cpu/miniXiangShan/src/main/scala/myCPU_top.scala)
和 [INTEGRATION.md](../../hardware/cpu/miniXiangShan/INTEGRATION.md) 为准。

- RV64IM、Zicsr/Zifencei、M/S/U、Bare/Sv39。
- `core_top` 导出 AXI4 Full master，64 位地址与数据、4 位 ID、8 位 LEN。
- 当前外部全局单 outstanding，读写串行，ID 固定为零。
- 64 字节 cache line 使用 8 拍 INCR burst；uncache 为单拍 8 字节，按 WSTRB 选字节。
- 时钟 `aclk`，低有效复位 `aresetn`，中断输入 `intrpt[7:0]`。
- `emu` 平台复位 PC 为 `0x80000000`；`fpga` 平台沿用 CPU 仓库默认值。

PMP/PMA 尚未实现。设备访问属性、带副作用 MMIO 的执行顺序、总线错误、
缓存与 DMA 的数据可见性，需要在系统接入阶段明确并验证。
AXI 的 ARCACHE/AWCACHE 信号不能单独证明存在硬件缓存一致性。

CPU 差分接口属于固定 CPU 版本的 ABI，随子模块读取，不在主仓库复制定义。
