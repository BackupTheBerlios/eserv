@echo off
if exist uninstall_acWEB_service.bat cd ..
net stop %1
cd acWEB
acWEB.exe ..\CommonPlugins\plugins\service\index.f /us
