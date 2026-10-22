$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$manifest = Get-Content -LiteralPath (Join-Path $root 'package.json') -Raw | ConvertFrom-Json
if ($manifest.publisher -notmatch '^[a-zA-Z0-9-]+$' -or $manifest.name -notmatch '^[a-z0-9-]+$' -or $manifest.version -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid package identity' }
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $dist | Out-Null
$target = Join-Path $dist "$($manifest.name)-$($manifest.version).vsix"
$vsix = @"
<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011">
<Metadata><Identity Language="en-US" Id="$($manifest.name)" Version="$($manifest.version)" Publisher="$($manifest.publisher)"/>
<DisplayName>Antigravity Option 2</DisplayName><Description xml:space="preserve">Toggle conversation-scoped approvals on Windows.</Description>
<Tags>antigravity,approval</Tags><Categories>Other</Categories><GalleryFlags>Preview</GalleryFlags>
<Properties><Property Id="Microsoft.VisualStudio.Code.Engine" Value="^1.85.0"/><Property Id="Microsoft.VisualStudio.Code.ExtensionDependencies" Value=""/><Property Id="Microsoft.VisualStudio.Code.ExtensionPack" Value=""/></Properties></Metadata>
<Installation><InstallationTarget Id="Microsoft.VisualStudio.Code"/></Installation><Dependencies/>
<Assets><Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/><Asset Type="Microsoft.VisualStudio.Services.Content.Details" Path="extension/README.md" Addressable="true"/><Asset Type="Microsoft.VisualStudio.Services.Content.License" Path="extension/LICENSE" Addressable="true"/></Assets>
</PackageManifest>
"@
$types = '<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="json" ContentType="application/json"/><Default Extension="js" ContentType="application/javascript"/><Default Extension="ps1" ContentType="text/plain"/><Default Extension="md" ContentType="text/markdown"/><Default Extension="vsixmanifest" ContentType="text/xml"/><Default Extension="xml" ContentType="text/xml"/><Default Extension="" ContentType="text/plain"/></Types>'
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression
$stream = [System.IO.File]::Open($target, [System.IO.FileMode]::Create)
$archive = [System.IO.Compression.ZipArchive]::new($stream, [System.IO.Compression.ZipArchiveMode]::Create)
function Add-Text($name, $text) {
    $entry = $archive.CreateEntry($name)
    $writer = [System.IO.StreamWriter]::new($entry.Open(), [System.Text.UTF8Encoding]::new($false))
    try { $writer.Write($text) } finally { $writer.Dispose() }
}
try {
    Add-Text 'extension.vsixmanifest' $vsix
    Add-Text '[Content_Types].xml' $types
    foreach ($file in @('package.json', 'extension.js', 'controller.js', 'watcher.ps1', 'rules.ps1', 'README.md', 'LICENSE', 'CHANGELOG.md')) {
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, (Join-Path $root $file), "extension/$file") | Out-Null
    }
} finally { $archive.Dispose(); $stream.Dispose() }
$check = [System.IO.Compression.ZipFile]::OpenRead($target)
try {
    if ($check.Entries.Count -ne 10) { throw 'Unexpected package contents' }
    foreach ($entry in $check.Entries) { if ($entry.FullName -match '\.env|\.git/|test/') { throw 'Unexpected private or development file in package' } }
} finally { $check.Dispose() }
Write-Output "Built $target"
