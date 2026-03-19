@echo off
chcp 65001 >nul
title Plouf Priority Manager
color 0D

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
if defined anim_done goto skip_anim

echo  ███████████  █████          ███████    █████  █████ ███████████
ping 127.0.0.1 -n 1 >nul
echo ▒▒███▒▒▒▒▒███▒▒███         ███▒▒▒▒▒███ ▒▒███  ▒▒███ ▒▒███▒▒▒▒▒▒█
ping 127.0.0.1 -n 1 >nul
echo  ▒███    ▒███ ▒███        ███     ▒▒███ ▒███   ▒███  ▒███   █ ▒ 
ping 127.0.0.1 -n 1 >nul
echo  ▒██████████  ▒███       ▒███      ▒███ ▒███   ▒███  ▒███████   
ping 127.0.0.1 -n 1 >nul
echo  ▒███▒▒▒▒▒▒   ▒███       ▒███      ▒███ ▒███   ▒███  ▒███▒▒▒█   
ping 127.0.0.1 -n 1 >nul
echo  ▒███         ▒███      █▒▒███     ███  ▒███   ▒███  ▒███  ▒    
ping 127.0.0.1 -n 1 >nul
echo  █████        ███████████ ▒▒▒███████▒   ▒▒████████   █████      
ping 127.0.0.1 -n 1 >nul
echo ▒▒▒▒▒        ▒▒▒▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒▒      ▒▒▒▒▒▒▒▒   ▒▒▒▒▒       

echo                                                           by septix

echo.
echo        Ripcord Disable Force Region
echo.
powershell -Command "Write-Host 'Current status: ' -NoNewline; Write-Host '%status%' -ForegroundColor DarkBlue"
echo.
echo 1 - Enable IPv4 priority (disable force region)
echo 2 - Enable IPv6 priority (default IPv6 and enable force region)
echo 3 - Exit
echo.

set anim_done=1
goto after_anim

:skip_anim
echo  ███████████  █████          ███████    █████  █████ ███████████
echo ▒▒███▒▒▒▒▒███▒▒███         ███▒▒▒▒▒███ ▒▒███  ▒▒███ ▒▒███▒▒▒▒▒▒█
echo  ▒███    ▒███ ▒███        ███     ▒▒███ ▒███   ▒███  ▒███   █ ▒ 
echo  ▒██████████  ▒███       ▒███      ▒███ ▒███   ▒███  ▒███████   
echo  ▒███▒▒▒▒▒▒   ▒███       ▒███      ▒███ ▒███   ▒███  ▒███▒▒▒█   
echo  ▒███         ▒███      █▒▒███     ███  ▒███   ▒███  ▒███  ▒    
echo  █████        ███████████ ▒▒▒███████▒   ▒▒████████   █████      
echo ▒▒▒▒▒        ▒▒▒▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒▒      ▒▒▒▒▒▒▒▒   ▒▒▒▒▒       

echo                                                          by septix

echo.
echo        Ripcord Fix Force Region
echo.
powershell -Command "Write-Host 'Current status: ' -NoNewline; Write-Host '%status%' -ForegroundColor DarkBlue"
echo.
echo 1 - Enable IPv4 priority (disable force region)
echo 2 - Enable IPv6 priority (default IPv6 and enable force region)
echo 3 - Exit
echo.

:after_anim

set /p choix=Choice : 

if "%choix%"=="1" goto ipv4_priority
if "%choix%"=="2" goto ipv6_default
if "%choix%"=="3" exit
goto menu

:ipv4_priority
cls

if /i "%state%"=="0x20" (
    echo IPv4 is already prioritized.
    pause
    goto menu
)

echo Enabling IPv4 priority...

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 32 /f >nul

echo.
echo IPv4 is now prioritized over IPv6
goto reboot_prompt

:ipv6_default
cls

if /i "%state%"=="0x0" (
    echo IPv6 is already set as default priority.
    pause
    goto menu
)

echo Restoring default IPv6 behavior...

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 0 /f >nul

echo.
echo IPv6 default behavior restored
goto reboot_prompt

:reboot_prompt
echo.
echo A system restart is recommended to apply changes.
choice /c YN /m "Restart now?"

if %errorlevel%==1 (
    echo Restarting in 5 seconds...
    shutdown /r /t 5 /c "Applying network configuration changes"
) else (
    echo Restart cancelled.
)

pause
goto menu
