# 地址映射

## 当前仿真基线

| 区域 | 地址 | 说明 |
| --- | --- | --- |
| DRAM | `0x80000000` 起 | emu 默认 16 MiB，可通过运行参数配置 |
| 性能 MMIO | `0x4000f000` 起 | 既有完成、计数与 console 协议 |
| 完成通知 | `0x4000f030` | 既有性能平台完成寄存器 |
| Console | `0x4000f038` | 仿真输出端口，尚非真实 UART |

具体寄存器语义见运行库 `software/runtime/include/mini.h` 和对应仿真模型。
CPU 对设备区域的现有分类见
[PerfAddressMap.scala](../../hardware/cpu/miniXiangShan/src/main/scala/config/PerfAddressMap.scala)。
CPU 对比平台的外部物理地址窗口限定为 32 位，不能直接代表完整 SoC 地址空间。

## 后续分配规则

加速器控制区、共享缓冲、ROM、UART、定时器和中断控制器尚未分配正式地址。
实现时明确每个区域的范围、访问宽度、缓存属性、副作用、权限和复位值。
硬件解码、软件头文件与文档应从同一地址定义生成，或明确引用唯一源码。
