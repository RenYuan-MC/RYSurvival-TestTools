@echo off
title ��Ԩ����-����ģʽ
cd /d "%~dp0"
cls

call :info ��ʼ����...

:: ���Ѱ�������
if "%~1" == "-pro" (set folder=RYSurvival-Pro && call :info ��⵽ʹ�ø��Ѱ�ֿ�) else (set folder=RYSurvival && call :info ��⵽ʹ����Ѱ�ֿ�)
set folder=%folder: =%

:: ��ɫ�����ʼ��
setlocal EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "DEL=%%a"
call :info ��ɫ��������ɳ�ʼ��
cd..

:: ��ȡ����˰汾
if exist %folder% (cd %folder%) else call :NotFoundError %folder% folder
call :info ���ҵ�����˲ֿ��ļ���
if not exist .version call :NotFoundError .version file
call :info ���ҵ��汾ʶ���ļ�
:: ��ȡ.version�ļ��еİ汾��Ϣ
for /f "tokens=1,* delims==" %%a in ('findstr "Version=" ".version"') do set version=%%b
if "%version%" == "" call :InvalidParameterError version
:: ����ո�
set version=%version: =%
call :info ��ȡ������˰汾 %version%
if "%version%" == "non-version" goto non-version-exit
cd /d "%~dp0"

:: ������п�
call :info ������п���
if exist test-environment-runtime (cd test-environment-runtime) else call :NotFoundError test-environment-runtime folder
call :info ���ҵ����п��ļ���
if not exist java\bin\java.exe call :NotFoundError java.exe file
call :info ���ҵ�Java
if exist test-flies (cd test-flies) else call :NotFoundError test-flies folder
call :info ���ҵ������ļ���

:: ���汾�ļ����Ƿ����
if not exist TestServerLib_%version% call :NotFoundError TestServerLib_%version% folder
call :info ���ҵ������ļ�

:: ��ȡ��Ӧ�汾�ĺ���
for /f "tokens=1,* delims==" %%a in ('findstr "%version%=" "version.properties"') do set core-name=%%b
if "%core-name%" == "" call :InvalidParameterError core-name
:: ����ո�
set core-name=%core-name: =%
call :info ��ȡ������˺������� %core-name%
for /l %%a in (1,1,3) do cd..

:: ������Է������ļ���
if exist RYSurvival-TestServer rd RYSurvival-TestServer /s/q
mkdir RYSurvival-TestServer
call :info �������Է������ļ���
call :info ���Ʒ�����ļ���

:: ���Ʒ����
xcopy "%folder%\Server" RYSurvival-TestServer /S/E/Y/I>nul
call :info �Ѹ��Ʋֿ��ļ�
xcopy "%~dp0test-environment-runtime\test-flies\TestServerLib" RYSurvival-TestServer /S/E/Y/I>nul
xcopy "%~dp0test-environment-runtime\test-flies\TestServerLib_%version%" RYSurvival-TestServer /S/E/Y/I>nul
call :info �Ѹ��ƶ�Ӧ�汾�Ĳ����ļ�
cd RYSurvival-TestServer

:: ��ʼ�����
call :info ��ʼ�����

:: ���������
call :info ���������������� && pause>nul
:: ���ñ���
title ��Ԩ��������-����ģʽ %core-name:-=%


:: �ű���ѭ��
:loop
:: ˢ�¿���̨
cls
:: ����������
echo loading %core-name:-=%, please wait...
"%~dp0\test-environment-runtime\java\bin\java.exe" -Xms2G -Xmx2G --add-modules=jdk.incubator.vector -jar %core-name%.jar nogui
echo #
:: �ط��ָ���
echo -----------------------------------------------------
call :info ��������������Է����� 
:: ����������
pause>nul

goto loop














:: ����̨�������
:info
echo [Info] %~1 %~2 %~3 %~4 %~5
goto exit

:warning
call :colortext 0e "[Warning] %~1" && echo.
goto exit

:error
call :colortext 0c "[Error] %~1" && echo.
goto exit

:: �����ɫ����
:colortext
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto exit


:: ���󱨸洦��
:NotFoundError
if "%~2" == "folder" call :error "NotFoundError���޷��ҵ���Ӧ�ļ��� %~1"
if "%~2" == "file" call :error "NotFoundError���޷��ҵ���Ӧ�ļ� %~1"
pause>nul
exit 

:InvalidParameterError
call :error "InvalidParameterError����Ч���� %~1"
pause>nul
exit 

:: ��⵽�Ƿ���˵��˳�
:non-version-exit
call :info �޷����,�����˳�
ping -n 3 -w 500 0.0.0.1 > nul
goto exit

:exit


