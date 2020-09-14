call build -restore -binaryLog -configuration Release /p:OfficialBuild=true /p:DebugType=embedded /p:VisualStudioDropName=Products/drop /p:RepositoryName=VSRepo

if %errorlevel% NEQ 0 (
	echo Failed to build Roslyn
	exit /b %errorlevel%
)

call msbuild /bl copy.proj
if %errorlevel% NEQ 0 (
	echo Failed copy.proj
	exit /b %errorlevel%
)

call nuget pack roslyn.nuspec -Version 1.0.22