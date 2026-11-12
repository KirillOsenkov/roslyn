@echo off
setlocal

rem Bump the third component only -- the package id stays 1.0.*. Update this line and re-run.
set _Version=1.0.25

call nuget pack microsoft.ide.internal.roslyn.nuspec -Version %_Version%
if errorlevel 1 (echo Failed to nuget pack & exit /b 1)
