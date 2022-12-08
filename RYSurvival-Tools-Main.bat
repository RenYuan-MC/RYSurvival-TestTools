@echo off

:: ����ģʽ�������
if "%~1" == "-?" ( goto HelpMode )
if "%~1" == "-��" ( goto HelpMode )
if "%~1" == "-help" ( goto HelpMode )
if "%~1" == "" ( goto HelpMode )

:: ������ʼ��׼��
title ��Ԩ����
cd /d "%~dp0"
cls

call :info ��ʼ����...

:: ��ɫ�����ʼ��
setlocal EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "DEL=%%a"
call :info ��ɫ��������ɳ�ʼ��
cd..

:: ����ģʽ�������
if "%~1" == "-test" ( goto TestMode )

:: ���ģʽ�������
if "%~1" == "-package" ( goto PackageMode )

call :warning δ��⵽��Ч�������������ģʽ

goto HelpMode




:: ------------------------
:: 
:: ��ģ��
:: @ ���÷��� goto ģ����
:: 
:: ------------------------



::
::  ����ģʽ��ͷ
:: 
:TestMode

:: �޸ı���
title ��Ԩ����-����ģʽ

:: ��ԭģʽ�������
if "%~2" == "-res" ( call :RestoreMode && goto loop )

:: ׼��������ļ�
call :PrepareServerFile %*

:: �л���������ļ���
cd..
cd RYSurvival-TestServer

:: ��չ���������
if "%~2" == "-ext" ( call :ExtensionPack ) else if "%~3" == "-ext" ( call :ExtensionPack )

:: ��Ӱ汾��Ϣ
echo core-name=%core-name% >restore.properties
echo version=%version% >>restore.properties

:: ��ʼ�����
call :info ��ʼ�����

:: ���������
call :info ���������������� && pause>nul

:: ���ñ���
call :title

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

::
::  ����ģʽ��β
:: 


:: ----------------------------------------------------------------------------------------------------------------


::
::  ���ģʽ��ͷ
:: 
:PackageMode

:: �޸ı���
title ��Ԩ����-���ģʽ

call :info ���ò���ģʽ׼���ļ���

:: ׼��������ļ�
call :PrepareServerFile %*

call :info ��������ļ�׼�����

:: ׼������ļ���
if exist build rd build /s/q
mkdir build && cd build
mkdir Server && cd..

:: �����Դ�ļ�
if not exist package-resources call :NotFoundError package-resources folder
if not exist package-resources\resources call :NotFoundError resources folder
xcopy "%~dp0package-resources\resources" "%~dp0build" /S/E/Y/I>nul
if exist package-resources\update-log.txt ( copy "%~dp0package-resources\update-log.txt" "%~dp0build" >nul && ren "%~dp0build\update-log.txt" ������־.txt )
call :info ��Դ�ļ�׼�����
xcopy "%~dp0\..\RYSurvival-TestServer" "%~dp0build\server" /S/E/Y/I>nul
call :info �����ļ�׼�����

pause>nul
goto exit



::
::  ���ģʽ��β
:: 


:: ----------------------------------------------------------------------------------------------------------------


::
::  ����ģʽ��ͷ
:: 

:: ����ģʽ
:HelpMode
if "%~2" == "" ( set name=%~n0 ) else ( set name=%~2 )
call :info ��Ԩ����-����
call :info �÷�(���ȼ����ϵ�������):
call :info
call :info %name% -?   ��ȡ�˰���
call :info %name% -help   ��ȡ�˰���
call :info %name% -package    ��Ĭ��ģʽ���
call :info %name% -package -pro    Ϊ���Ѱ���
call :info %name% -test   ����ģʽ
call :info %name% -test -res   ��ԭ���ϴβ���ģʽ
call :info %name% -test -pro   �л������Ѱ�
call :info %name% -test -ext   װ����չ��
call :info %name% -test -pro -ext   �л������Ѱ沢װ����չ��
call :info
call :info ��������˳�
pause>nul
@echo on
goto exit

::
::  ����ģʽ��β
:: 







:: ------------------------
:: 
:: Сģ�� 
:: @ ��ͨ���÷��� call :ģ����
:: @ ������ģ����� goto ģ����
::
:: ------------------------


:: ����̨�������
:info
echo [Info] %*
goto exit


:warning
call :colortext 0e "[Warning] %~1" && echo.
goto exit


:error
call :colortext 0c "[Error] %~1" && echo.
goto exit

:: ----------------------------------------------------------------------------------------------------------------

:: �����ɫ����
:colortext
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto exit

:: ----------------------------------------------------------------------------------------------------------------

:: ���ñ���
:title
title ��Ԩ��������-����ģʽ %core-name:-=%
goto exit

:: ----------------------------------------------------------------------------------------------------------------

:: ���󱨸洦��
:NotFoundError
if "%~2" == "folder" call :error "NotFoundError���޷��ҵ���Ӧ�ļ��� %~1"
if "%~2" == "file" call :error "NotFoundError���޷��ҵ���Ӧ�ļ� %~1"
pause>nul
exit 

:: ----------------------------------------------------------------------------------------------------------------

:InvalidParameterError
call :error "InvalidParameterError����Ч���� %~1"
pause>nul
exit 

:: ----------------------------------------------------------------------------------------------------------------

:: ��չ������
:ExtensionPack
if not exist .extensionpack call :NotFoundError .extensionpack folder
if not exist plugins call :NotFoundError plugins folder
xcopy .extensionpack plugins /S/E/Y/I>nul
rd .extensionpack /s/q
call :info ��װ����չ��
goto exit

:: ----------------------------------------------------------------------------------------------------------------

:: ��⵽�Ƿ���˵��˳�
:non-version-exit
call :info �޷����,�����˳�
ping -n 3 -w 500 0.0.0.1 > nul
goto exit

:: ----------------------------------------------------------------------------------------------------------------

:: ��ԭģʽ����
:RestoreMode
call :info ��ԭģʽ������

:: ��ʼ���ļ�λ��
cd /d "%~dp0"
cd..
if not exist RYSurvival-TestServer call :NotFoundError RYSurvival-TestServer folder
cd RYSurvival-TestServer
if not exist restore.properties call :NotFoundError restore.properties file

:: ��ȡ�汾��Ϣ
for /f "tokens=1,* delims==" %%a in (' findstr "version=" "restore.properties" ') do set version=%%b
if "%version%" == "" call :InvalidParameterError version
:: ����ո�
set version=%version: =%
call :info ��ȡ������˰汾 %version%

:: ��ȡ��������
for /f "tokens=1,* delims==" %%a in (' findstr "core-name=" "restore.properties" ') do set core-name=%%b
if "%core-name%" == "" call :InvalidParameterError core-name
:: ����ո�
set core-name=%core-name: =%
call :info ��ȡ������˺������� %core-name%

:: ���ñ���
call :title

:: �������
call :info ����ɻ�ԭģʽ����
call :info ����������� && pause>nul

goto exit

:: ----------------------------------------------------------------------------------------------------------------

:: ������ļ�׼��
:PrepareServerFile

:: ���Ѱ�������
if "%~2" == "-pro" ( set folder=RYSurvival-Pro && call :info ��⵽ʹ�ø��Ѱ�ֿ� ) else ( set folder=RYSurvival && call :info ��⵽ʹ����Ѱ�ֿ� )
set folder=%folder: =%

:: ��ȡ����˰汾
if exist %folder% (cd %folder%) else call :NotFoundError %folder% folder
call :info ���ҵ�����˲ֿ��ļ���
if not exist .version call :NotFoundError .version file
call :info ���ҵ��汾ʶ���ļ�
:: ��ȡ.version�ļ��еİ汾��Ϣ
for /f "tokens=1,* delims==" %%a in (' findstr "Version=" ".version" ') do set version=%%b
if "%version%" == "" call :InvalidParameterError version
:: ����ո�
set version=%version: =%
call :info ��ȡ������˰汾 %version%
if "%version%" == "non-version" goto non-version-exit
cd /d "%~dp0"

:: ������п�
call :info ������п���
if exist test-environment-runtime ( cd test-environment-runtime ) else call :NotFoundError test-environment-runtime folder
call :info ���ҵ����п��ļ���
if not exist java\bin\java.exe call :NotFoundError java.exe file
call :info ���ҵ�Java
if exist test-flies ( cd test-flies ) else call :NotFoundError test-flies folder
call :info ���ҵ������ļ���

:: ���汾�ļ����Ƿ����
if not exist TestServerLib_%version% call :NotFoundError TestServerLib_%version% folder
call :info ���ҵ������ļ�

:: ��ȡ��Ӧ�汾�ĺ���
for /f "tokens=1,* delims==" %%a in (' findstr "%version%=" "version.properties" ') do set core-name=%%b
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
if "%~1" neq "-package" xcopy "%~dp0test-environment-runtime\test-flies\TestServerLib" RYSurvival-TestServer /S/E/Y/I>nul
xcopy "%~dp0test-environment-runtime\test-flies\TestServerLib_%version%" RYSurvival-TestServer /S/E/Y/I>nul
call :info �Ѹ��ƶ�Ӧ�汾�Ĳ����ļ�

cd /d "%~dp0"

goto exit

:: ----------------------------------------------------------------------------------------------------------------

:: �˳���ʶ,�벻Ҫ�ڴ��·���Ӵ���
:exit
