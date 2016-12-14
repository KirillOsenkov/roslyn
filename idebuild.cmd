restore.cmd
REM build.cmd -release -official -sign -binaryLog

"C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe" /nr:false /clp:v=m /p:Configuration=Release /m /bl:C:\roslyn\Binaries\Logs\Roslyn.binlog /p:DeployExtension=false /p:SkipApplyOptimizations=true /p:BuildNumber=20180315.5 /p:OfficialBuild=true /p:RoslynDebugType=embedded Roslyn.sln