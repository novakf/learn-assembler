MYDATA SEGMENT 'DATA'
    BUF DB 20 DUP ('1')
    SURNAME DB 'Новиков','$'
    SURNAME_LEN DB 7 
    NO_PARAMS DB 'Нет введеных параметров $'
    FIRST_PARAM DB '1-ый параметр $'
    CORRECT DB 'правильный = $'
    INCORRECT DB 'неправильный$'
    SECOND_CORRECT DB '2-ой параметр есть$'
    SECOND_INCORRECT DB '2-ой параметр отсутствует$'
MYDATA ENDS

MYCODE SEGMENT 'CODE'
 ASSUME CS:MYCODE,DS:MYDATA

PUTCH PROC
    MOV AH , 02H
    INT 021H
    RET
PUTCH ENDP

CRLF PROC
    MOV DL , 10
    CALL PUTCH
    MOV DL , 13
    CALL PUTCH
    RET
CRLF ENDP

GETCH PROC
    MOV AH,01H
    INT 21H
    RET
GETCH ENDP

CLRS PROC
    MOV AH,00
    MOV AL,03
    INT 10h
    RET
CLRS ENDP

PRINT PROC
    PUSH AX
	MOV AH, 09h    ;09H вывод строк
	INT 21H
	POP AX
	RETN
PRINT ENDP

START:
    MOV AX, MYDATA
	MOV ES, AX

    MOV SI, 80H
    MOV CL, [SI]
    CMP CL, 0
    JNE CONTINUE

    PUSH ES
    POP DS

    LEA DX, NO_PARAMS
    CALL PRINT
    JMP EXIT

CONTINUE:
    SUB CL, 1
    
    ADD SI, 2 ;переход к первому аргументу

    CYCLE:
        MOV AL, [SI]
        CMP AL, ' '
        JE COPY
        INC SI
    LOOP CYCLE

COPY:
    SUB SI, 82H ;число символов в аргументе
    PUSH SI
    PUSH SI
    
    MOV SI, 80H
    MOV CL ,[SI]
    SUB CL, 1

    CLD
    MOV SI, 82H  
    LEA DX, BUF
    REP MOVSB ;пересылка по байтам или словам
    PUSH ES
    POP DS
    
    LEA DI, BUF
    LEA SI, SURNAME
    POP CX

    CMP CL, SURNAME_LEN
    JGE COMPARE
    MOV CL, SURNAME_LEN


COMPARE:
    LEA DX, FIRST_PARAM
    CALL PRINT

    REPE CMPSB
    JE FIRST_OK

    ;если не равны
    LEA DX, INCORRECT
    CALL PRINT
    CALL CRLF
    JMP SECOND_ARG

FIRST_OK:
    LEA DX, CORRECT
    CALL PRINT
    LEA DX, SURNAME
    CALL PRINT	
    CALL CRLF

SECOND_ARG:
    MOV SI, OFFSET BUF
    POP CX
    ADD SI, CX
    
    MOV AL, [SI]
    CMP AL, ' '
    JE SECOND_OK
    LEA DX, SECOND_INCORRECT
    CALL PRINT
    CALL CRLF
    JMP EXIT

SECOND_OK:
    LEA DX, SECOND_CORRECT
    CALL PRINT
    CALL CRLF

    EXIT:
	MOV AL, 0
	MOV AH, 4CH
	INT 21H
    RETN
	

MYCODE ENDS
	END START