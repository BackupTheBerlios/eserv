@echo off
if "%OS%"=="Windows_XP" goto WinNT
if "%OS%"=="Windows_NT" goto WinNT
if "%OS%"=="Windows_2000" goto WinNT

:Win95
acFTP.exe
goto exit

:WinNT
net start acFTP

:exit