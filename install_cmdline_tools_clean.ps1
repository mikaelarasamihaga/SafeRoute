$Sdk = "$env:USERPROFILE\AppData\Local\Android\sdk"
if (-not (Test-Path $Sdk)) { New-Item -ItemType Directory -Path $Sdk -Force }

$Url = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$ZipPath = Join-Path $Sdk "cmdline-tools.zip"

# Remove any existing zip
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }

Write-Host "Downloading cmdline-tools..."
Invoke-WebRequest -Uri $Url -OutFile $ZipPath

$ExtractPath = Join-Path $Sdk "cmdline-tools"
if (Test-Path $ExtractPath) { Remove-Item $ExtractPath -Recurse -Force }
Write-Host "Extracting..."
Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

# Rename inner folder to "latest"
$Inner = Join-Path $ExtractPath "cmdline-tools"
$Dest = Join-Path $Sdk "cmdline-tools\latest"
if (Test-Path $Dest) { Remove-Item $Dest -Recurse -Force }
Rename-Item -Path $Inner -NewName "latest"

# Cleanup zip
Remove-Item $ZipPath -Force

Write-Host "cmdline-tools installed at $Dest"
