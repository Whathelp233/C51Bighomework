# C51 Big Homework - Topic 3

课题：流水灯及智能小车超声测距及避障实现。

本仓库当前包含：

- 课程设计说明书初稿：`docs/课程设计说明书_课题3_初稿.md`
- 项目技术设计文档：`docs/课题3项目设计文档.md`
- 需求实现矩阵：`docs/需求实现矩阵.md`
- 汇编程序清单与模块说明：`docs/汇编程序清单与模块说明.md`
- 提交材料与答辩脚本：`docs/提交材料与答辩脚本.md`
- 器件手册索引：`docs/器件手册索引.md`
- 汇编固件：`firmware/asm/topic3_car.a51`
- Keil A51 构建脚本：`firmware/build.ps1`
- Proteus 仿真说明：`proteus/README.md`
- 最终 Proteus 原理图搭建清单：`proteus/FINAL_CIRCUIT_CHECKLIST.md`
- Proteus BOM：`proteus/topic3_bom.csv`
- Proteus GUI 搭建工单：`proteus/topic3_gui_build_steps.md`
- Proteus 精确接线表：`proteus/topic3_car_wiring.csv`
- Echo 脉冲测试输入表：`proteus/topic3_echo_test_inputs.csv`
- Proteus 自动生成可行性调查：`docs/proteus自动生成可行性调查.md`
- 20 秒演示视频分镜：`output/video/demo_storyboard.md`
- Proteus 与实物调试记录模板：`docs/仿真测试记录.md`
- 本地手册资料：`refs/datasheets/`

## Build Firmware

Run from the repository root:

```powershell
.\firmware\build.ps1
```

Expected output:

```text
A51: 0 WARNING(S), 0 ERROR(S)
BL51: 0 WARNING(S), 0 ERROR(S)
Generated D:\C51BigHomeWork\build\topic3_car.hex
```

`build/` is ignored by Git because it contains generated files.

## Proteus

Final circuit target:

```text
proteus/topic3_car.pdsprj
```

Build it manually in Proteus using:

```text
proteus/FINAL_CIRCUIT_CHECKLIST.md
proteus/topic3_bom.csv
proteus/topic3_gui_build_steps.md
proteus/topic3_car_wiring.csv
```

Load this HEX into the MCU:

```text
D:\C51BigHomeWork\build\topic3_car.hex
```

Local starter projects can be generated for quick Proteus loading checks:

```powershell
.\tools\create_proteus_starters.ps1
.\tools\check_proteus_starters.ps1
```

The starter `.pdsprj` files are ignored by Git because they are derived from Proteus built-in samples.

Check the prepared wiring and Echo test tables:

```powershell
.\tools\check_topic3_proteus_plan.ps1
```

Start the final manual Proteus build session:

```powershell
.\tools\start_final_proteus_session.ps1 -OpenReferences
```

After a Proteus project exists, open it with:

```powershell
.\tools\launch_proteus.ps1 -Project final
```

## Environment Check

```powershell
.\tools\check_environment.ps1
```

This checks for Keil A51/BL51/OH51, Proteus 8 Professional, and Poppler `pdftotext`.

## Deliverable Check

```powershell
.\tools\check_deliverables.ps1
```

This reports required documents and build outputs, plus pending final evidence such as the completed Proteus project and 20-second demo video.

Use final mode before submission:

```powershell
.\tools\check_deliverables.ps1 -Final
.\tools\check_final_submission.ps1
```

To wait while the Proteus GUI project and demo video are being produced:

```powershell
.\tools\watch_final_submission.ps1
```

## Build Design DOCX

```powershell
$py='C:\Users\PCbeta\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $py .\tools\build_design_docx.py
```

The generated document is written to `output/docx/课程设计说明书_课题3_提交版.docx`.
