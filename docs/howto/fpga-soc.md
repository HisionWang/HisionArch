# 构建和启动 FPGA SoC

先阅读 [CPU SoC 架构](../architecture/cpu-soc.md)。目前没有选定 FPGA 和板卡，
`template` 是待填写的配置模板；它会明确报缺项，不能生成 bitstream。

## 先构建板卡无关部分

```bash
make soc-rtl
make soc-app
make fpga-check
```

前两个命令分别生成 `build/rtl/soc/` 和 `software/apps/soc_demo/build/soc_demo.bin`。
第三个命令在默认模板上预期失败，列出缺少的板卡信息；它不依赖 Vivado。

`soc_demo` 是单独的真实 UART/LED 应用，`hello`、`coremark` 使用仿真运行库。
`soc_demo` 的链接地址来自 SoC map，另预留 16 KiB 软件栈；这不是物理 DDR 容量配置。
上板前检查 `soc_demo.memory.txt` 的 `__app_ram_end` 不超过 DDR 末地址。JTAG loader
检查 BIN 长度和读回内容，不会解析 ELF 的 BSS、栈范围。二进制必须将 `_start` 放在
DDR 起始地址，不能把 ELF 文件本身作为 BIN 下载。

SoC/Vivado 流程统一使用仓库根 `build/` 交换生成文件。`make soc-rtl` 固定该路径；
旧仿真流程的 `BUILD_DIR` 自定义不影响这一约定。

## 新建板卡目标

复制 `fpga/targets/template/` 到 `fpga/targets/<board>/`，填写 `target.tcl`：

| 字段 | 填写依据 |
| --- | --- |
| `name` | 目标名称，用于生成目录 |
| `part` | 完整 FPGA part，含封装和速度等级 |
| `vivado_version` | 采用的精确 Vivado 主次版本，如工具 `version -short` 输出 |
| `axi_clock_hz` | DDR 控制器实际 UI 时钟，单位 Hz |
| `ddr_bytes` | 实际可用 DDR 映射容量，字节，V1 要求 2 的幂且不超过 2 GiB |
| `led_width` / `led_active_low` | 板载 LED 数量及点亮电平，1–32 路，极性 0 或 1 |
| `uart_baud` | 终端使用的波特率，8 数据位、无校验、1 停止位 |
| `xdc_files` | 非空 XDC 文件列表，含真实引脚、电平与输入时钟约束 |
| `memory_provider_tcl` | DDR、时钟和复位适配脚本路径 |
| `mig_prj` | 仅 MIG7 适配需要，来自实际板卡 MIG 配置的 `.prj` |

路径相对于 `target.tcl`；也可以使用绝对路径。模板不填写任何推测的资源。
MIG 文件、XDC 和板卡适配脚本是构建输入，纳入版本控制。最终 DDR 参数包含实际
存储颗粒、总线宽度、时序、时钟拓扑、引脚、复位极性及 UI 配置。

若明确选择 7 系列 MIG，可将 `memory_provider_tcl` 指向
`../../scripts/memory_mig7.tcl`，并提供 `mig_prj`。这个适配会外引 MIG 的物理接口、
输入时钟和 `sys_rst`；外部端口名由 Vivado 生成，XDC 必须对应最终 wrapper。
DDR 物理约束可能由 MIG 自动产生，仍须检查和板卡 XDC 的一致性。
这个适配不假定其他 FPGA 系列可使用 MIG7。

## 自定义 DDR 适配契约

memory provider 在当前 Block Design 中定义过程：

```tcl
proc ::hision::create_memory {cfg} {
    # 使用真实板卡配置创建 DDR IP、输入时钟/复位端口及同步复位电路。
    # 连接 DDR IP 的 AXI 时钟与复位；外引 DDR 引脚。
    # 返回以下 dict（值必须是当前 BD 中已存在的对象路径）：
    return [dict create \
        axi <DDR_AXI_slave_interface> \
        clk <UI_clock_output_pin> \
        aresetn <synchronized_active_low_fabric_reset_pin> \
        calibrated <calibration_done_pin> \
        segment <DDR_slave_address_segment>]
}
```

AXI 接口必须支持 AXI4、窄事务和 CPU 的 64 字节 INCR burst。
UI 时钟频率元数据必须准确。返回的 `aresetn` 应覆盖控制器 UI 复位和失锁/板卡复位，
至少满足所有 IP 的复位时长要求；校准丢失需要触发系统复位。实际板卡的电源、参考
时钟、DDR reset 时序由该适配负责。采用 DDR4/其他系列时，可按此契约替换控制器。

## Tcl 创建、综合和实现

先加载相应 Vivado 的环境，再在仓库根运行：

```bash
make fpga-check TARGET=fpga/targets/<board>/target.tcl
make fpga-project TARGET=fpga/targets/<board>/target.tcl
# 或从全新生成目录直接完成综合/bitstream：
make fpga-synth TARGET=fpga/targets/<board>/target.tcl
make fpga-bitstream TARGET=fpga/targets/<board>/target.tcl JOBS=8
```

三个 Vivado 入口都从源码创建**新工程**，不是在上一次生成的工程上增量执行。
已存在 `build/fpga/<name>/hision_soc.xpr` 时会停止，避免隐式覆盖；重建前移走或删除
对应生成目录。GUI 查看允许，但需要保留的修改必须回写 Tcl/配置/XDC。

流程自动加入 CPU RTL、生成 CPU BRAM 适配、实例化 IP、连接总线/时钟/复位、分配地址、
校验 Block Design，再生成 wrapper 和工程。IP 的具体 VLNV 来自目标固定版本的工具，
记录在 `build-manifest.txt`；不提交 GUI 生成的 `.xpr`、`.bd`、`.xci` 或 bitstream。

bitstream 流程输出 `timing.rpt`、`utilization.rpt`、`drc.rpt`，检查最差 setup/hold
slack 后调用 `write_bitstream`，保留 Vivado 的默认 DRC。约束完整性、时序覆盖、DDR
校准和功能仍需要板卡验证；脚本成功不能替代这些工作。

## 配置 FPGA 和 JTAG 下载

构建命令不会自动连接或改写 FPGA。明确配置硬件时，在 Vivado Tcl Console 中执行
（参数中的硬件 target/device 可从 `get_hw_targets`、`get_hw_devices` 获取；只有一个
对象时可以省略）：

```tcl
set argv [list /absolute/path/hision_soc.bit <hardware-target-name> <fpga-device-name>]
set argc [llength $argv]
source fpga/scripts/program.tcl
source fpga/scripts/jtag.tcl
hision::debug::attach fpga/targets/<board>/target.tcl
hision::debug::status
hision::debug::load_bin software/apps/soc_demo/build/soc_demo.bin
hision::debug::run
```

也可用 `vivado -mode batch -source fpga/scripts/program.tcl -tclargs ...` 单独配置。
Hardware Manager 已连接时，直接 source `jtag.tcl` 并 attach 即可；若有多个 JTAG AXI，
将准确的 AXI 对象名作为 attach 的第二个参数。

使用板卡指定波特率打开电脑串口终端；看到欢迎文本和 LED0 心跳后，可输入字符查看
回显。外接串口的电压标准、TX/RX/GND 和 USB 桥连接按板卡原理图确定。

其他调试操作：

```tcl
hision::debug::stop             ;# 排空已选择的外部 AXI 事务，再复位 CPU
hision::debug::wait_ddr
# attach 加载了来自同一 JSON 的 map，以下用它计算地址：
set map $::hision_map
set gpio [dict get $map gpio_base]
hision::debug::read32 $gpio
hision::debug::write32 $gpio 1  ;# 这是原始 GPIO 电平；按板卡 LED 极性理解
hision::debug::status
```

CPU 处于复位时，JTAG 仍可以访问 GPIO、UART 和 DDR。下载脚本始终先停 CPU、等待校准，
按 little-endian 32 位字下载并立即读回；首版速度较慢，后续再增加批量传输。
`stop` 会丢弃 CPU 内部缓存状态，不可用作保存现场的暂停；运行中 JTAG DDR 访问不一致。
软件想保留的数据应使用后续明确的缓存维护/通信协议。

本地当前没有可用 Vivado 命令，也没有完整板卡配置，因此 Vivado 专有属性、DDR IP
生成、综合/实现、JTAG Hardware Manager 操作和实际程序运行均待选板后确认。
