# Topic 3 Assembly and Proteus Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the course project for topic 3 with local datasheets, a Keil A51 assembly firmware, Proteus simulation guidance, and design-document evidence.

**Architecture:** The project is split into documentation, datasheet references, assembly firmware, build scripts, and Proteus simulation notes. The firmware uses a single 8051 assembly source first, with named subroutines for LED flow, key scanning, LCD1602 output, HC-SR04 timing, L293D motor control, and obstacle decision logic.

**Tech Stack:** STC89C52/8051, Keil A51/BL51/OH51, Proteus 8 Professional, Markdown design documents, PDF datasheets.

---

## File Structure

- `refs/datasheets/`: Saved datasheet PDFs used as evidence.
- `refs/extracted/`: Extracted datasheet text for quick search.
- `docs/器件手册索引.md`: Local source index and key hardware facts.
- `docs/课程设计说明书_课题3_初稿.md`: Main course design document.
- `docs/资料与元器件准备清单.md`: Checklist of literature, parts, and required materials.
- `docs/superpowers/plans/2026-06-13-topic3-assembly-proteus-plan.md`: This implementation plan.
- `firmware/asm/topic3_car.a51`: Keil A51 assembly firmware entry point and subroutines.
- `firmware/build.ps1`: Builds the assembly source into object, absolute object, and Intel HEX.
- `firmware/README.md`: Firmware port map, build command, and Proteus loading steps.
- `proteus/README.md`: Proteus component list, wiring table, simulation procedure, and expected behavior.

## Task 1: Datasheet Evidence

**Files:**
- Modify: `docs/器件手册索引.md`
- Modify: `docs/课程设计说明书_课题3_初稿.md`

- [x] **Step 1: Save datasheets locally**

Run:

```powershell
Get-ChildItem refs\datasheets
```

Expected: PDF files for STC89C52RC/STC89C51RC, LCD1602/HD44780U, HC-SR04, L293D, 74HC573, and PCF8591 are present.

- [x] **Step 2: Extract datasheet text**

Run:

```powershell
Get-ChildItem refs\extracted
```

Expected: matching `.txt` files are present for each saved PDF.

- [x] **Step 3: Record key knowledge**

Record these facts in `docs/器件手册索引.md`:

```text
HC-SR04: 10 us Trig pulse, Echo pulse width maps to distance, cm = us / 58.
L293D: VCC1 is logic supply, VCC2 is motor supply, enable pins are active high.
LCD1602: HD44780U supports 4-bit interface using DB4-DB7.
STC89C52: 8051-compatible core with P0/P1/P2/P3 I/O and timer resources.
```

## Task 2: Assembly Firmware Skeleton

**Files:**
- Create: `firmware/asm/topic3_car.a51`
- Create: `firmware/build.ps1`
- Create: `firmware/README.md`

- [x] **Step 1: Write the assembly source**

Create `firmware/asm/topic3_car.a51` with:

```asm
$MOD51
ORG 0000H
    LJMP START

START:
    MOV SP,#60H
    MOV P1,#0FFH
    MOV P2,#00H
MAIN_LOOP:
    ACALL KEY_SCAN
    ACALL LED_TASK
    ACALL CAR_TASK
    SJMP MAIN_LOOP
END
```

Then expand it with port bit definitions, LED flow routines, HC-SR04 distance timing, motor actions, LCD placeholders, and delay routines.

- [x] **Step 2: Build with Keil A51**

Run:

```powershell
.\firmware\build.ps1
```

Expected: `build/topic3_car.hex` exists.

- [x] **Step 3: Fix assembler errors**

If A51 reports syntax errors, edit `firmware/asm/topic3_car.a51` until:

```text
A51 TERMINATED. 0 WARNING(S), 0 ERROR(S)
```

or equivalent successful output appears.

## Task 3: Proteus Simulation Notes

**Files:**
- Create: `proteus/README.md`
- Later create manually in Proteus: `proteus/topic3_car.pdsprj`

- [x] **Step 1: Document component placement**

Add this component list:

```text
AT89C52 or compatible 8051 MCU
8 LEDs and 8 current-limiting resistors
4 active-low buttons
LCD1602/LM016L
HC-SR04 or pulse source for Echo simulation
L293D
2 DC motors
5 V logic supply and motor supply
```

- [x] **Step 2: Document exact wiring**

Record the firmware port map:

```text
P1.0-P1.7 -> LED0-LED7
P3.0 -> KEY_UP
P3.1 -> KEY_DOWN
P3.2 -> KEY_START_STOP
P3.3 -> KEY_MODE
P3.4 -> HC-SR04 Trig
P3.5 -> HC-SR04 Echo
P2.0-P2.1 -> left motor IN1/IN2
P2.2-P2.3 -> right motor IN3/IN4
P2.4-P2.5 -> ENA/ENB
P0.0-P0.5 -> LCD RS/EN/D4-D7
```

- [x] **Step 2.5: Generate local starter projects**

Run:

```powershell
.\firmware\build.ps1
.\tools\create_proteus_starters.ps1
.\tools\check_proteus_starters.ps1
```

Expected: local starter projects exist under `proteus/` and contain `FIRMWARE/AT89C51/Debug/Debug.hex`. These are ignored by Git because they derive from Proteus built-in samples.

- [ ] **Step 3: Load firmware HEX**

In Proteus, set the MCU program file to:

```text
D:\C51BigHomeWork\build\topic3_car.hex
```

Expected: LEDs respond to buttons, motors change direction, and LCD pins toggle when display routines are enabled.

## Task 4: Design Document Expansion

**Files:**
- Modify: `docs/课程设计说明书_课题3_初稿.md`

- [x] **Step 1: Add implementation evidence**

Add a section after software design:

```text
本项目已建立 Keil A51 汇编工程，源文件为 firmware/asm/topic3_car.a51。构建脚本 firmware/build.ps1 调用 A51、BL51 和 OH51 生成 Intel HEX 文件，供 Proteus 单片机模型加载。
```

- [ ] **Step 2: Add simulation evidence**

After the Proteus circuit is created, add screenshots and describe the observed results:

```text
按下 KEY_UP 时，P1 口输出流水灯上行码；按下 KEY_DOWN 时，P1 口输出流水灯下行码；小车运行模式下，P2 口输出 L293D 控制信号。
```

## Task 5: Verification

**Files:**
- Verify: `build/topic3_car.hex`
- Verify: `docs/器件手册索引.md`
- Verify: `firmware/README.md`
- Verify: `proteus/README.md`

- [x] **Step 1: Build firmware**

Run:

```powershell
.\firmware\build.ps1
```

Expected: command exits successfully and prints the generated HEX path.

- [x] **Step 2: Inspect HEX**

Run:

```powershell
Get-Item build\topic3_car.hex
Get-Content build\topic3_car.hex -TotalCount 5
```

Expected: file exists and begins with Intel HEX records starting with `:`.

- [x] **Step 3: Check documentation references**

Run:

```powershell
rg -n "refs/datasheets|firmware/asm/topic3_car.a51|Proteus|A51|HC-SR04|L293D" docs firmware proteus
```

Expected: docs mention the datasheets, assembly source, build tool, and Proteus workflow.
