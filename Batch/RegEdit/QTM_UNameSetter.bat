:: Set given username and password in
:: Registry for Component Control's Quantum
:: -------------[ Alex McPhee ]------------

:: Window Scale and Color
Title %~n0
Mode 40,3 & Color 0E

@echo off
  SET /P u=Username:
  Call:InputPassword "Password" P
setlocal EnableDelayedExpansion

:: Add the following to Componant Control's registry. as of update 10.10.0 '\Dev' is omitted from install
  REG ADD "HKCU\Software\Component Control USA, LLC.\Quantum Control\2k.0\Dev"
  REG ADD "HKCU\Software\Component Control USA, LLC.\Quantum Control\2k.0\Dev" /v spwd /t REG_DWORD /d "00000000"
  REG ADD "HKCU\Software\Component Control USA, LLC.\Quantum Control\2k.0\Dev" /v uname /t REG_SZ /d "%u%"
  REG ADD "HKCU\Software\Component Control USA, LLC.\Quantum Control\2k.0\Dev" /v upwd /t REG_SZ /d "%P%"
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
