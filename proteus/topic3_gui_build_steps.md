# Topic 3 Proteus GUI Build Steps

Use this worksheet when creating the final `proteus/topic3_car.pdsprj` manually. Do not submit the generated starter projects as the final file.

## 1 New Project

Start from PowerShell:

```powershell
.\tools\start_final_proteus_session.ps1 -OpenReferences
```

1. Open Proteus 8 Professional.
2. Create a new schematic-only project.
3. Save it as `D:\C51BigHomeWork\proteus\topic3_car.pdsprj`.
4. Keep `proteus/topic3_bom.csv` and `proteus/topic3_car_wiring.csv` open while placing parts.

## 2 Place Core Parts

| Step | Action | Check |
| --- | --- | --- |
| 2.1 | Place `U1` as `AT89C52` or `AT89C51` | MCU is visible and has P0/P1/P2/P3 pins |
| 2.2 | Set `U1` clock to `12MHz` | Timer0 distance threshold remains 870 us |
| 2.3 | Set `U1` Program File to `D:\C51BigHomeWork\build\topic3_car.hex` | Firmware path is absolute |
| 2.4 | Connect `EA` to `VCC_5V` | Internal program memory mode |
| 2.5 | Place `Y1`, `C1`, `C2`, `R13`, `C3` | Minimum system is complete |

## 3 Wire LEDs And Keys

| Step | Action | Check |
| --- | --- | --- |
| 3.1 | Place `D1-D8` and `R1-R8` | LED anodes connect to `VCC_5V` |
| 3.2 | Wire LED cathode nets `LED0_DRV` to `LED7_DRV` to `P1.0-P1.7` | Active-low logic matches firmware |
| 3.3 | Place `SW1-SW4` and `R9-R12` | Each key net is pulled up to `VCC_5V` |
| 3.4 | Wire `KEY_UP_N`, `KEY_DOWN_N`, `KEY_START_N`, `KEY_MODE_N` to `P3.0-P3.3` | Pressing a key connects the net to `GND` |

## 4 Wire LCD1602

| Step | Action | Check |
| --- | --- | --- |
| 4.1 | Place `U2` as `LM016L` or LCD16X2 | Pins `RS`, `RW`, `E`, `D4-D7` are available |
| 4.2 | Wire `LCD_RS`, `LCD_EN`, `LCD_D4-D7` to `P0.0-P0.5` | 4-bit LCD bus matches firmware |
| 4.3 | Tie `RW` to `GND` | Write-only mode |
| 4.4 | Connect `VSS`, `VDD`, `VEE` | Contrast is adjustable through `VR1` or divider |
| 4.5 | Add `RP1` pull-ups on P0 lines if LCD does not respond | P0 open-drain issue is handled |

## 5 Wire Motor Driver

| Step | Action | Check |
| --- | --- | --- |
| 5.1 | Place `U3` as `L293D`, `M1`, and `M2` | Two DC motors are visible |
| 5.2 | Wire `L_IN1`, `L_IN2`, `R_IN1`, `R_IN2` to `P2.0-P2.3` | Direction inputs match firmware |
| 5.3 | Wire `L_EN`, `R_EN` to `P2.4-P2.5` | Enables are active high |
| 5.4 | Wire `1Y/2Y` to `M1` and `3Y/4Y` to `M2` | Left and right motors are separated |
| 5.5 | Connect `VCC1` to `VCC_5V`, `VCC2` to `MOTOR_VCC`, all `GND` pins to common ground | Logic and motor supplies share ground |

## 6 Wire Ultrasonic Or Pulse Substitute

| Step | Action | Check |
| --- | --- | --- |
| 6.1 | Place `U4` as `HC-SR04` if available | `Trig` and `Echo` pins are visible |
| 6.2 | Wire `US_TRIG` to `P3.4`, `US_ECHO` to `P3.5` | Firmware can trigger and time Echo |
| 6.3 | If no HC-SR04 exists, place `V1` pulse source and connect output to `US_ECHO` | Keep `US_TRIG` visible on a probe |
| 6.4 | Use `proteus/topic3_echo_test_inputs.csv` for pulse settings | Test no echo, 500 us, 870 us, and 2000 us |

## 7 First Simulation Run

1. Run `.\firmware\build.ps1` before opening the project.
2. Start simulation.
3. Confirm LCD first line reaches `TOPIC3 READY` or a later state message.
4. Press `KEY_UP`; LEDs should flow from `P1.0` toward `P1.7`.
5. Press `KEY_DOWN`; LEDs should flow from `P1.7` toward `P1.0`.
6. Press `KEY_START`; the car enters auto mode.
7. Apply Echo pulse widths from `proteus/topic3_echo_test_inputs.csv`.
8. Capture screenshots for the report and record the 20-second demo.

## 8 Final Save

Save and close the final project as:

```text
D:\C51BigHomeWork\proteus\topic3_car.pdsprj
```

Then run:

```powershell
.\tools\check_final_submission.ps1
```
