$Sdk = "$env:USERPROFILE\AppData\Local\Android\sdk"
if (-not (Test-Path $Sdk)) { New-Item -ItemType Directory -Path $Sdk -Force | Out-Null }

$TempZip = "$env:TEMP\cmdline-tools.zip"
$TempExtract = "$env:TEMP\cmdtools"

# Clean previous temp files
if (Test-Path $TempZip) { Remove-Item $TempZip -Force }
if (Test-Path $TempExtract) { Remove-Item $TempExtract -Recurse -Force }

$Url = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
Write-Host "Downloading cmdline-tools..."
Invoke-WebRequest -Uri $Url -OutFile $TempZip

Write-Host "Extracting to temporary folder..."
Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force

# The zip contains a folder "cmdline-tools"; we want its contents as "latest"
$Src = Join-Path $TempExtract "cmdline-tools"
$Dest = Join-Path $Sdk "cmdline-tools\latest"
if (Test-Path $Dest) { Remove-Item $Dest -Recurse -Force }
New-Item -ItemType Directory -Path $Dest -Force | Out-Null
Copy-Item -Path (Join-Path $Src "*") -Destination $Dest -Recurse -Force

# Cleanup temp files
Remove-Item $TempZip -Force
Remove-Item $TempExtract -Recurse -Force

Write-Host "cmdline-tools installed at $Dest"
