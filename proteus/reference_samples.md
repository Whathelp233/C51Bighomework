# Proteus Reference Samples

These built-in Proteus samples are useful references when drawing the final topic 3 schematic manually. They should not be submitted as the final project file.

| Purpose | Sample Path | Use In This Project |
| --- | --- | --- |
| 8051 with LCD1602 | `C:\ProgramData\Labcenter Electronics\Proteus 8 Professional\SAMPLES\VSM for 8051\8051 with LCD1602 LCD controller\LCD1602.pdsprj` | Reference LCD1602 placement and 8051 firmware attachment |
| 8051 DC motor controller | `C:\ProgramData\Labcenter Electronics\Proteus 8 Professional\SAMPLES\VSM for 8051\8051 DC Motor Controller\8051 DC Motor Controller.pdsprj` | Reference 8051 motor output and DC motor simulation |
| SRF04 ultrasonic ranger | `C:\ProgramData\Labcenter Electronics\Proteus 8 Professional\SAMPLES\VSM for AVR\SRF04 Ultrasonic Ranger\SRF04 Ultrasonic Ranger.pdsprj` | Reference ultrasonic Echo timing if HC-SR04 is unavailable |
| Grove ultrasonic ranger | `C:\ProgramData\Labcenter Electronics\Proteus 8 Professional\SAMPLES\VSM for Arduino\Grove Ultrasonic Ranger\Grove Ultrasonic Ranger.pdsprj` | Reference ultrasonic module behavior and distance display |

Open local starter projects after generating them:

```powershell
.\firmware\build.ps1
.\tools\create_proteus_starters.ps1
.\tools\launch_proteus.ps1 -Project lcd
.\tools\launch_proteus.ps1 -Project motor
```

The final schematic still needs to be created as:

```text
D:\C51BigHomeWork\proteus\topic3_car.pdsprj
```

Use `proteus/topic3_car_wiring.csv` as the exact net table and `proteus/topic3_echo_test_inputs.csv` as the pulse-source test table.
