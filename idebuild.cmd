build -restore -binaryLog -configuration Release /p:OfficialBuild=true /p:DebugType=embedded /p:VisualStudioDropName=Products/drop /p:RepositoryName=VSRepo
msbuild /bl copy.proj
nuget pack roslyn.nuspec