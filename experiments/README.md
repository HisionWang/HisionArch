# 实验

当前重点是加速器卸载、数据搬运与存储系统行为。

| 实验 | 状态 | 用途 |
| --- | --- | --- |
| `cpu-baseline/` | 由原 `compare/` 迁入 | 保留 miniXiangShan/NutShell 的 CPU 基线比较 |
| `memory-offload/` | 研究方案草案 | 探索任务规模、数据搬运和带宽竞争对卸载收益的影响 |

新实验包含 `README.md`、`methodology.md`、实际运行配置、运行/分析脚本。
小型结果表和可重画图表的源数据放 `reports/`；原始日志放 `runs/` 并默认忽略。
大型数据在外部归档，报告保留存储地址与校验值。

结果应能追溯到父仓库提交、CPU gitlink、硬件/软件配置、工具版本、镜像和
bitstream 指纹。区分仿真周期与 FPGA 实际运行时间，记录计时边界与自检结果。
