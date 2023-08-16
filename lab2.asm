MYCODE SEGMENT 'CODE'
     ASSUME CS:MYCODE    
     PUBLIC LET 
     LET DB 'А' 
     TABLHEX DB '0123456789ABCDEF'
;Выполнил Новиков Б. ИУ5-44Б
;Очистка экрана
CLRSCR PROC
     MOV AX, 03
     INT 10H
     RET
CLRSCR ENDP

;Вывод символа на экран
PUTCH PROC
    MOV ah, 02h
    INT 21h
    RET
PUTCH ENDP

;Перевод строки
CRLF PROC
    MOV dl, 0dh
    CALL PUTCH
    MOV dl, 0ah
    CALL PUTCH
    RET
CRLF ENDP

;Ввод символа с клавиатуры
GETCH PROC
    MOV ah, 01h
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

;Начало выполнения программы
START: 
PUSH CS
POP DS 
 
LOOPING:
CALL CLRSCR
CALL CRLF
MOV CX, 20   

MYLOOP: 
;Выводим символ
MOV DL, LET
CALL PUTCH 

MOV DL, ' '
CALL PUTCH
MOV DL, '-'
CALL PUTCH
MOV DL, ' '
CALL PUTCH

MOV DL,LET
;Перекодировка
CALL HEX  

;Повторяем для следующего символа
ADD LET,1
CALL CRLF
LOOP MYLOOP  
 
;Ввод нового  символа и сравнение с '*'
CALL GETCH
MOV LET, AL
CMP LET, '*'
JNE LOOPING     
CALL CLRSCR

;Выход из программы
MOV AL, 5
MOV AH, 4CH
INT 21H  
 
MYCODE ENDS
END START
