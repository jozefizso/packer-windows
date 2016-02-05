@echo off
@setlocal EnableDelayedExpansion EnableExtensions
if not defined PACKER_SEARCH_PATHS set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:
if not defined VMWARE_TOOLS_TAR_URL set VMWARE_TOOLS_TAR_URL=https://softwareupdate.vmware.com/cds/vmw-desktop/ws/12.0.0/2985596/windows/packages/tools-windows.tar

if "%PACKER_BUILDER_TYPE%" equ "vmware-iso" goto :vmware
if "%PACKER_BUILDER_TYPE%" equ "virtualbox-iso" goto :virtualbox
if "%PACKER_BUILDER_TYPE%" equ "parallels-iso" goto :parallels
goto :done

:vmware
if defined ProgramFiles(x86) (
  set VMWARE_TOOLS_SETUP_EXE=setup64.exe
) else (
  set VMWARE_TOOLS_SETUP_EXE=setup.exe
)

@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined VMWARE_TOOLS_SETUP_PATH @if exist "%%~i\VMwareToolsUpgrader.exe" set VMWARE_TOOLS_SETUP_PATH=%%~i\%VMWARE_TOOLS_SETUP_EXE%
if defined VMWARE_TOOLS_SETUP_PATH goto install_vmware_tools

if exist "C:\Users\vagrant\windows.iso" (
    move /Y C:\Users\vagrant\windows.iso C:\Windows\Temp
)

if not exist "C:\Windows\Temp\windows.iso" (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('http://softwareupdate.vmware.com/cds/vmw-desktop/ws/12.0.0/2985596/windows/packages/tools-windows.tar', 'C:\Windows\Temp\vmware-tools.tar')" <NUL
    cmd /c ""a:\7za.exe" x C:\Windows\Temp\vmware-tools.tar -oC:\Windows\Temp"
    FOR /r "C:\Windows\Temp" %%a in (VMware-tools-windows-*.iso) DO REN "%%~a" "windows.iso"
    rd /S /Q "C:\Program Files (x86)\VMWare"
)

cmd /c ""a:\7za.exe" x "C:\Windows\Temp\windows.iso" -oC:\Windows\Temp\VMWare"
cmd /c C:\Windows\Temp\VMWare\setup.exe /S /v"/qn REBOOT=R\"

goto :done

:install_vmware_tools
echo ==^> Installing VMware tools
echo ==^> VMware tools path: %VMWARE_TOOLS_SETUP_PATH%
"%VMWARE_TOOLS_SETUP_PATH%" /S /v "/qn REBOOT=R ADDLOCAL=ALL"
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%VMWARE_TOOLS_SETUP_PATH%" /S /v "/qn REBOOT=R ADDLOCAL=ALL"
ver>nul
goto :done

:done
