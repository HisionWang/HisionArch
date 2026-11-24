# 加速器

这里保存项目自主设计的加速器。第一个候选任务为数组过滤与归约，尚未实现。
每个加速器在对应的 Scala 包下组织；可复用逻辑放入 `hardware/common/` 或
`hardware/memory/`。

模块开始实现时，增加 `docs/<name>.md`，说明计算语义、数据格式、溢出规则、
控制与数据接口、本地缓冲，以及错误和复位行为。软件驱动放在
`software/drivers/`，工作负载放在 `software/apps/`，性能研究放在 `experiments/`。

首版接入建议见 [加速器接口草案](../../docs/interfaces/accelerator.md)。
