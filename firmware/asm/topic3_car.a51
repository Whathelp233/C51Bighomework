$MOD51

; Topic 3: LED flow and ultrasonic obstacle-avoidance car.
; Target: STC89C52 / 8051 compatible MCU, Keil A51 syntax.

; -----------------------------
; Pin map
; -----------------------------
KEY_UP      BIT P3.0
KEY_DOWN    BIT P3.1
KEY_START   BIT P3.2
KEY_MODE    BIT P3.3
US_TRIG     BIT P3.4
US_ECHO     BIT P3.5

LCD_RS      BIT P0.0
LCD_EN      BIT P0.1

; P1.0-P1.7: active-low LEDs.
; P2.0/P2.1: left motor IN1/IN2.
; P2.2/P2.3: right motor IN3/IN4.
; P2.4/P2.5: left/right enable.

; -----------------------------
; Internal RAM variables
; -----------------------------
MODE        DATA 30H
LED_PAT     DATA 31H
CAR_RUN     DATA 32H
DIST_H      DATA 33H
DIST_L      DATA 34H
DIST_VALID  DATA 35H
CM_H        DATA 36H
CM_L        DATA 37H
TMP_H       DATA 38H
TMP_L       DATA 39H
DIG_HUND    DATA 3AH
DIG_TENS    DATA 3BH
DIG_ONES    DATA 3CH

MODE_LED_UP     EQU 00H
MODE_LED_DOWN   EQU 01H
MODE_CAR_AUTO   EQU 02H

MOTOR_STOP      EQU 00H
MOTOR_FORWARD   EQU 35H
MOTOR_BACKWARD  EQU 3AH
MOTOR_LEFT      EQU 36H
MOTOR_RIGHT     EQU 39H

DANGER_H        EQU 03H      ; 15 cm * 58 us = 870 us = 0366H
DANGER_L        EQU 66H

            ORG 0000H
            LJMP START

            ORG 0030H

START:
            MOV SP,#60H
            MOV P0,#0FFH
            MOV P1,#0FFH
            MOV P2,#MOTOR_STOP
            MOV P3,#0FFH
            CLR US_TRIG

            MOV MODE,#MODE_LED_UP
            MOV LED_PAT,#01H
            MOV CAR_RUN,#00H
            MOV DIST_VALID,#00H

            ACALL LCD_INIT
            MOV DPTR,#MSG_READY
            ACALL LCD_PRINT_LINE1
            MOV DPTR,#MSG_LED_UP
            ACALL LCD_PRINT_LINE2

MAIN_LOOP:
            ACALL KEY_SCAN
            ACALL LED_TASK
            ACALL CAR_TASK
            SJMP MAIN_LOOP

; -----------------------------
; Key handling
; Active-low independent keys.
; -----------------------------
KEY_SCAN:
            JB KEY_UP,KS_DOWN
            ACALL DEBOUNCE
            JB KEY_UP,KS_DOWN
            MOV MODE,#MODE_LED_UP
            MOV LED_PAT,#01H
            MOV CAR_RUN,#00H
            ACALL CAR_STOP
            MOV DPTR,#MSG_LED_UP
            ACALL LCD_PRINT_LINE2
            ACALL WAIT_KEYS_RELEASE
            RET

KS_DOWN:
            JB KEY_DOWN,KS_START
            ACALL DEBOUNCE
            JB KEY_DOWN,KS_START
            MOV MODE,#MODE_LED_DOWN
            MOV LED_PAT,#80H
            MOV CAR_RUN,#00H
            ACALL CAR_STOP
            MOV DPTR,#MSG_LED_DN
            ACALL LCD_PRINT_LINE2
            ACALL WAIT_KEYS_RELEASE
            RET

KS_START:
            JB KEY_START,KS_MODE
            ACALL DEBOUNCE
            JB KEY_START,KS_MODE
            MOV MODE,#MODE_CAR_AUTO
            MOV A,CAR_RUN
            JZ KS_START_ON
            MOV CAR_RUN,#00H
            ACALL CAR_STOP
            MOV DPTR,#MSG_CAR_STOP
            ACALL LCD_PRINT_LINE2
            SJMP KS_START_DONE
KS_START_ON:
            MOV CAR_RUN,#01H
            MOV DPTR,#MSG_CAR_RUN
            ACALL LCD_PRINT_LINE2
KS_START_DONE:
            ACALL WAIT_KEYS_RELEASE
            RET

KS_MODE:
            JB KEY_MODE,KS_EXIT
            ACALL DEBOUNCE
            JB KEY_MODE,KS_EXIT
            MOV MODE,#MODE_CAR_AUTO
            MOV CAR_RUN,#01H
            MOV DPTR,#MSG_CLEAN
            ACALL LCD_PRINT_LINE2
            ACALL WAIT_KEYS_RELEASE
KS_EXIT:
            RET

WAIT_KEYS_RELEASE:
            JNB KEY_UP,WAIT_KEYS_RELEASE
            JNB KEY_DOWN,WAIT_KEYS_RELEASE
            JNB KEY_START,WAIT_KEYS_RELEASE
            JNB KEY_MODE,WAIT_KEYS_RELEASE
            RET

; -----------------------------
; LED task
; -----------------------------
LED_TASK:
            MOV A,MODE
            CJNE A,#MODE_LED_UP,LED_CHECK_DOWN
            MOV A,LED_PAT
            CPL A
            MOV P1,A
            MOV A,LED_PAT
            RL A
            JNZ LED_SAVE
            MOV A,#01H
LED_SAVE:
            MOV LED_PAT,A
            ACALL DELAY_LED
            RET

LED_CHECK_DOWN:
            CJNE A,#MODE_LED_DOWN,LED_IDLE
            MOV A,LED_PAT
            CPL A
            MOV P1,A
            MOV A,LED_PAT
            RR A
            JNZ LED_SAVE_DN
            MOV A,#80H
LED_SAVE_DN:
            MOV LED_PAT,A
            ACALL DELAY_LED
LED_IDLE:
            RET

; -----------------------------
; Car task and obstacle decision
; -----------------------------
CAR_TASK:
            MOV A,MODE
            CJNE A,#MODE_CAR_AUTO,CAR_TASK_EXIT
            MOV A,CAR_RUN
            JZ CAR_TASK_STOP

            ACALL MEASURE_DISTANCE
            MOV A,DIST_VALID
            JZ CAR_NO_ECHO

            ACALL DIST_LT_DANGER
            JC CAR_AVOID

            ACALL CAR_FORWARD
            MOV DPTR,#MSG_CLEAR
            ACALL LCD_PRINT_LINE1
            ACALL LCD_PRINT_DISTANCE
            RET

CAR_NO_ECHO:
            ACALL CAR_STOP
            MOV DPTR,#MSG_CAR_STOP
            ACALL LCD_PRINT_LINE1
            MOV DPTR,#MSG_NO_ECHO
            ACALL LCD_PRINT_LINE2
            RET

CAR_AVOID:
            ACALL CAR_STOP
            MOV DPTR,#MSG_AVOID
            ACALL LCD_PRINT_LINE1
            ACALL LCD_PRINT_DISTANCE
            ACALL DELAY_ACTION
            ACALL CAR_BACKWARD
            ACALL DELAY_ACTION
            ACALL CAR_RIGHT
            ACALL DELAY_ACTION
            ACALL CAR_STOP
            RET

CAR_TASK_STOP:
            ACALL CAR_STOP
CAR_TASK_EXIT:
            RET

; Return C=1 when measured Echo timer count is less than danger threshold.
DIST_LT_DANGER:
            MOV A,DIST_H
            CJNE A,#DANGER_H,DLD_H_DIFF
            MOV A,DIST_L
            CJNE A,#DANGER_L,DLD_L_DIFF
            CLR C
            RET
DLD_H_DIFF:
            JC DLD_TRUE
            CLR C
            RET
DLD_L_DIFF:
            JC DLD_TRUE
            CLR C
            RET
DLD_TRUE:
            SETB C
            RET

; -----------------------------
; HC-SR04 measurement
; Timer0 mode 1, assumes 12 MHz crystal: about 1 us per count.
; -----------------------------
MEASURE_DISTANCE:
            MOV DIST_VALID,#00H
            CLR US_TRIG
            ACALL DELAY_10US
            SETB US_TRIG
            ACALL DELAY_10US
            CLR US_TRIG

            MOV R6,#0FFH
WAIT_ECHO_HIGH:
            JB US_ECHO,ECHO_HIGH
            DJNZ R6,WAIT_ECHO_HIGH
            RET

ECHO_HIGH:
            ANL TMOD,#0F0H
            ORL TMOD,#01H
            CLR TR0
            CLR TF0
            MOV TH0,#00H
            MOV TL0,#00H
            SETB TR0

WAIT_ECHO_LOW:
            JNB US_ECHO,ECHO_DONE
            JNB TF0,WAIT_ECHO_LOW
            CLR TR0
            RET

ECHO_DONE:
            CLR TR0
            MOV DIST_H,TH0
            MOV DIST_L,TL0
            MOV DIST_VALID,#01H
            RET

; -----------------------------
; Distance conversion and display
; Converts Echo timer count in microseconds to centimeters:
; cm = us / 58. Result is clamped to 999 for 3-digit LCD display.
; -----------------------------
LCD_PRINT_DISTANCE:
            ACALL ECHO_TO_DIGITS
            MOV A,#0C0H
            ACALL LCD_CMD
            MOV A,#'D'
            ACALL LCD_DATA
            MOV A,#'I'
            ACALL LCD_DATA
            MOV A,#'S'
            ACALL LCD_DATA
            MOV A,#'T'
            ACALL LCD_DATA
            MOV A,#':'
            ACALL LCD_DATA
            MOV A,DIG_HUND
            ADD A,#'0'
            ACALL LCD_DATA
            MOV A,DIG_TENS
            ADD A,#'0'
            ACALL LCD_DATA
            MOV A,DIG_ONES
            ADD A,#'0'
            ACALL LCD_DATA
            MOV A,#'c'
            ACALL LCD_DATA
            MOV A,#'m'
            ACALL LCD_DATA
            MOV R5,#06H
LPD_PAD:
            MOV A,#' '
            ACALL LCD_DATA
            DJNZ R5,LPD_PAD
            RET

ECHO_TO_DIGITS:
            ACALL ECHO_TO_CM
            ACALL CLAMP_CM_999
            MOV DIG_HUND,#00H
            MOV DIG_TENS,#00H

ETD_HUND_LOOP:
            MOV A,CM_H
            JNZ ETD_SUB_100
            MOV A,CM_L
            CLR C
            SUBB A,#064H
            JC ETD_HUND_DONE
ETD_SUB_100:
            MOV A,CM_L
            CLR C
            SUBB A,#064H
            MOV CM_L,A
            MOV A,CM_H
            SUBB A,#00H
            MOV CM_H,A
            INC DIG_HUND
            SJMP ETD_HUND_LOOP

ETD_HUND_DONE:
ETD_TENS_LOOP:
            MOV A,CM_L
            CLR C
            SUBB A,#00AH
            JC ETD_TENS_DONE
            MOV CM_L,A
            INC DIG_TENS
            SJMP ETD_TENS_LOOP

ETD_TENS_DONE:
            MOV A,CM_L
            MOV DIG_ONES,A
            RET

ECHO_TO_CM:
            MOV TMP_H,DIST_H
            MOV TMP_L,DIST_L
            MOV CM_H,#00H
            MOV CM_L,#00H

ETC_LOOP:
            MOV A,TMP_H
            JNZ ETC_SUB_58
            MOV A,TMP_L
            CLR C
            SUBB A,#03AH
            JC ETC_DONE

ETC_SUB_58:
            MOV A,TMP_L
            CLR C
            SUBB A,#03AH
            MOV TMP_L,A
            MOV A,TMP_H
            SUBB A,#00H
            MOV TMP_H,A
            INC CM_L
            MOV A,CM_L
            JNZ ETC_LOOP
            INC CM_H
            SJMP ETC_LOOP

ETC_DONE:
            RET

CLAMP_CM_999:
            MOV A,CM_H
            CJNE A,#04H,CC_CHECK_H4
            SJMP CC_SET_999
CC_CHECK_H4:
            JC CC_CHECK_3
            SJMP CC_SET_999
CC_CHECK_3:
            MOV A,CM_H
            CJNE A,#03H,CC_OK
            MOV A,CM_L
            CLR C
            SUBB A,#0E8H
            JNC CC_SET_999
CC_OK:
            RET
CC_SET_999:
            MOV CM_H,#03H
            MOV CM_L,#0E7H
            RET

; -----------------------------
; Motor output routines
; -----------------------------
CAR_STOP:
            MOV P2,#MOTOR_STOP
            RET

CAR_FORWARD:
            MOV P2,#MOTOR_FORWARD
            RET

CAR_BACKWARD:
            MOV P2,#MOTOR_BACKWARD
            RET

CAR_LEFT:
            MOV P2,#MOTOR_LEFT
            RET

CAR_RIGHT:
            MOV P2,#MOTOR_RIGHT
            RET

; -----------------------------
; LCD1602 4-bit write-only routines
; P0.0=RS, P0.1=EN, P0.2-P0.5=D4-D7.
; -----------------------------
LCD_INIT:
            ACALL DELAY_POWER
            CLR LCD_RS
            CLR LCD_EN
            MOV A,#03H
            ACALL LCD_WRITE_NIBBLE
            ACALL DELAY_5MS
            MOV A,#03H
            ACALL LCD_WRITE_NIBBLE
            ACALL DELAY_5MS
            MOV A,#03H
            ACALL LCD_WRITE_NIBBLE
            ACALL DELAY_5MS
            MOV A,#02H
            ACALL LCD_WRITE_NIBBLE
            MOV A,#028H
            ACALL LCD_CMD
            MOV A,#00CH
            ACALL LCD_CMD
            MOV A,#006H
            ACALL LCD_CMD
            MOV A,#001H
            ACALL LCD_CMD
            ACALL DELAY_5MS
            RET

LCD_PRINT_LINE1:
            MOV A,#080H
            ACALL LCD_CMD
            SJMP LCD_PUTS

LCD_PRINT_LINE2:
            MOV A,#0C0H
            ACALL LCD_CMD
            SJMP LCD_PUTS

LCD_PUTS:
            MOV R5,#16
LCD_PUTS_LOOP:
            CLR A
            MOVC A,@A+DPTR
            JZ LCD_PAD
            ACALL LCD_DATA
            INC DPTR
            DJNZ R5,LCD_PUTS_LOOP
            RET
LCD_PAD:
            MOV A,#' '
            ACALL LCD_DATA
            DJNZ R5,LCD_PAD
            RET

LCD_CMD:
            CLR LCD_RS
            ACALL LCD_WRITE_BYTE
            ACALL DELAY_SHORT
            RET

LCD_DATA:
            SETB LCD_RS
            ACALL LCD_WRITE_BYTE
            ACALL DELAY_SHORT
            RET

LCD_WRITE_BYTE:
            MOV R7,A
            SWAP A
            ANL A,#0FH
            ACALL LCD_WRITE_NIBBLE
            MOV A,R7
            ANL A,#0FH
            ACALL LCD_WRITE_NIBBLE
            RET

LCD_WRITE_NIBBLE:
            MOV R7,A
            ANL P0,#0C3H
            MOV A,R7
            ANL A,#0FH
            RL A
            RL A
            ORL P0,A
            SETB LCD_EN
            ACALL DELAY_SHORT
            CLR LCD_EN
            ACALL DELAY_SHORT
            RET

; -----------------------------
; Delays
; -----------------------------
DEBOUNCE:
            ACALL DELAY_5MS
            ACALL DELAY_5MS
            RET

DELAY_10US:
            NOP
            NOP
            NOP
            NOP
            NOP
            RET

DELAY_SHORT:
            MOV R7,#20
DS1:        DJNZ R7,DS1
            RET

DELAY_5MS:
            MOV R6,#20
D5_OUT:     MOV R7,#250
D5_IN:      DJNZ R7,D5_IN
            DJNZ R6,D5_OUT
            RET

DELAY_LED:
            MOV R4,#6
DL_OUT:     ACALL DELAY_5MS
            DJNZ R4,DL_OUT
            RET

DELAY_ACTION:
            MOV R3,#40
DA_OUT:     ACALL DELAY_5MS
            DJNZ R3,DA_OUT
            RET

DELAY_POWER:
            MOV R2,#10
DP_OUT:     ACALL DELAY_5MS
            DJNZ R2,DP_OUT
            RET

; -----------------------------
; LCD messages, max 16 chars.
; -----------------------------
MSG_READY:      DB 'TOPIC3 READY',0
MSG_LED_UP:     DB 'LED UP',0
MSG_LED_DN:     DB 'LED DOWN',0
MSG_CAR_RUN:    DB 'CAR RUN',0
MSG_CAR_STOP:   DB 'CAR STOP',0
MSG_CLEAN:      DB 'CLEAN MODE',0
MSG_CLEAR:      DB 'PATH CLEAR',0
MSG_NO_ECHO:    DB 'NO ECHO',0
MSG_AVOID:      DB 'OBSTACLE AVOID',0

            END
