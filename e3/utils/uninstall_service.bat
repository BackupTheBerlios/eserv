@echo off
if exist uninstall_service.bat cd ..
net stop %1
cd %1
%1.exe ..\CommonPlugins\plugins\service\index.f /us
