@echo off
setlocal EnableDelayedExpansion

set ROOTPATH=%~dp0

pushd %ROOTPATH%

REM Default to the oldest Unreal Engine 5 version but can be overriden to any other version
if [%1] == [] (
  set ENGINE=5.0
) else (
  set ENGINE=%1
)

set ENGINEPATH="C:\Program Files\Epic Games\UE_%ENGINE%"
set UBT=!ENGINEPATH!\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe

if not exist %UBT% (
    echo %UBT% not found
    exit /b
)

echo Unsing Unreal Engine %ENGINE% from %ENGINEPATH%

for %%a in (*.uproject) do set "UPROJECT=%CD%\%%a"
if not defined UPROJECT (
    echo *.uproject file not found
    exit /b
)

for %%i in ("%UPROJECT%") do (
  set PROJECT=%%~ni
)

echo Build %UPROJECT% (project '%PROJECT%')

echo on
%UBT% %UPROJECT% Win64 Development %PROJECT%Editor
@echo off
