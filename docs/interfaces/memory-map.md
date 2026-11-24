# 地址映射

## CPU SoC V1

唯一维护位置：`hardware/soc/config/base.json`。`make soc-config` 从它生成硬件宏、
软件头文件和 Tcl map；该映射用于 `soc` 模式与 Vivado/JTAG 流程。

| 区域 | 基地址 | 范围 | 缓存属性 |
| --- | --- | --- | --- |
| 系统控制 | `0x40000000` | 64 KiB，未定义偏移返回 SLVERR | 不可缓存 |
| LED GPIO | `0x40010000` | 64 KiB，仅下表偏移有效 | 不可缓存 |
| UART Lite | `0x40020000` | 64 KiB，仅下表偏移有效 | 不可缓存 |
| DDR | `0x80000000` | `target.tcl` 的 `ddr_bytes`，当前待填 | 可缓存 |

首版 DDR 容量为 2 的幂，最大 2 GiB；CPU 启动地址是 DDR 起始地址。
未映射地址由矩阵返回 DECERR。CPU 记录 AXI 错误，但当前核不保证把所有总线错误转成
架构访存异常，因此软件应只访问有效地址和宽度。

### 系统控制

寄存器间隔 8 字节。驱动/JTAG 使用低 32 位，必须按 8 字节对齐；CPU 也可作对齐的
64 位访问。读写通道独立，读值在 AR 握手时采样；写入按字节选通。复位为系统 AXI
复位，CPU 单独复位不会清除 RUN、scratch 或粘滞错误。

| 偏移 | 名称 | 访问 | 内容 / 复位 |
| --- | --- | --- | --- |
| `0x00` | ID | R | `0x48495331`（HIS1） |
| `0x08` | CONTROL | R/W | bit0 RUN；复位 0，其余位读零，写忽略 |
| `0x10` | STATUS | R | bit0 DDR ready；bit1 CPU in reset；bit2 CPU AXI busy；bit3 RUN 请求；bit4 AXI error 粘滞标志 |
| `0x18` | SCRATCH | R/W | 64 位调试暂存，复位 0；JTAG 脚本仅访问低 32 位 |
| `0x20` | CLOCK_HZ | R | 实际 AXI/CPU UI 时钟 Hz，来自板卡配置 |
| `0x28` | BOARD_IO | R | bits7:0 LED 数量；bit8 LED 为低电平点亮 |

向只读或未定义地址写入返回 SLVERR。错误标志在 CPU 收到非 OKAY 响应后置位，只有
系统复位清除。RUN=0 先结束已经选中的 CPU 外部事务，再复位 CPU；没有自动缓存写回。
细节见 [启动和复位](../architecture/cpu-soc.md)。

### LED GPIO 与 UART

这些是**逻辑偏移**，原生 IP 偏移为其一半。只使用对齐 32 位读写，写事务选通必须为
低 4 字节；64 位写、部分写、未对齐或超出寄存器槽范围的访问返回 SLVERR。
读取仍可使用 CPU 的完整 64 位总线事务，高 32 位补零。

| 区域 | 逻辑偏移 | 原生 IP 偏移 | 含义 |
| --- | --- | --- | --- |
| GPIO | `0x00` | `0x00` | DATA：LED 原始输出电平 |
| GPIO | `0x08` | `0x04` | TRI：GPIO 配置全输出，该寄存器方向固定 |
| UART | `0x00` | `0x00` | RX FIFO，读取弹出字符 |
| UART | `0x08` | `0x04` | TX FIFO，写入低 8 位字符 |
| UART | `0x10` | `0x08` | STATUS：bit0 RX 有数据；bit2 TX 空；bit3 TX 满；其余见 PG142 |
| UART | `0x18` | `0x0c` | CONTROL：bit0 清 TX；bit1 清 RX；bit4 中断使能 |

寄存器读写权限和副作用由原生 IP 定义；适配器保留其响应。UART 状态读取可能清除
IP 错误状态，调试时避免额外读取 RX/STATUS。首版驱动轮询，CONTROL 保持中断关闭。

## 既有仿真基线

`emu` 与 `compare` 使用独立的简化设备模型，和真实 FPGA 外设的寄存器协议不同。

| 区域 | 地址 | 说明 |
| --- | --- | --- |
| DRAM | `0x80000000` 起 | emu 默认 16 MiB，可通过运行参数配置 |
| 性能 MMIO | `0x4000f000` 起 | 既有完成、计数与 console 协议 |
| 完成通知 | `0x4000f030` | 既有性能平台完成寄存器 |
| Console | `0x4000f038` | 仿真输出端口 |

具体语义见 `software/runtime/include/mini.h` 和仿真模型。该模型的应用不能直接作为
真实 UART 应用使用。CPU 设备分类见
[PerfAddressMap.scala](../../hardware/cpu/miniXiangShan/src/main/scala/config/PerfAddressMap.scala)。

加速器控制区、共享缓冲、ROM、定时器尚未分配正式地址；新增时明确宽度、缓存属性、
权限和副作用，并更新唯一地址配置与对应访问适配。
