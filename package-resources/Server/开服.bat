@echo off
cd /d "%~dp0"
cls

setlocal EnableDelayedExpansion

call :info ���Ժ�,��ʼ����...
set line=----------------------------------
set titl=��Ԩ����
title %titl% ��ʼ����...

:: ��ʼ����ɫ����
for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "DEL=%%a"

call :VersionReader
call :ConfigReader
call :DisplayConfig
call :EulaChecker
call :PortChecker

set /a times=0
if "%port-titl%" equ "true" set titl-port=�˿�: %server-port%



:Loop
call :RefreshMemory
cls
call :RefreshTitle
call :RefreshFlags

%java-path% -Xmx%xmx%M -Xms%xms%M %flags% %extra-java% -jar %core% %extra-server%

echo.
call :Info %line%
call :Info ������Ѿ��ر�

if "%auto-restart%" neq "true" (
    call :Info ����3���رմ���
    ping -n 4 -w 500 127.0.0.1 >nul 
    goto exit
)

for /l %%a in (%restart-wait%,-1,1) do (
    call :Info ����˽���%%a�������
    ping -n 2 -w 500 127.0.0.1 >nul
)

call :Info �����������
set /a times+=1

call :Info %line%

goto Loop












:: ��ȡ����˰汾��Ϣ
:VersionReader
if not exist version.properties (
    call :Error �汾�ļ���ʧ����ʹ��Ĭ�ϵĺ�������server.jar 
    set core=server.jar
    goto exit
)
call :PropertiesReader version.properties version
call :PropertiesReader version.properties core -disablewarn
call :PropertiesReader version.properties name
call :PropertiesReader version.properties git
if "%core%" equ "" call :Error �������Ʋ�����ʧ����ʹ��Ĭ�ϵĺ�������server.jar & set core=server.jar
call :Info %line%
call :Info ��Ԩ�������� %version% [git-%git%]
call :Info %line%
goto exit



:: ����̨�������
:Info
echo [Info] %*
goto exit



:Warn
call :colortext 0e "[Warn] %~1" & echo.
goto exit



:Error
call :colortext 0c "[Error] %~1" & echo.
goto exit



:: �����ɫ����
:ColorText
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto exit



:: properties�ļ���ȡ
:PropertiesReader
if "%~3" equ "-keepspace" (set space=true) & if "%~4" equ "-keepspace" (set space=true)
if "%~3" equ "-disablewarn" (set warn=false) & if "%~4" equ "-disablewarn" set (warn=false)
if not exist %~1 ( if "%warn%" neq "false" call :Warn "δ��⵽�ļ� %~1 ��" ) & goto exit
for /f "tokens=1,* delims==" %%a in ('findstr "%~2=" "%~1"') do set tag=%%b
if "%tag%" equ "" ( if "%warn%" neq "false" call :Warn "�޷���ȡ�� %~1 �� %~2 ������" ) & goto exit
if "%space%" neq "true" set tag=%tag: =%
set %~2=%tag%
:: �ͷű���
set tag=
set warn=
set space=
goto exit



:: �����ļ���ȡ
:ConfigReader
call :Info ���ڳ�ʼ�������ļ�ϵͳ

:: ���ڰ汾�ľ������ļ�����ת��
if exist ConfigProgress.txt ren ConfigProgress.txt progress.properties
if exist config.txt ren config.txt config.properties

:: ���������ļ�
call :PropertiesReader progress.properties ConfigSet -disablewarn
if "%ConfigSet%" equ "true" goto :ConfigTranslator

:: ���Ĭ�������ļ�
if not exist launcher.properties call :ConfigCreater

:: ��ȡ�����ļ�
call :Info ��ȡ�����ļ���
call :PropertiesReader launcher.properties port-titl
call :PropertiesReader launcher.properties etil-flags
call :PropertiesReader launcher.properties auto-memory
call :PropertiesReader launcher.properties default-xmx
call :PropertiesReader launcher.properties default-xms
call :PropertiesReader launcher.properties auto-restart
call :PropertiesReader launcher.properties restart-wait
call :PropertiesReader launcher.properties extra-server -keepspace -disablewarn
call :PropertiesReader launcher.properties extra-java -keepspace -disablewarn
call :PropertiesReader launcher.properties java-path -keepspace -disablewarn
call :Info ��ȡ��ϣ�
goto exit



:: �����ļ�����
:ConfigCreater
call :info ������һ���µ������ļ�,��������Լ���
pause >nul
set port-titl=true
set etil-flags=true
set auto-memory=true 
set default-xmx=4096 
set default-xms=4096 
set auto-restart=true 
set restart-wait=10 
set extra-server=nogui 
.\Java\bin\java.exe -version >nul 2>&1
if %errorlevel% equ 0 ( set java-path=.\Java\bin\java.exe ) else ( set java-path=java )
call :SaveConfig
call :Info ������ϣ�
goto exit



:: �ɰ������ļ�ת��
:ConfigTranslator
if not exist config.properties call :Warn δ�ҵ���ȷ�ľ������ļ� & goto ConfigCreater
call :info ����ת���ɰ������ļ�
if exist launcher.properties call :Warn ��⵽launcher.properties�Ѵ��ڣ�������ԭ�����ļ�����������Լ��� & pause >nul

:: �������ڲ����ڿ���ǰ�ȴ�,������EarlyLunchWait
:: ServerGUI��ת��Ϊextra-serverֱ�����-nogui����
:: EarlyLunchWait,SysMem��LogAutoRemove������,��Ϊ������������ת��
:: ����ӳ���б�:
:: AutoMemSet -> auto-memory
:: UserRam -> default-xmx
:: MinMem -> default-xms
:: AutoRestart -> auto-restart
:: RestartWait -> restart-wait
:: ServerGUI -> extra-server
:: SysMem -> old.system-memory
:: LogAutoRemove -> old.auto-remove-log
:: EarlyLunchWait -> old.launch-wait

call :PropertiesReader config.properties AutoMemSet -disablewarn
call :PropertiesReader config.properties UserRam -disablewarn
call :PropertiesReader config.properties MinMem -disablewarn
call :PropertiesReader config.properties AutoRestart -disablewarn
call :PropertiesReader config.properties RestartWait -disablewarn
call :PropertiesReader config.properties ServerGUI -disablewarn
call :PropertiesReader config.properties SysMem -disablewarn
call :PropertiesReader config.properties LogAutoRemove -disablewarn
call :PropertiesReader config.properties EarlyLunchWait -disablewarn

set port-titl=true
set etil-flags=true
set auto-memory=%AutoMemSet%
if "%UserRam%" equ "" set UserRam=4096
set default-xmx=%UserRam%
if "%MinMem%" equ "" set MinMem=128
set default-xms=%MinMem%
set auto-restart=%AutoRestart%
set restart-wait=%RestartWait%
if "%ServerGUI%" equ "false" set extra-server=nogui 
.\Java\bin\java.exe -version >nul 2>&1
if %errorlevel% equ 0 ( set java-path=.\Java\bin\java.exe ) else ( set java-path=java )
set old.system-memory=%SysMem%
set old.auto-remove-log=%LogAutoRemove%
set old.launch-wait=%EarlyLunchWait%

call :SaveConfig true

del progress.properties /f/q
del config.properties /f/q

call :Info ת����ϣ�

goto exit



:: ���������ļ�
:SaveConfig
echo # ��Ԩ�������������������ļ� >launcher.properties
echo. >>launcher.properties
echo # �Ƿ��ڱ�����ʾ�������˿� >>launcher.properties
echo port-titl=%port-titl% >>launcher.properties
echo. >>launcher.properties
echo # �Ƿ�����etil-flags >>launcher.properties
echo # etil-flags����Aikar-flags,����С������������ >>launcher.properties
echo etil-flags=%etil-flags% >>launcher.properties
echo. >>launcher.properties
echo # �Ƿ��Զ������ڴ� >>launcher.properties
echo auto-memory=%auto-memory% >>launcher.properties
echo. >>launcher.properties
echo # ��С�ڴ������ڴ�,�翪���Զ������ڴ�,�����Ч >>launcher.properties
echo default-xmx=%default-xmx% >>launcher.properties
echo default-xms=%default-xms% >>launcher.properties
echo. >>launcher.properties
echo # �Ƿ��Զ����� >>launcher.properties
echo auto-restart=%auto-restart% >>launcher.properties
echo # �Զ�����ʱ�ĵȴ�ʱ�� >>launcher.properties
echo restart-wait=%restart-wait% >>launcher.properties
echo. >>launcher.properties
echo # ���������� >>launcher.properties
echo extra-server=%extra-server% >>launcher.properties
echo # JVM���� >>launcher.properties
echo extra-java=%extra-java% >>launcher.properties
echo # Java·�� >>launcher.properties
echo java-path=%java-path% >>launcher.properties
echo. >>launcher.properties
if "%~1" neq "true" goto exit
echo # �ɰ汾�����ļ��������� >>launcher.properties
echo old.system-memory=%old.system-memory% >> launcher.properties
echo old.auto-remove-log=%old.auto-remove-log% >> launcher.properties
echo old.launch-wait=%old.launch-wait% >> launcher.properties
goto exit



:DisplayConfig
call :Info %line%
call :Info �ڱ�����ʾ�˿�: %port-titl%
call :Info ����etil-flags: %etil-flags%
call :Info �Զ������ڴ�: %auto-memory%
call :Info ����ڴ�: %default-xmx%
call :Info ��С�ڴ�: %default-xms%
call :Info �Զ�����: %auto-restart%
call :Info �����ȴ�ʱ��: %restart-wait%
call :Info ����������: %extra-server%
call :Info JVM����: %extra-java%
call :Info Java·��: %java-path%
call :Info %line%
goto exit



:: Eula���
:EulaChecker
call :PropertiesReader eula.txt eula -disablewarn
if "%eula%" equ "true" goto exit

call :Warn "�ڷ������ʽ����ǰ���㻹Ҫͬ��Minecraft EULA"
call :Info �鿴EULA��ǰ�� https://account.mojang.com/documents/minecraft_eula
call :Info �ڴ˴����������ʾͬ��Minecraft EULA�����������

pause >nul
echo eula=true >eula.txt
call :Info ��ͬ����Minecraft EULA,����˼�������
call :Info %line%
ping -n 2 -w 500 127.0.0.1 >nul

goto exit


:: �˿ڼ��
:PortChecker
call :PropertiesReader server.properties server-port -disablewarn
if "%server-port%" equ "" (
    set port-titl=false
    goto exit
)

:: ����ռ�ö˿ڵĳ���
set /a times=0 
for /f "tokens=2,5" %%i in (' netstat -ano ^| findstr "%server-port%" ') do (
    for /f %%a in (' echo %%i ^| findstr "%server-port%" ') do ( 
        if "!times!" equ "0" (
            call :Warn �������˿ڿ��ܱ�ռ�ã����ᵼ�·������޷�����������
            call :Info ������ռ�ö˿ڵĽ���PID�Ͷ�Ӧ�˿�IP:
        )
        call :Info ����PID: %%j ,ռ�ö˿�IP: %%a
        set /a times+=1
    )
)
if "%times%" neq "0" (
    call :Info ����5����������������
    call :Info %line% 
    ping -n 6 -w 500 127.0.0.1 >nul 
)
set times=
goto exit




:: ˢ�±���
:RefreshTitle
if "%auto-restart%" equ "true" (
    title %titl% %name% ��������: %times% %titl-port%
) else (
    title %titl% %name% %titl-port%
)
goto exit




:: ˢ���ڴ����
:RefreshMemory
if "%auto-memory%" neq "true" (
    set xmx=%default-xmx%
    set xms=%default-xms%
    goto exit
)

for /f "delims=" %%a in ('wmic os get TotalVisibleMemorySize /value^|find "="') do set %%a
set /a t1=%TotalVisibleMemorySize%,t2=1024
set /a ram=%t1%/%t2%
for /f "delims=" %%b in ('wmic os get FreePhysicalMemory /value^|find "="') do set %%b
set /a t3=%FreePhysicalMemory%
set /a freeram=%t3%/%t2%
call :Info ϵͳ����ڴ�Ϊ��%ram% MB��ʣ������ڴ�Ϊ��%freeram% MB

set /a xmx=%freeram%-728
if %xmx% lss 1024 (
    call :Warn ʣ������ڴ���ܲ����Կ�������˻��߿����󿨶�
    set xmx=1024
) else if %xmx% gtr 20480 set xmx=20480
set xms=%xmx%
call :Info ���ν����� %xmx% MB�ڴ�
call :Info %line%
ping -n 2 -w 500 127.0.0.1 >nul 

goto exit


:: ˢ��etil-flags
:RefreshFlags
if "%etil-flags%" equ "false" goto exit

if %xmx% lss 12288 (
    set flags=-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -XX:-UseBiasedLocking -XX:UseAVX=3 -XX:+UseStringDeduplication -XX:+UseFastUnorderedTimeStamps -XX:+UseAES -XX:+UseAESIntrinsics -XX:UseSSE=4 -XX:+UseFMA -XX:AllocatePrefetchStyle=1 -XX:+UseLoopPredicate -XX:+RangeCheckElimination -XX:+EliminateLocks -XX:+DoEscapeAnalysis -XX:+UseCodeCacheFlushing -XX:+SegmentedCodeCache -XX:+UseFastJNIAccessors -XX:+OptimizeStringConcat -XX:+UseCompressedOops -XX:+UseThreadPriorities -XX:+OmitStackTraceInFastThrow -XX:+TrustFinalNonStaticFields -XX:ThreadPriorityPolicy=1 -XX:+UseInlineCaches -XX:+RewriteBytecodes -XX:+RewriteFrequentPairs -XX:+UseNUMA -XX:-DontCompileHugeMethods -XX:+UseFPUForSpilling -XX:+UseFastStosb -XX:+UseNewLongLShift -XX:+UseVectorCmov -XX:+UseXMMForArrayCopy -XX:+UseXmmI2D -XX:+UseXmmI2F -XX:+UseXmmLoadAndClearUpper -XX:+UseXmmRegToRegMoveAll -Dfile.encoding=UTF-8 -Xlog:async -Djava.security.egd=file:/dev/urandom --add-modules=jdk.incubator.vector
) else (
    set flags=-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=40 -XX:G1MaxNewSizePercent=50 -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=15 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=20 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -XX:-UseBiasedLocking -XX:UseAVX=3 -XX:+UseStringDeduplication -XX:+UseFastUnorderedTimeStamps -XX:+UseAES -XX:+UseAESIntrinsics -XX:UseSSE=4 -XX:+UseFMA -XX:AllocatePrefetchStyle=1 -XX:+UseLoopPredicate -XX:+RangeCheckElimination -XX:+EliminateLocks -XX:+DoEscapeAnalysis -XX:+UseCodeCacheFlushing -XX:+SegmentedCodeCache -XX:+UseFastJNIAccessors -XX:+OptimizeStringConcat -XX:+UseCompressedOops -XX:+UseThreadPriorities -XX:+OmitStackTraceInFastThrow -XX:+TrustFinalNonStaticFields -XX:ThreadPriorityPolicy=1 -XX:+UseInlineCaches -XX:+RewriteBytecodes -XX:+RewriteFrequentPairs -XX:+UseNUMA -XX:-DontCompileHugeMethods -XX:+UseFPUForSpilling -XX:+UseFastStosb -XX:+UseNewLongLShift -XX:+UseVectorCmov -XX:+UseXMMForArrayCopy -XX:+UseXmmI2D -XX:+UseXmmI2F -XX:+UseXmmLoadAndClearUpper -XX:+UseXmmRegToRegMoveAll -Dfile.encoding=UTF-8 -Xlog:async -Djava.security.egd=file:/dev/urandom --add-modules=jdk.incubator.vector
)

goto exit


:: �˳���ʶ,�벻Ҫ�ڴ��·���Ӵ���
:exit