@echo off
if "%OS%"=="Windows_XP" goto WinNT
if "%OS%"=="Windows_NT" goto WinNT
if "%OS%"=="Windows_2000" goto WinNT

start/wait Eproxy.exe /stop
goto exit

:WinNT
net stop Eproxy

:exit