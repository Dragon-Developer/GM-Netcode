@echo off
set "MCVersion=1.0.1"
set "NumOfInsts=%YYEXTOPT_MultiClient_Number_Of_Clients%"
set "ExecuteInDebug=%YYEXTOPT_MultiClient_Enable_Debug_Mode%"
set "MaxClients=1"
set "ShouldProxyClients=%YYEXTOPT_MultiClient_Should_Proxy_Clients%"
set "ProxyPath=%YYEXTOPT_MultiClient_Proxy_Path%"
set "ProxyArgs=%YYEXTOPT_MultiClient_Proxy_Args%"
setlocal enabledelayedexpansion

echo -------------------------
echo Multi-Client v%MCVersion%: Initialized!
if %YYPLATFORM_name% NEQ operagx if %YYPLATFORM_name% NEQ HTML5 if %YYPLATFORM_name% NEQ Windows (
	echo Multi-Client: This does not work on other platforms at this time.
	echo -------------------------
	exit 0
) 

rem Main Execution. 
if %YYdebug% EQU True (
	if %YYPLATFORM_name% NEQ operagx (
		if %YYPLATFORM_name% NEQ HTML5 (
			echo Multi-Client: Warning - This doesn't fully support debug mode. By default this is off within the extension options!
			if %ExecuteInDebug% EQU False (
				echo Multi-Client: Workaround not enabled... Exiting safely...
				echo -------------------------
				exit 0
			) else (
				echo Multi-Client: ExecuteInDebug is set to True, will attempt workaround...
				echo Multi-Client: ClientID's increased by 4.
				set /A NumOfInsts=%NumOfInsts%+4
			)
		)
	)
)

echo Multi-Client: Running instances %YYEXTOPT_MultiClient_Number_Of_Clients%
if %YYPLATFORM_name% EQU HTML5 goto WebClient
if %YYPLATFORM_name% EQU operagx goto WebClient
goto main
:WebClient
set /a "NumOfInsts=%NumOfInsts%-1"
set /a "MaxClients=%MaxClients%+1"
if [%YYPREF_default_web_address%]==[] (
	echo Multi-Client: Failed to find YYPREF_default_web_address ^& YYPREF_default_webserver_port. Is Web runner running? 
	if %YYEXTOPT_MultiClient_Use_GM_Web_Fallback% EQU False (
		echo Multi-Client: Use_GM_Web_Fallback is set to False. Please ensure that webserver is running or set Use_GM_Web_Preset to True.
		echo -------------------------
		exit 1
	)
	
	echo Multi-Client: Use_GM_Web_Fallback is set to True. Using preset.
	echo Multi-Client: Defaulting to %YYEXTOPT_MultiClient_GM_Web_Fallback_Address%:%YYEXTOPT_MultiClient_GM_Web_Fallback_Port%
	set YYPREF_default_web_address=%YYEXTOPT_MultiClient_GM_Web_Fallback_Address%
	set YYPREF_default_webserver_port=%YYEXTOPT_MultiClient_GM_Web_Fallback_Port%
)
:main

set n_clients=0
set proxy_clients=1
for /l %%x in (1, %MaxClients%, %NumOfInsts%) do (
	:: Windows
	if %YYPLATFORM_name% EQU Windows (
        if %ShouldProxyClients% EQU True (
            if !n_clients! EQU 0 (
                if %YYTARGET_runtime% EQU YYC (
                    start /b cmd /C "%YYoutputFolder%\%YYprojectName%.exe" —mc-window-number %%x %YYEXTOPT_MultiClient_Additional_Parameters%
                ) else (
                    start /b cmd /C %YYruntimeLocation%\Windows\x64\runner.exe -game "%YYoutputFolder%\%YYprojectName%.win" —mc-window-number %%x %YYEXTOPT_MultiClient_Additional_Parameters%
                )
            ) else (
                set token=""
                for /f "tokens=1 delims=;" %%a in ("!ProxyArgs!") do (
                    if !proxy_clients! EQU !n_clients! (
                        set "token=%%a "
                        echo !counter!
                        echo !token!
                    )
                    set /a proxy_clients+=1
                )
                echo Proxying client !n_clients!
                if %YYTARGET_runtime% EQU YYC (
                    "%ProxyPath%" !token!"%YYoutputFolder%\%YYprojectName%.exe" —mc-window-number %%x %YYEXTOPT_MultiClient_Additional_Parameters%
                ) else (
                    "%ProxyPath%" !token!%YYruntimeLocation%\Windows\x64\runner.exe -game "%YYoutputFolder%\%YYprojectName%.win" —mc-window-number %%x %YYEXTOPT_MultiClient_Additional_Parameters%
                )
            )
        ) else (
            if %YYTARGET_runtime% EQU YYC (
                start /b cmd /C "%YYoutputFolder%\%YYprojectName%.exe" —mc-window-number %%x %YYEXTOPT_MultiClient_Additional_Parameters%
            ) else (
                start /b cmd /C %YYruntimeLocation%\Windows\x64\runner.exe -game "%YYoutputFolder%\%YYprojectName%.win" —mc-window-number %%x %YYEXTOPT_MultiClient_Additional_Parameters%
            )
        )
	)
	
	if %YYPLATFORM_name% EQU HTML5 (
		start /b %YYPREF_default_web_address%:%YYPREF_default_webserver_port%?mc-window-number=%%x
	)
	
	if %YYPLATFORM_name% EQU operagx (
		start /b %YYPREF_default_web_address%:%YYPREF_default_webserver_port%/runner.html?game=%YYPLATFORM_option_operagx_game_name%^&mc-window-number=%%x
	)

    set /a n_clients+=1
)

if %YYPLATFORM_name% NEQ operagx (
	if %YYPLATFORM_name% NEQ HTML5 goto exitIgor
)
goto WebClientExit
:exitIgor
echo Multi-Client: This will exit with a exit code of 1. Igor will "fail". This is intentional.
echo -------------------------
exit 1

:WebClientExit
echo Multi-Client: Task completed!
echo -------------------------
exit 0
