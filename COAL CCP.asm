; =========================================================
; REMOTE AREA RESOURCE MANAGEMENT SYSTEM
; EMU8086 – ERROR FREE VERSION
; =========================================================

.MODEL SMALL
.STACK 100H

.DATA
MAX_RECORDS EQU 50
RECORD_COUNT DW 0

SR_NO DW MAX_RECORDS DUP(0)
NAMES DB MAX_RECORDS*20 DUP(' ')

MENU_MSG DB 13,10,'1.Add  4.Display  0.Exit',13,10,'Choice: $'
PROMPT_SR DB 13,10,'Enter Sr#: $'
PROMPT_NAME DB 13,10,'Enter Name: $'
MSG_DONE DB 13,10,'Done!$'
NEWLINE DB 13,10,'$'

TEMP_NAME DB 20 DUP(' ')

.CODE
MAIN PROC
    MOV AX,@DATA
    MOV DS,AX

MAIN_LOOP:
    LEA DX,MENU_MSG
    MOV AH,09H
    INT 21H

    MOV AH,01H
    INT 21H
    SUB AL,30H

    CMP AL,0
    JE EXIT
    CMP AL,1
    JE ADD_REC
    CMP AL,4
    JE DISPLAY
    JMP MAIN_LOOP

ADD_REC:
    CALL ADD_RECORD
    JMP MAIN_LOOP

DISPLAY:
    CALL DISPLAY_ALL
    JMP MAIN_LOOP

EXIT:
    MOV AH,4CH
    INT 21H
MAIN ENDP

; ================= ADD RECORD =================
ADD_RECORD PROC
    CMP RECORD_COUNT,MAX_RECORDS
    JGE DONE_ADD

    LEA DX,PROMPT_SR
    MOV AH,09H
    INT 21H
    CALL READ_NUMBER

    MOV BX,RECORD_COUNT
    SHL BX,1
    MOV SR_NO[BX],AX

    LEA DX,PROMPT_NAME
    MOV AH,09H
    INT 21H
    LEA DX,TEMP_NAME
    CALL READ_STRING

    MOV AX,RECORD_COUNT
    MOV CX,20
    MUL CX
    LEA SI,TEMP_NAME
    LEA DI,NAMES
    ADD DI,AX
    MOV CX,20
    REP MOVSB

    INC RECORD_COUNT

DONE_ADD:
    LEA DX,MSG_DONE
    MOV AH,09H
    INT 21H
    RET
ADD_RECORD ENDP

; ================= DISPLAY =================
DISPLAY_ALL PROC
    CMP RECORD_COUNT,0
    JE DISP_END

    MOV CX,0
DISP_LOOP:
    CMP CX,RECORD_COUNT
    JGE DISP_END

    MOV BX,CX
    SHL BX,1
    MOV AX,SR_NO[BX]
    CALL PRINT_NUMBER

    LEA DX,NEWLINE
    MOV AH,09H
    INT 21H

    INC CX
    JMP DISP_LOOP

DISP_END:
    RET
DISPLAY_ALL ENDP

; ================= READ NUMBER =================
READ_NUMBER PROC
    XOR AX,AX
    MOV BX,10
READ_DIG:
    MOV AH,01H
    INT 21H
    CMP AL,13
    JE DONE_NUM
    SUB AL,30H
    MOV CX,AX
    MUL BX
    ADD AX,CX
    JMP READ_DIG
DONE_NUM:
    RET
READ_NUMBER ENDP

; ================= READ STRING =================
READ_STRING PROC
    MOV CX,20
READ_CH:
    MOV AH,01H
    INT 21H
    CMP AL,13
    JE FILL
    MOV SI, DX     
    MOV [SI], AL
    INC DX
    LOOP READ_CH
    JMP END_STR

FILL:
    MOV AL,' '
FILL_LOOP:
    MOV SI, DX     
MOV [SI], AL
    INC DX
    LOOP FILL_LOOP

END_STR:
    RET
READ_STRING ENDP

; ================= PRINT NUMBER =================
PRINT_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX,10
    XOR CX,CX
DIV_LOOP:
    XOR DX,DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX,0
    JNE DIV_LOOP

PRINT_LOOP:
    POP DX
    ADD DL,30H
    MOV AH,02H
    INT 21H
    LOOP PRINT_LOOP

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUMBER ENDP

END MAIN
