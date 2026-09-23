$ErrorActionPreference = 'Stop'
$serverRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$appRoot = [IO.Path]::GetFullPath((Join-Path $serverRoot '../claimdesk_flutter'))
$outputPath = [IO.Path]::GetFullPath((Join-Path $serverRoot 'web/app'))
if (-not $outputPath.StartsWith($serverRoot + [IO.Path]::DirectorySeparatorChar)) {
    throw 'Web output must stay inside the server package.'
}
Push-Location $appRoot
try {
    flutter build web --base-href /app/
    if ($LASTEXITCODE -ne 0) { throw 'Flutter web build failed.' }
    $builtPath = Join-Path $appRoot 'build/web'
    if (-not (Test-Path -LiteralPath (Join-Path $builtPath 'index.html'))) {
        throw 'Flutter did not produce index.html.'
    }
    if (Test-Path -LiteralPath $outputPath) {
        Remove-Item -LiteralPath $outputPath -Recurse -Force
    }
    Copy-Item -LiteralPath $builtPath -Destination $outputPath -Recurse
} finally {
    Pop-Location
}
