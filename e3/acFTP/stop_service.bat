@echo off
if "%OS%"=="Windows_XP" goto WinNT
if "%OS%"=="Windows_NT" goto WinNT
if "%OS%"=="Windows_2000" goto WinNT

start/wait acFTP.exe /stop
goto exit

:WinNT
net stop acFTP

:exit