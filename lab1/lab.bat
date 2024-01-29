rem Богдан Новиков вариант 15
echo off
rem сохранение аргумента
set show_help=%1
shift
set help_filename=%1
:menu
cls
rem меню
echo 1. Команда DIR для .bat файлов
echo 2. Команда DIR для .com файлов
echo 3. Команда DEL
echo 4. Справка
echo 5. Выход
rem выбор опции
choice /c:12345
if ERRORLEVEL 5 goto 5
if ERRORLEVEL 4 goto 4
if ERRORLEVEL 3 goto 3
if ERRORLEVEL 2 goto 2
if ERRORLEVEL 1 goto 1
:1
call dir *.bat
pause
goto menu
:2
call dir *.com
pause
goto menu
:3
call del vc.ini
pause
goto menu
:4
call %help_filename%
pause
goto menu
:5
if (%show_help%)==(yes) cls