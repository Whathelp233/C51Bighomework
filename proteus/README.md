# Proteus Simulation Guide

Proteus 8 Professional is installed locally:

```text
C:\Program Files (x86)\Labcenter Electronics\Proteus 8 Professional\BIN\PDS.EXE
```

Create the final Proteus project manually as `proteus/topic3_car.pdsprj`, then load:

```text
D:\C51BigHomeWork\build\topic3_car.hex
```

into the 8051-compatible MCU.

Use these prepared files while drawing the schematic:

```text
proteus/topic3_car_wiring.csv
proteus/topic3_echo_test_inputs.csv
proteus/topic3_bom.csv
proteus/topic3_gui_build_steps.md
proteus/reference_samples.md
docs/proteus自动生成可行性调查.md
```

## Local Starter Projects

The helper script `tools/create_proteus_starters.ps1` can generate two local starter projects:

```text
proteus/topic3_lcd1602_starter.pdsprj
proteus/topic3_dc_motor_starter.pdsprj
```

These files are copied from the Proteus built-in 8051 samples and have their firmware attachment replaced with `build/topic3_car.hex`. They are useful for checking that Proteus can open an 8051 project and load this firmware, but they are not the final topic 3 circuit and are ignored by Git because they derive from Labcenter sample content.

Run:

```powershell
.\firmware\build.ps1
.\tools\create_proteus_starters.ps1
.\tools\check_proteus_starters.ps1
```

Open a project from PowerShell after the project file exists:

```powershell
.\tools\launch_proteus.ps1 -Project final
```

Starter references can be opened with:

```powershell
.\tools\launch_proteus.ps1 -Project lcd
.\tools\launch_proteus.ps1 -Project motor
```

Command-line probing of `PDS.EXE /?` and `PROSPICE.EXE /?` did not expose a reliable schematic-generation interface in this local installation, so the final `topic3_car.pdsprj` still needs to be wired in the Proteus GUI using `proteus/FINAL_CIRCUIT_CHECKLIST.md` and `proteus/topic3_car_wiring.csv`.

Run this consistency check before drawing the final schematic:

```powershell
.\tools\check_topic3_proteus_plan.ps1
```

Start the final GUI build session from the repository root:

```powershell
.\tools\start_final_proteus_session.ps1 -OpenReferences
```

This builds the HEX, checks the prepared tables, opens reference files, and launches Proteus. If `proteus/topic3_car.pdsprj` does not exist yet, save the new Proteus project to that exact path.

## Components

The placement list is also available as `proteus/topic3_bom.csv`. Use that CSV for part references and values, then use `proteus/topic3_gui_build_steps.md` for the manual Proteus build sequence.

Use these parts in Proteus:

| Component | Suggested Proteus Part | Notes |
| --- | --- | --- |
| 8051 MCU | AT89C52 or AT89C51 | Use as STC89C52-compatible simulation target |
| LEDs | LED-RED | 8 LEDs with current-limiting resistors |
| Buttons | BUTTON | Active-low, with pull-up or MCU port default high |
| LCD | LM016L or LCD16X2 | HD44780-compatible LCD1602 |
| Motor driver | L293D | Drives two DC motors |
| DC motors | MOTOR-DC | Left and right wheel motors |
| Ultrasonic | HC-SR04 if available | If unavailable, simulate Echo with a pulse source |
| Power | VCC/GND | 5 V logic supply, separate motor supply if desired |

## Wiring

The table below is the short port summary. The exact component references, nets, pins, and optional pulse-source substitute are listed in `proteus/topic3_car_wiring.csv`.

| MCU Signal | Proteus Connection |
| --- | --- |
| P1.0-P1.7 | LED0-LED7 through resistors, active-low |
| P3.0 | KEY_UP to GND when pressed |
| P3.1 | KEY_DOWN to GND when pressed |
| P3.2 | KEY_START to GND when pressed |
| P3.3 | KEY_MODE to GND when pressed |
| P3.4 | HC-SR04 Trig |
| P3.5 | HC-SR04 Echo or simulated pulse |
| P2.0/P2.1 | L293D 1A/2A |
| P2.2/P2.3 | L293D 3A/4A |
| P2.4 | L293D 1,2EN |
| P2.5 | L293D 3,4EN |
| P0.0 | LCD RS |
| P0.1 | LCD EN |
| P0.2-P0.5 | LCD D4-D7 |
| P0.0-P0.5 | Add pull-ups to VCC if the selected 8051 model treats P0 as open-drain |
| LCD RW | GND |
| LCD VSS/VDD/VEE | GND/5 V/contrast divider |

## Simulation Checks

1. Build firmware with `.\firmware\build.ps1`.
2. Create `proteus/topic3_car.pdsprj` manually in Proteus.
3. Open Proteus and load `build/topic3_car.hex` into the MCU.
4. Run simulation.
5. Press `KEY_UP`; LEDs should flow from low bit to high bit.
6. Press `KEY_DOWN`; LEDs should flow from high bit to low bit.
7. Press `KEY_START`; P2 should drive L293D for forward motion when Echo is safe.
8. Send a short Echo pulse less than about 870 us; P2 should stop, reverse, turn right, and stop.

## Echo Pulse Notes

At a 12 MHz 8051 clock, Timer0 counts approximately once per microsecond in this firmware. The danger threshold is:

```text
15 cm * 58 us/cm = 870 us = 0366H
```

So an Echo pulse shorter than 870 us is treated as a dangerous close obstacle.

Use `proteus/topic3_echo_test_inputs.csv` for the no-echo, safe-distance, threshold, and danger-distance pulse settings.

Before final submission, run:

```powershell
.\tools\check_final_submission.ps1
```
