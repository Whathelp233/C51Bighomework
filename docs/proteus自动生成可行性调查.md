# Proteus 自动生成可行性调查

本文档记录对本机 Proteus 8 Professional 工程格式和命令行能力的调查结论，用于解释为什么最终 `proteus/topic3_car.pdsprj` 仍需要在 Proteus GUI 中人工搭建，而不是在当前仓库中伪造或手写生成。

## 1 调查对象

本机 Proteus 安装位置：

```text
C:\Program Files (x86)\Labcenter Electronics\Proteus 8 Professional\BIN\PDS.EXE
```

已检查的本地资源包括：

- Proteus 自带 8051 LCD1602 示例工程。
- Proteus 自带 8051 DC Motor Controller 示例工程。
- Proteus 自带 SRF04/Grove Ultrasonic Ranger 示例工程。
- `.pdsprj` 工程压缩包中的 `PROJECT.XML`、`FIRMWARE.XML`、`FIRMWARE/AT89C51.XML`、`ROOT.CDB` 和 `ROOT.DSN`。
- `PDS.EXE`、`PROSPICE.EXE` 和 ISIS 相关可执行文件的命令行帮助或字符串信息。

## 2 工程格式观察

Proteus `.pdsprj` 文件本质上是一个 ZIP 容器。解包后可以看到：

| 文件 | 作用 | 可人工稳定修改 |
| --- | --- | --- |
| `PROJECT.XML` | 项目说明、脚本、元数据 | 可以 |
| `FIRMWARE.XML` | 固件项目索引 | 可以 |
| `FIRMWARE/AT89C51.XML` | 8051 固件文件引用 | 可以 |
| `FIRMWARE/AT89C51/Debug/Debug.hex` | 可加载到 MCU 的 HEX | 可以 |
| `ROOT.CDB` | 设计数据库 | 不稳定 |
| `ROOT.DSN` | ISIS 原理图主体 | 不稳定 |

前几个 XML 文件能够用脚本替换固件引用，所以当前仓库可以生成 LCD1602 和 DC motor 的本地 starter 工程。但真正的原理图连接、元件实例、导线、网标和布局主要保存在 `ROOT.DSN` 与相关数据库中，该内容是二进制设计数据，不适合在缺少官方格式说明的情况下手写。

## 3 命令行能力结论

对 `PDS.EXE /?`、`PROSPICE.EXE /?` 以及 ISIS 相关字符串进行检查后，没有发现可稳定创建 ISIS 原理图、放置元件和连线的公开命令行接口。本机帮助文件中也没有可直接用于生成完整 `.pdsprj` 的脚本接口说明。

因此，本项目不应把 starter 工程复制成最终 `topic3_car.pdsprj`，也不应尝试手工拼写 `ROOT.DSN`。那样得到的文件无法保证可打开、可仿真或属于课题 3 的完整原理图。

## 4 当前可自动准备的内容

虽然最终原理图仍需要 GUI 搭建，仓库已经准备了可降低人工出错率的材料：

| 文件 | 用途 |
| --- | --- |
| `proteus/FINAL_CIRCUIT_CHECKLIST.md` | 手工搭建最终原理图的步骤清单 |
| `proteus/topic3_car_wiring.csv` | 精确到元件编号、引脚、网络名的接线表 |
| `proteus/topic3_echo_test_inputs.csv` | Echo 脉冲源测试参数 |
| `proteus/reference_samples.md` | 本机可参考的 Proteus 示例工程路径 |
| `tools/check_topic3_proteus_plan.ps1` | 检查上述资料是否覆盖关键网络和测试场景 |

最终建议流程是：先运行构建和检查脚本，再按 CSV 在 Proteus 中创建 `topic3_car.pdsprj`，最后补截图和 20 秒内演示视频。
