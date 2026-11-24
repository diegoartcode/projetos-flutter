$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
if (!(Get-Command flutter -ErrorAction SilentlyContinue)) { throw "Flutter não localizado no PATH." }
# Gera os arquivos nativos em uma pasta temporária, sem sobrescrever lib/.
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("meufinance_" + [guid]::NewGuid().ToString("N"))
try {
  flutter create --platforms=android --project-name meufinance --org br.edu.exemplo --no-pub $temp
  if ($LASTEXITCODE -ne 0) { throw "Falha em flutter create" }
  foreach ($item in @("android", ".metadata")) {
    if (!(Test-Path $item)) { Copy-Item (Join-Path $temp $item) -Destination $item -Recurse }
  }
} finally { if (Test-Path $temp) { Remove-Item $temp -Recurse -Force } }
flutter pub get
if ($LASTEXITCODE -ne 0) { throw "Falha em flutter pub get" }
Write-Host "Execute flutterfire configure para gerar lib/firebase_options.dart."
