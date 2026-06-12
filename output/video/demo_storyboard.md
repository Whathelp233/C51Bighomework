# 20-Second Demo Storyboard

Use this script for `output/video/demo.mp4`. The video should be under 20 seconds and show the actual Proteus simulation or physical car behavior.

Start the final build/recording session with:

```powershell
.\tools\start_final_proteus_session.ps1 -OpenReferences
```

| Time | Shot | Action | Evidence |
| --- | --- | --- | --- |
| 0-3 s | Full schematic or car overview | Show MCU, LCD, LEDs, L293D/motors, and Echo source | Confirms complete system |
| 3-6 s | LED upward mode | Press `KEY_UP` | LEDs flow from P1.0 to P1.7 |
| 6-9 s | LED downward mode | Press `KEY_DOWN` | LEDs flow from P1.7 to P1.0 |
| 9-13 s | Safe distance | Press `KEY_START`; apply 2000 us Echo | LCD shows distance; motors move forward |
| 13-17 s | Dangerous distance | Apply 500 us Echo | LCD shows obstacle state; motors stop/back/turn |
| 17-20 s | End frame | Show final state and project filename if possible | Confirms final project run |

Minimum video checklist:

- `build/topic3_car.hex` is loaded into the Proteus MCU.
- `proteus/topic3_car.pdsprj` is the project shown if recording Proteus.
- The LCD display is readable at least once.
- Both LED directions are shown.
- Safe and dangerous Echo behavior are both shown.
- The final file is saved as `output/video/demo.mp4`.

After recording, run:

```powershell
.\tools\check_final_submission.ps1
```

Alternatively, start this watcher before saving the project and video:

```powershell
.\tools\watch_final_submission.ps1
```
