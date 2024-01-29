MYCODE SEGMENT 'CODE'
 ASSUME CS: MYCODE
 PUBLIC LET
LET0 DB 'Н'
;Новиков Богдан ИУ5-44б ЛР3
LET DB 'А'
START:
; ЗАГРУЗКА СЕГМЕНТНОГО РЕГИСТРА ДАННЫХ DS
 PUSH CS
 POP DS
; ВЫВОД Б
 MOV DL, LET0
 CALL PUTCH
 CALL CRLF
; ВЫВОД ОДНОГО СИМВОЛА НА ЭКРАН
 MOV DL, LET
 CALL PUTCH
; ПЕРЕВОД СТРОКИ
 CALL CRLF
; ВЫВОД СЛЕДУЮЩИХ ДВУХ СИМВОЛОВ
 ADD LET, 1
 MOV DL, LET
 CALL PUTCH
 CALL CRLF

 ADD LET, 1
 MOV DL, LET
 CALL PUTCH
 CALL CRLF

; ОЖИДАНИЕ ЗАВЕРШЕНИЯ ПРОГРАММЫ
 CALL GETCH

; ВЫХОД ИЗ ПРОГРАММЫ
 MOV AL, 0
 MOV AH, 4CH
 INT 21H

; ПРОЦЕДУРА ПЕРЕВОДА СТРОКИ
CRLF PROC
 MOV DL, 10
 CALL PUTCH
 MOV DL, 13
 CALL PUTCH
 RET
CRLF ENDP

; ПРОЦЕДУРА ВЫВОДА СИМВОЛА
PUTCH PROC
 MOV AH, 02H
 INT 021H
 RET
PUTCH ENDP

; ПРОЦЕДУРА ВВОДА СИМВОЛА
GETCH PROC
 MOV AH, 01H
 INT 021H
 RET
GETCH ENDP
; ПРОЦЕДУРА ОЧИСТКИ ЭКРАНА
MYCODE ENDS
END START
