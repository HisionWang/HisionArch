# 裸机运行环境

`start.S` 设置栈、清零 BSS 并调用 `main`；`link.ld` 定义当前基线镜像布局。
`minilibc.c` 提供最小字符串函数，`runtime.c` 与 `include/mini.h` 提供控制台和
性能报告接口。`app.mk` 是应用共用构建规则，`bin2hex.py` 生成性能平台镜像。

应用 Makefile 在定义 `NAME`、`SRCS`、`HEADERS` 后包含 `../../runtime/app.mk`。
当前运行环境对应仿真地址图，尚未提供真实 UART、DMA 或 SD 卡驱动。

## FPGA SoC

`soc/` 包含独立的 DDR 启动文件和链接脚本，通过 `soc_demo` 构建。它不使用仿真
console/完成通知，真实 UART/LED 操作在 `software/drivers/soc/`。
