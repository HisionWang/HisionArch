# 软件

- `runtime/`：裸机启动、链接脚本、最小 C 运行库、控制台和性能报告接口。
- `drivers/`：后续 DMA、加速器和外设的软件驱动。
- `apps/`：独立编译的应用、CPU 参考实现和基准程序。

当前 ABI 为 `lp64`，ISA 为 `rv64im_zicsr_zifencei`，镜像链接到 `0x80000000`。
构建应用不会自动运行仿真。

```bash
make app APP=hello
make run APP=hello
```

增加应用见 [应用说明](apps/README.md)。OS、持久存储启动与加速器驱动尚未实现。
