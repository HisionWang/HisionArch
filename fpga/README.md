# FPGA 目标

当前尚未选择板卡，未建立可烧录工程。`make rtl MODE=fpga` 只生成 CPU RTL。

选定板卡后，在 `targets/<name>/` 保存目标 README、时钟与引脚约束、顶层适配、
厂商 IP 配置及重建/烧录脚本。共用内容放 `common/`。
Vivado/Quartus 工作目录输出到被忽略的 `build/`。

目标文档需记录器件型号、工具版本、RAM IP、DDR 数据路径、时钟复位、
启动介质和调试接口。发布 bitstream 时关联 CPU 版本、固件与 PCB 修订号。
