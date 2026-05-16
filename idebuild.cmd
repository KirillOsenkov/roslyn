@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -File Generate-RoslynNoTests.ps1
if errorlevel 1 (echo Failed to generate RoslynNoTests.slnx & exit /b 1)

rem Use the locally-pinned SDK from .dotnet (set up by build.cmd's first run);
rem fall back to global dotnet if .dotnet doesn't exist yet.
set _DOTNET=%~dp0.dotnet\dotnet.exe
if not exist "%_DOTNET%" set _DOTNET=dotnet

call "%_DOTNET%" build RoslynNoTests.slnx -c Release -bl:RoslynNoTests.binlog /p:OfficialBuild=true /p:DebugType=embedded /p:UsingToolVisualStudioIbcTraining=false /p:EnableNgenOptimization=false /p:DotNetUseShippingVersions=true
if errorlevel 1 (echo Failed to build RoslynNoTests.slnx & exit /b 1)

call msbuild /bl:copy.binlog copy.proj
if errorlevel 1 (echo Failed to run copy.proj & exit /b 1)

call "%~dp0pack.cmd"
if errorlevel 1 (echo Failed to pack & exit /b 1)
