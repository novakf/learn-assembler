MYDATA SEGMENT 'DATA'   ;Сегмент данных
    TABLEHEX DB '0123456789ABCDEF'
    BUF DB 80 DUP (?)   ;буфер
    BUFRES DB 80 DUP (?)    ;буфер с результотом
    HMDWORD DW ?
    MSGHELLO DB 'Введите число(в формате НННН)>$'
    MSGEND DB 'Ввод чисел завершен!$'
    MSGERROR DB 'Число введено неправильно(допускаются 0-9 и A-F)!$'
MYDATA ENDS

MYCODE SEGMENT 'CODE'   ;Сегмент кода
ASSUME CS:MYCODE, DS:MYDATA
;Новиков Богдан ИУ5-44Б

;Начало выполнения
START:
    ;загрузка сегментного регистра данных
    MOV AX, MYDATA
    MOV DS, AX
    CALL CRLSCR
    MOV CX, 4

;Начало ввода нового числа
BIG_LOOP:
    LEA DX, MSGHELLO
    MOV AH, 09H
    INT 21H
    MOV SI, 0

;Ввод числа в 16CC
SMALL_LOOP:
    CALL GETCH
    ;* -> выход
    CMP AL, '*'
    JE	END_BIG_LOOP
    ;обработка некорректного ввода
    CMP AL, 'F'
    JG	STR_ERROR
    CMP AL, '0'
    JB	STR_ERROR
    CMP AL, '9'
    JLE IF_RIGHT
    CMP AL, 'A'
    JB	STR_ERROR
;если корректно -> записываем цифру в буфер
IF_RIGHT:	    
    MOV [BUF+SI], AL
    INC SI
    ;продолжаем для следующей цифры
    LOOP SMALL_LOOP
    ;выводим в 16CC
    CALL HEX_PRINT
    LEA SI, BUF
    MOV CX, 4
    MOV HMDWORD, 0
    MOV BX, 0

;Перевод Ш->М (из 16-чного в машинное)
HEXTOMACH:			   
    CALL HEX_MACH
    LOOP HEXTOMACH
    EX_TR:
    MOV HMDWORD, BX
    MOV CX, 5
    MOV BX, 10000
    MOV SI, 0

;Перевод М->Д (из машинного в десятичное)
MACHTODEC:		     
    CALL MACH_DEC
    LOOP MACHTODEC
    MOV [BUFRES+SI], '$'
    MOV SI, 0
    MOV DI, 0

;Печать числа в 10СС
DEC_SCREEN:		   
    MOV AL, [BUFRES+SI]
    CMP AL, '$'
    JE END_PRINT
    CALL DEC_PRINT
    LOOP DEC_SCREEN

;Конец печати
END_PRINT:
    JMP NEW_STR

;Печать сообщения об ошибке
STR_ERROR:	     
    CALL CRLF
    LEA DX, MSGERROR
    MOV AH, 09H
    INT 21H

;Ввод нового числа  
NEW_STR:
    CALL CRLF
    MOV CX, 5
    LOOP BIG_LOOP

END_BIG_LOOP:
    CALL CRLF
    ;печать сообщения о завершении программы
	LEA DX, MSGEND	 
	MOV AH, 09H
	INT 21H
    CALL GETCH	 
    ;очистка экрана    
    CALL CRLSCR	 
    MOV AL, 0		 
    ;завершение программы
	MOV AH, 4CH
	INT 21H

;Процедура перевода Ш->М
HEX_MACH PROC	
    ;перевод символа в 16-нуюю цифру	   
	MOV AL, [SI]    
	CMP AL, 39H
	JG	TR
    ;если цифра от 0 до 9
	SUB AL, 30H	 
    JMP NOT_TR
;если цифра от A до F
TR:     
    SUB AL, 37H	 
NOT_TR:
    ;Перевод по схеме Горнера в 10СС
    MOV AH, 0	
    ;складываем с текущим результатом	     
	ADD BX, AX 
    CMP CX, 1
    JE	EX_TR
    SHL BX, 1   ;умножаем на 16
    SHL BX, 1
    SHL BX, 1
    SHL BX, 1
    ;переход к следующему символу из буфера
    INC SI  
    RET
HEX_MACH ENDP

;Процедура перевода М->Д
MACH_DEC PROC		   
    MOV DX, 0
    MOV AX, HMDWORD
    DIV BX
    MOV HMDWORD, DX
    ADD AL, 30H ;переводим полученное число в символьное представление
    ;запись частного в буфер с результатом
    MOV [BUFRES+SI], AL    
    INC SI
    MOV AX, BX  ;уменьшение делителя в 10 раз
    MOV DX, 0
    MOV BX, 10
    DIV BX
    MOV BX, AX
    RET
MACH_DEC ENDP

;вывод символа на экран
PUTCH PROC
    MOV AH, 02H
    INT 021H
    RET
PUTCH ENDP

;перевод строки
CRLF PROC
    MOV DL, 10
    CALL PUTCH
    MOV DL, 13
    CALL PUTCH
    RET
CRLF ENDP

;ввод символа с клавиатуры
GETCH PROC
    MOV AH, 01H
    INT 021H
    RET
GETCH ENDP

;очистка экрана
CRLSCR PROC
	MOV AH, 00H
	MOV AL, 3
	INT 10H
    RET
CRLSCR ENDP

;Печать шестнадцатеричного числа
HEX_PRINT PROC	     
    MOV DL, ' '
    CALL PUTCH
	MOV DL, '='
    CALL PUTCH
    MOV DL, ' '
    CALL PUTCH
    MOV [BUF+SI], '$'
    LEA DX, BUF
    MOV AH, 09H
    INT 21H
    MOV DL, 'h'
    CALL PUTCH
    MOV DL, ' '
    CALL PUTCH
    RET
HEX_PRINT ENDP

;Печать десятичной цифры
DEC_PRINT PROC	     
    CMP AL, 30H
    ;проверяем на 0
    JE	CHECK_NULL
    JMP PRINT
CHECK_NULL:
    CMP SI, 4
    JE	PRINT
    CMP DI, 0
    JE	BAD_NULL
;печать цифры
PRINT:			 
    MOV DL, AL
    CALL PUTCH
    INC DI
;0 незначащий -> пропускаем
BAD_NULL:	     
    INC SI		 
    RET
DEC_PRINT ENDP

MYCODE ENDS
END START
