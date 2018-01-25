:: Set given username and password in Registry for Component Control's Quantum

@echo QTM Username Setter

Title %~n0
Mode 40,3 & Color 0E

@echo off
SET /P u=Username:
Call:InputPassword "Password" P
setlocal EnableDelayedExpansion

Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Component Control USA, LLC.\Quantum Control\2k.0\Dev]
"uname"="%u%"
"upwd"="%p%"
"spwd"=dword:00000000

@echo %u% %p% > test.txt

pause
::***********************************
:InputPassword
Cls
echo.
echo.
set "psCommand=powershell -Command "$pword = read-host '%1' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
      [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
        for /f "usebackq delims=" %%p in (`%psCommand%`) do set %2=%%p
)
goto :eof
::***********************************
