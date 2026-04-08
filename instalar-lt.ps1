$url = "https://languagetool.org/download/LanguageTool-stable.zip"
$dest = "LanguageTool.zip"
$extractPath = "$PWD\LanguageToolServer"

Write-Host "--- INICIANDO DOWNLOAD (Aprox. 200MB) ---" -ForegroundColor Cyan
Invoke-WebRequest -Uri $url -OutFile $dest

Write-Host "--- EXTRAINDO ARQUIVOS ---" -ForegroundColor Cyan
if (!(Test-Path $extractPath)) { New-Item -ItemType Directory -Path $extractPath }
Expand-Archive -Path $dest -DestinationPath $extractPath -Force

Write-Host "--- LIMPANDO ARQUIVOS TEMPORARIOS ---" -ForegroundColor Cyan
Remove-Item $dest

Write-Host "--- INSTALACAO CONCLUIDA! ---" -ForegroundColor Green
Write-Host "Acesse a pasta $extractPath e rode o arquivo iniciar-lt.bat"
