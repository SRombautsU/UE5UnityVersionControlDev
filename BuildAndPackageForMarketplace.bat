@echo off
setlocal

set ROOT_PATH=%~dp0

pushd %ROOT_PATH%

echo Plugins\UnityVersionControl\UnityVersionControl.uplugin:
type Plugins\UnityVersionControl\UnityVersionControl.uplugin
echo .

REM Read the plugin version from uplugin file and prompt the user to check, and name zip files from the version
if [%1] == [] (
  set /p VERSION="Enter the version name exactly as in the UnityVersionControl.uplugin above: "
) else (
  set VERSION=%1
)
if [%VERSION%] == [] (
  echo Version is empty
  exit /b 1
)

REM TODO: double check with the uplugin and also search in the README

REM Let's also check we are on main
echo on
git branch
@echo off

REM Ask the user if they agree to do a git clean & a git reset! Else we abort the process.
set /p GIT_CLEAN_RESET="WARNING: Git clean & reset before building. You will lose any local changes you have! (ENTER/N)? "
if [%GIT_CLEAN_RESET%] == [] (
  echo on
  git stash --message "Automatic stash from BuildAndPackageForRelease %VERSION%"
  git clean -fdx
  git reset --hard
  pushd Plugins\UnityVersionControl
  git stash --message "Automatic stash from BuildAndPackageForRelease %VERSION%"
  git clean -fdx
  git reset --hard
  popd
  @echo off
) else (
  echo Git clean is required, exiting.
  exit /b
)


REM
REM #####################
REM
REM The Unreal Engine Marketplace only allow to submit new version for the last 3 Unreal versions
call :BuildAndPackage 5.3
call :BuildAndPackage 5.4

REM NOTE: Unreal 5.5 requires C++20 if not compiling with Unity Builds, we have to edit "UE5PlasticPluginDevEditor.Target.cs" manually before continuing!
REM set /p PAUSE="WARNING: you have to edit Source\UE5PlasticPluginDevEditor.Target.cs and uncomment CppStandard = CppStandardVersion.Cpp20; before compiling for UE5.5 (ENTER)"
call :BuildAndPackage 5.5
REM
REM Done
REM

echo .
echo NOTE: After validation, add the source package to the corresponding github release and post to the Marketplace the links to these
exit /b %ERRORLEVEL%



REM
REM ################# BuildAndPackage Function
REM

:BuildAndPackage

set UNREAL_ENGINE=%~1

call :ReplaceEngineVersion 5.0.0 %UNREAL_ENGINE%.0

REM Let's ensure that the plugin correctly builds
del /Q Plugins\UnityVersionControl\Binaries\Win64\*
call Build.bat %UNREAL_ENGINE%
if NOT exist Plugins\UnityVersionControl\Binaries\Win64\UnrealEditor-UnityVersionControl.dll (
  echo Something is wrong, some binaries are missing.
  exit /b 1
)

REM Create the archive for the Marketplace from within the Plugins subfolder for a cleaner ZIP
cd Plugins

set ARCHIVE_NAME_REL=UE%UNREAL_ENGINE%_UnityVersionControl-%VERSION%.zip

echo on
del ..\%ARCHIVE_NAME_REL%
..\Tools\7-Zip\x64\7za.exe a -tzip ..\%ARCHIVE_NAME_REL% UnityVersionControl -xr!Binaries -xr!Intermediate -xr!Screenshots -xr!.editorconfig -xr!".git*" -xr!"cm.log.conf" -xr!_config.yml -xr!README.md -xr!"*.pdb"
@echo off

cd ..

call :ReplaceEngineVersion %UNREAL_ENGINE%.0 5.0.0

echo Done for Unreal Engine %UNREAL_ENGINE%
echo .

exit /b %ERRORLEVEL%


REM
REM ################# ReplaceEngineVersion Function
REM

:ReplaceEngineVersion

set OLD_VERSION=%~1
set NEW_VERSION=%~2
set UPLUGIN=Plugins\UnityVersionControl\UnityVersionControl.uplugin

if [%OLD_VERSION%] == [%NEW_VERSION%] (
  exit /b
)

echo Replace "EngineVersion": "%OLD_VERSION%" by "%NEW_VERSION%" in %UPLUGIN%

setlocal enableextensions disabledelayedexpansion

for /f "delims=" %%i in ('type "%UPLUGIN%" ^& break ^> "%UPLUGIN%" ') do (
  set "line=%%i"
  setlocal enabledelayedexpansion
  >>"%UPLUGIN%" echo(!line:%OLD_VERSION%=%NEW_VERSION%!
  endlocal
)

endlocal


exit /b %ERRORLEVEL%

REM
REM #################
REM

