@echo off
chcp 65001 >nul
title IPvX Priority Manager
color 5

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Restarting as admin...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

:menu
cls

set state=0x0
for /f "tokens=3" %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents 2^>nul ^| find "DisabledComponents"') do set state=%%a


if /i "%state%"=="0x20" (
    set status=IPv4 Priority
) else (
    set status=IPv6 Priority
)

echo.
echo   █████████  ██████████ ███████████  ███████████ █████ █████ █████
echo  ███▒▒▒▒▒███▒▒███▒▒▒▒▒█▒▒███▒▒▒▒▒███▒█▒▒▒███▒▒▒█▒▒███ ▒▒███ ▒▒███ 
echo ▒███    ▒▒▒  ▒███  █ ▒  ▒███    ▒███▒   ▒███  ▒  ▒███  ▒▒███ ███  
echo ▒▒█████████  ▒██████    ▒██████████     ▒███     ▒███   ▒▒█████   
echo  ▒▒▒▒▒▒▒▒███ ▒███▒▒█    ▒███▒▒▒▒▒▒      ▒███     ▒███    ███▒███  
echo  ███    ▒███ ▒███ ▒   █ ▒███            ▒███     ▒███   ███ ▒▒███ 
echo ▒▒█████████  ██████████ █████           █████    █████ █████ █████
echo  ▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒▒▒▒ ▒▒▒▒▒           ▒▒▒▒▒    ▒▒▒▒▒ ▒▒▒▒▒ ▒▒▒▒▒ 
echo.
echo.

echo         Ripcord Fix Force Region
echo.
echo Current status: %status%
echo.

echo 1 - Enable IPv4 priority (disable force region)
echo 2 - Enable IPv6 priority (default IPv6 and enable force region)
echo 3 - Exit
echo.

set /p choix=Choice :

if "%choix%"=="1" goto ipv4_priority
if "%choix%"=="2" goto ipv6_default
if "%choix%"=="3" exit
goto menu

:ipv4_priority
cls
echo Enabling IPv4 priority...

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" ^
/v DisabledComponents /t REG_DWORD /d 32 /f >nul

echo.
echo IPv4 is now prioritized over IPv6
goto reboot_prompt

:ipv6_default
cls
echo Restoring default IPv6 behavior...

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" ^
/v DisabledComponents /t REG_DWORD /d 0 /f >nul

echo.
echo IPv6 default behavior restored
goto reboot_prompt

:reboot_prompt
echo.
choice /m "Restart now"
if %errorlevel%==1 shutdown /r /t 5

pause
goto menu
