$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
# Gera os arquivos nativos sem substituir o código entregue.
$backup = Join-Path ([System.IO.Path]::GetTempPath()) ('adotapet-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $backup | Out-Null
Copy-Item lib "$backup/lib" -Recurse
Copy-Item pubspec.yaml "$backup/pubspec.yaml"
Copy-Item .gitignore "$backup/gitignore"
try {
  flutter create --platforms=android --project-name adotapet .
  if ($LASTEXITCODE -ne 0) { throw 'flutter create falhou' }
} finally {
  Copy-Item "$backup/lib/*" lib -Recurse -Force
  Copy-Item "$backup/pubspec.yaml" pubspec.yaml -Force
  Copy-Item "$backup/gitignore" .gitignore -Force
  Remove-Item $backup -Recurse -Force
}
# O teste padrão do contador não se aplica ao AdotaPet.
if (Test-Path test/widget_test.dart) { Remove-Item test/widget_test.dart }
$manifest = 'android/app/src/main/AndroidManifest.xml'
$xml = Get-Content $manifest -Raw
if ($xml -notmatch 'android.permission.INTERNET') { $xml = $xml -replace '<application', '<uses-permission android:name="android.permission.INTERNET" />`n    <application' }
$xml = $xml.Replace('`n', "`n").Replace('android:label="adotapet"','android:label="AdotaPet"')
Set-Content $manifest $xml -Encoding utf8
flutter pub get
