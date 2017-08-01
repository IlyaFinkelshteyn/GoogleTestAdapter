@echo off
 
set DIA_SDK="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\DIA SDK\bin"


if defined APPVEYOR goto Build


echo:
echo You have to accept the following licenses before executing this batch file:
echo:
echo Component X: MIT license (http://www.mit.edu)
echo Components Y, Z: Apache license (http://www.apache.org)
echo:
set /p input= "Do you accept these licenses? (yes/no) "

if not "%input%" == "yes" goto End


:Build

echo Setting adapter flavor to GTA
powershell -Command "(gc TestAdapterFlavor.props) -replace '>TAfGT<', '>GTA<' | Out-File TestAdapterFlavor.props"

echo Execute preparing T4 scripts
msbuild ResolveTTs.proj

echo Removing TAfGT projects (for now)
powershell -ExecutionPolicy Bypass .\Tools\RemoveGtaProjects.ps1 -flavor GTA

echo Copying DIA dlls
cd GoogleTestAdapter\DiaResolver
copy %DIA_SDK%\msdia140.dll x86
copy %DIA_SDK%\amd64\msdia140.dll x64

echo Generating dia2.dll
cd dia2
powershell -ExecutionPolicy Bypass .\compile_typelib.ps1

echo Building Google Test NuGet packages
cd ..\..
nuget.exe restore GoogleTestAdapter.sln
cd ..
rem git submodule init
rem git submodule update
cd GoogleTestNuGet
rem powershell .\Build.ps1 -Verbose
cd ..


:End
