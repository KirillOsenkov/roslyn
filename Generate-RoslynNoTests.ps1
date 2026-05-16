# Generate RoslynNoTests.slnx from Roslyn.slnx by removing projects/folders
# whose name matches one of the SolutionFilter.txt patterns (which are file/dir
# name globs prefixed with !).
#
# This replaces the older slnfilter step which only worked on .sln files.

[CmdletBinding()]
param(
    [string]$Source,
    [string]$Filter,
    [string]$Destination
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Source)      { $Source      = Join-Path $root 'Roslyn.slnx' }
if (-not $Filter)      { $Filter      = Join-Path $root 'SolutionFilter.txt' }
if (-not $Destination) { $Destination = Join-Path $root 'RoslynNoTests.slnx' }

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $Source)) { throw "Source not found: $Source" }
if (-not (Test-Path $Filter)) { throw "Filter not found: $Filter" }

# Read patterns. Each line starts with '!' and contains a wildcard pattern that
# matches against the project / folder leaf name (without extension).
$patterns = @()
foreach ($line in Get-Content $Filter) {
    $t = $line.Trim()
    if (-not $t) { continue }
    if ($t.StartsWith('!')) { $patterns += $t.Substring(1) }
}

if (-not $patterns) { throw "No '!pattern' lines found in $Filter" }

[xml]$doc = Get-Content $Source -Raw

function Test-Match([string]$name) {
    foreach ($p in $patterns) {
        if ($name -like $p) { return $true }
    }
    return $false
}

# Drop any <Project Path="..."> whose project file name (sans extension) matches.
# Track the relative path of every removed project so we can also drop
# <BuildDependency Project="<that path>"/> references on surviving projects.
$removed = 0
$removedProjectPaths = @{}
$projects = @($doc.SelectNodes('//Project[@Path]'))
foreach ($p in $projects) {
    $leaf = [System.IO.Path]::GetFileNameWithoutExtension($p.Path)
    if (Test-Match $leaf) {
        # Normalize forward/backward slashes so we can compare against BuildDependency Project="...".
        $key = $p.Path.Replace('\','/').ToLowerInvariant()
        $removedProjectPaths[$key] = $true
        [void]$p.ParentNode.RemoveChild($p)
        $removed++
    }
}

# Drop any <BuildDependency> whose Project= points at a removed project.
$droppedDeps = 0
foreach ($dep in @($doc.SelectNodes('//BuildDependency[@Project]'))) {
    $key = $dep.Project.Replace('\','/').ToLowerInvariant()
    if ($removedProjectPaths.ContainsKey($key)) {
        [void]$dep.ParentNode.RemoveChild($dep)
        $droppedDeps++
    }
}

# Also drop empty folders
$changed = $true
while ($changed) {
    $changed = $false
    foreach ($folder in @($doc.SelectNodes('//Folder'))) {
        if (-not $folder.HasChildNodes -or
            ($folder.ChildNodes.Count -eq 1 -and $folder.ChildNodes[0].NodeType -eq 'Whitespace')) {
            [void]$folder.ParentNode.RemoveChild($folder)
            $changed = $true
        }
    }
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.IndentChars = '  '
$settings.OmitXmlDeclaration = $true
$settings.Encoding = New-Object System.Text.UTF8Encoding $false  # no BOM (matches the upstream Roslyn.slnx)
$writer = [System.Xml.XmlWriter]::Create($Destination, $settings)
try { $doc.Save($writer) } finally { $writer.Dispose() }

Write-Host "Generated $Destination (removed $removed projects, $droppedDeps build-dep references; $($patterns.Count) patterns)"
