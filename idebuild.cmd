call build -restore -binaryLog -configuration Release /p:OfficialBuild=true /p:DebugType=embedded /p:VisualStudioDropName=Products/drop /p:RepositoryName=VSRepo

if %errorlevel% NEQ 0 (
	echo Failed to build Roslyn
	exit /b %errorlevel%
)

call msbuild /bl:copy.binlog copy.proj
if %errorlevel% NEQ 0 (
	echo Failed copy.proj
	exit /b %errorlevel%
)

call nuget pack microsoft.ide.internal.roslyn.nuspec -Version 1.0.2