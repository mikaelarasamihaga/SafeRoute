$Sdk = "$env:USERPROFILE\AppData\Local\Android\sdk"
if (-not (Test-Path $Sdk)) { New-Item -ItemType Directory -Path $Sdk -Force | Out-Null }

$Url = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$ZipPath = Join-Path $Sdk "cmdline-tools.zip"
Write-Host "Downloading cmdline-tools..."
Invoke-WebRequest -Uri $Url -OutFile $ZipPath

$ExtractPath = Join-Path $Sdk "cmdline-tools"
Write-Host "Extracting..."
Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

$Inner = Join-Path $ExtractPath "cmdline-tools"
if (Test-Path $Inner) {
    Rename-Item -Path $Inner -NewName "latest" -Force
    Write-Host "Renamed to latest"
}
Remove-Item $ZipPath -Force
Write-Host "cmdline-tools installed at $Sdk\cmdline-tools\latest"
