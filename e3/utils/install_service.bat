@echo off
if exist install_service.bat cd ..
cd %1
%1.exe ..\CommonPlugins\plugins\service\index.f /is