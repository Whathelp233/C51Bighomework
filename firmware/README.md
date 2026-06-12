# Firmware

This folder contains the first Keil A51 assembly implementation for topic 3.

## Toolchain

The local machine has Keil C51 tools installed at:

```text
C:\Keil_v5\C51\BIN\A51.EXE
C:\Keil_v5\C51\BIN\BL51.EXE
C:\Keil_v5\C51\BIN\OH51.EXE
```

Proteus also includes ASEM51, but this project uses Keil A51 because it matches the C51 course workflow and can generate a HEX file for Proteus.

## Build

Run from the repository root:

```powershell
.\firmware\build.ps1
```

Expected output:

```text
Generated D:\C51BigHomeWork\build\topic3_car.hex
```

## Port Map

| MCU Pin | Signal | Description |
| --- | --- | --- |
| P1.0-P1.7 | LED0-LED7 | Active-low LED flow output |
| P3.0 | KEY_UP | Active-low key for upward LED flow |
| P3.1 | KEY_DOWN | Active-low key for downward LED flow |
| P3.2 | KEY_START | Active-low key for car start/stop |
| P3.3 | KEY_MODE | Active-low key for clean/car mode |
| P3.4 | US_TRIG | HC-SR04 trigger output |
| P3.5 | US_ECHO | HC-SR04 echo input |
| P2.0 | Left IN1 | L293D left motor direction input |
| P2.1 | Left IN2 | L293D left motor direction input |
| P2.2 | Right IN3 | L293D right motor direction input |
| P2.3 | Right IN4 | L293D right motor direction input |
| P2.4 | ENA | L293D left motor enable |
| P2.5 | ENB | L293D right motor enable |
| P0.0 | LCD_RS | LCD1602 register select |
| P0.1 | LCD_EN | LCD1602 enable |
| P0.2-P0.5 | LCD_D4-D7 | LCD1602 4-bit data bus |

## Current Behavior

- `KEY_UP` switches to upward LED flow and stops the car.
- `KEY_DOWN` switches to downward LED flow and stops the car.
- `KEY_START` toggles auto car mode.
- Auto car mode triggers HC-SR04 measurement on P3.4/P3.5.
- If the Echo pulse is shorter than the 15 cm threshold, the firmware stops, backs up, turns right, and stops.
- LCD1602 line 1 shows status messages; line 2 shows measured distance as `DIST:xxxcm` when Echo is valid.
