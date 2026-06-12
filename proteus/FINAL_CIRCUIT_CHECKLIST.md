# Final Proteus Circuit Checklist

Use this checklist to create the final `proteus/topic3_car.pdsprj` schematic from scratch in Proteus 8 Professional. The generated starter projects are only local references; this final schematic should be built manually so it belongs to this coursework project.

Before wiring, run `.\tools\check_topic3_proteus_plan.ps1` and keep `proteus/topic3_bom.csv`, `proteus/topic3_gui_build_steps.md`, and `proteus/topic3_car_wiring.csv` open. This checklist gives the build order; the CSV files give component references, pins, net names, values, and substitutes.

## 1 Components

| Qty | Proteus Search Term | Purpose |
| --- | --- | --- |
| 1 | `AT89C52` or `AT89C51` | 8051-compatible simulation MCU for STC89C52 |
| 1 | `LM016L` | LCD1602-compatible display |
| 1 | `L293D` | Dual DC motor driver |
| 2 | `MOTOR-DC` | Left and right motors |
| 8 | `LED-RED` | LED flow display |
| 8 | `RES` | LED current limiting, 220 ohm to 1 kohm |
| 4 | `BUTTON` | Active-low keys |
| 4 | `RES` or `RESPACK` | Pull-up resistors, 4.7 kohm to 10 kohm |
| 1 | `RESPACK-8` or 6 x `RES` | P0 pull-up resistors for LCD data/control lines if required |
| 1 | `CRYSTAL` | 12 MHz crystal |
| 2 | `CAP` | 30 pF crystal capacitors |
| 1 | `CAP-ELEC` | Reset capacitor, about 10 uF |
| 1 | `RES` | Reset resistor, about 10 kohm |
| 1 | `HC-SR04` if available | Ultrasonic module |
| 1 | `PULSE` or `CLOCK` | Echo pulse substitute if HC-SR04 is unavailable |
| 1 | `VCC` | 5 V logic rail |
| 1 | `GROUND` | Common ground |

## 2 MCU Setup

1. Place `AT89C52` if available; otherwise use `AT89C51`.
2. Set clock frequency to `12MHz`.
3. Set Program File to `D:\C51BigHomeWork\build\topic3_car.hex`.
4. Connect `EA` to `VCC`.
5. Connect `VCC` and `GND`.
6. Add 12 MHz crystal and two 30 pF capacitors on `XTAL1`/`XTAL2`.
7. Add reset RC circuit on `RST`.

## 3 Wiring Table

| Firmware Signal | Proteus Connection |
| --- | --- |
| `P1.0-P1.7` | LED cathodes through resistors; LED anodes to VCC for active-low display |
| `P3.0` | `KEY_UP`, button to GND, pull-up to VCC |
| `P3.1` | `KEY_DOWN`, button to GND, pull-up to VCC |
| `P3.2` | `KEY_START`, button to GND, pull-up to VCC |
| `P3.3` | `KEY_MODE`, button to GND, pull-up to VCC |
| `P3.4` | HC-SR04 `Trig` |
| `P3.5` | HC-SR04 `Echo` or pulse generator output |
| `P2.0` | L293D `1A` |
| `P2.1` | L293D `2A` |
| `P2.2` | L293D `3A` |
| `P2.3` | L293D `4A` |
| `P2.4` | L293D `1,2EN` |
| `P2.5` | L293D `3,4EN` |
| `P0.0` | LCD `RS` |
| `P0.1` | LCD `E` |
| `P0.2` | LCD `D4` |
| `P0.3` | LCD `D5` |
| `P0.4` | LCD `D6` |
| `P0.5` | LCD `D7` |
| `P0.0-P0.5` | Add pull-up resistors to VCC if the selected 8051 model requires open-drain P0 behavior |
| LCD `RW` | GND |
| LCD `VSS/VDD/VEE` | GND/VCC/contrast potentiometer or fixed divider |
| L293D `VCC1` | VCC 5 V |
| L293D `VCC2` | Motor supply, 5 V to 9 V in simulation |
| L293D `GND` pins | Common ground |

## 4 Echo Pulse Substitute

If the Proteus library does not include HC-SR04, use a pulse source on `P3.5`. Keep `P3.4` visible with a logic probe or oscilloscope so the Trig pulse can still be observed.

| Test | Echo Pulse Width | Expected Firmware Decision |
| --- | --- | --- |
| No echo | Keep low | LCD shows `NO ECHO`, car stops |
| Safe distance | Wider than 870 us | P2 outputs forward code `35H` |
| Dangerous distance | Shorter than 870 us | Stop, reverse, right turn, stop |

The 870 us threshold comes from:

```text
15 cm * 58 us/cm = 870 us = 0366H
```

Suggested pulse source settings for manual testing:

| Scenario | Initial Delay | High Time | Low Time / Period | Purpose |
| --- | --- | --- | --- | --- |
| Safe distance | 2 ms | 2000 us | 20 ms | Simulates about 34 cm |
| Dangerous distance | 2 ms | 500 us | 20 ms | Simulates about 8 cm |
| No echo | output held low | 0 us | continuous low | Tests timeout path |

If the pulse source repeats continuously, start with a period of 20 ms or longer so the firmware has time to finish one measurement and LCD update before the next Echo pulse.

The same pulse settings are recorded in `proteus/topic3_echo_test_inputs.csv` so they can be checked and reused when recording the final screenshots or video.

## 5 Acceptance Checks

- [ ] `KEY_UP` switches to upward LED flow.
- [ ] `KEY_DOWN` switches to downward LED flow.
- [ ] `KEY_START` enters car auto mode.
- [ ] LCD displays `TOPIC3 READY` after reset.
- [ ] Valid Echo measurement displays `DIST:xxxcm` on LCD line 2.
- [ ] Safe Echo pulse drives both motors forward.
- [ ] Dangerous Echo pulse triggers stop, reverse, right turn, stop.
- [ ] All grounds are common.
- [ ] Screenshots are captured for initial LCD display, LED flow, safe Echo, and dangerous Echo cases.
- [ ] The final file is saved as `proteus/topic3_car.pdsprj`.
