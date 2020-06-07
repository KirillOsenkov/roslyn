call build -restore -binaryLog -configuration Release /p:OfficialBuild=true /p:DebugType=embedded /p:VisualStudioDropName=Products/drop /p:RepositoryName=VSRepo
call msbuild /bl copy.proj
call nuget pack roslyn.nuspec -Version 1.0.11