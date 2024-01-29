MYCODE SEGMENT 'CODE'
    ASSUME CS:MYCODE, DS:MYCODE    
    TABLHEX DB '0123456789ABCDEF'
    Welcome DB 'Введите строку, чтобы выйти введите *$'
	StringLimit DB 'Превышен лимит$'       
	Buf DB 21 DUP (' '), '$' 

;Новиков Богдан ИУ5-44Б

PRINTSTR PROC
    MOV ah, 09h
	INT 021h
	RET
PRINTSTR ENDP

CLRSCR PROC
    MOV AX, 03
    INT 10H
    RET
CLRSCR ENDP

PUTCH PROC
    MOV ah, 02h
    INT 21h
    RET
PUTCH ENDP

CLRF PROC
    MOV dl, 0dh
    CALL PUTCH
    MOV dl, 0ah
    CALL PUTCH
    RET
CLRF ENDP

GETCH PROC
    MOV ah, 08h
    INT 21h
    RET
GETCH ENDP

;Перекодировка символа
HEX PROC
    PUSH DX
;1-я цифра (DL=А лат)
    MOV AL, DL    ;пусть AL = 41h
    SHR AL, 4     ;сдвиг вправо на 4р
    LEA BX, TABLHEX
    XLAT          ;перекодировка
    MOV DL, AL   
    CALL PUTCH
    POP DX
;2-я цифра
    MOV AL, DL
    AND AL, 0FH   ;Маскирование And
    XLAT          ;Перекодировка
    MOV DL, AL    
    CALL PUTCH
    MOV DL, 'h'   ;Вывод символа в DL = 'h'
    CALL PUTCH
    RET
HEX ENDP

START:
    PUSH CS
    POP DS

MAIN:
	CALL CLRSCR
	MOV DX, OFFSET Welcome
	CALL PRINTSTR
	CALL CLRF

GETSTRING:
	MOV SI, 0
	LEA BX, Buf
    
	CALL GETCH
   	MOV BX[SI], AL

    ;* - выход
	CMP AL, "*"
	JE EXIT
    ;$ - конец строки
	CMP AL, '$'
	JE PRINTSTRING                 
	
	;Если не $ и * - печатаем
	MOV DX, AX
	CALL PUTCH
	INC SI
		
GETSYM:	
	CALL GETCH
	MOV BX[SI], AL
	
	CMP AL, "$"
	JE PRINTSTRING
	
	MOV DX, AX
	CALL PUTCH

	CMP SI, 19
	JE STRLIM
	
	INC SI
	JMP GETSYM
	
PRINTSTRING:   	 
	;пустая строка
	MOV AX, [BX]
	CMP AL, '$'
	JE HANDLER
	
	MOV DX, 32
	CALL PUTCH
	MOV DX, '='
	CALL PUTCH

PrintHex:
	XOR SI, SI
PrintHexSym:
	MOV AX, BX[SI]
	
    CMP AL, '$'
	JE HANDLER

	MOV DX, 32
	CALL PUTCH

	;Перекодировка
	MOV DX, BX[SI]
	PUSH BX
	CALL HEX
	POP BX	  
	
	;Следующий
	INC SI
	JMP PrintHexSym

;$
HANDLER:
	CALL CLRF
	JMP GETSTRING

STRLIM:
	MOV AX, '$'
	MOV BX[SI], AL
	CALL clrf
	MOV DX, OFFSET StringLimit
	CALL printstr
	CALL clrf
	JE PrintHex

EXIT:
    MOV AL, 0
    MOV AH, 4CH
    INT 21H  
 
MYCODE ENDS
END START
