# Copia o projeto e o APK para a pasta do usuario, sem builds/node_modules
$dest = "C:\Users\RECEPCAO03\OneDrive\Documentos\JN-ST\ciclolivre"
$src = "C:\dev\ciclolivre"

if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

robocopy $src $dest /E /XD node_modules .gradle build .idea .git dist /XF *.log /NFL /NDL /NJH /NJS /NP | Out-Null

$apkSrc = Join-Path $src "android\app\build\outputs\apk\debug\app-debug.apk"
$apkDest = "C:\Users\RECEPCAO03\OneDrive\Documentos\JN-ST\CicloLivre-v1.0.0.apk"
Copy-Item $apkSrc $apkDest -Force

Write-Output "Projeto copiado para $dest"
Write-Output "APK: $apkDest ($([math]::Round((Get-Item $apkDest).Length / 1MB, 2)) MB)"
