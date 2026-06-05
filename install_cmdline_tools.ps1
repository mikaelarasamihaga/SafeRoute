$Sdk = "$env:USERPROFILE\AppData\Local\Android\sdk"
if (-not (Test-Path $Sdk)) {
    New-Item -ItemType Directory -Path $Sdk -Force | Out-Null
}
$Url = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$ZipPath = Join-Path $Sdk "cmdline-tools.zip"
Invoke-WebRequest -Uri $Url -OutFile $ZipPath
$ExtractPath = Join-Path $Sdk "cmdline-tools"
Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force
# The zip creates cmdline-tools\cmdline-tools; rename inner to latest
$Inner = Join-Path $ExtractPath "cmdline-tools"
Rename-Item -Path $Inner -NewName "latest" -Force
Remove-Item $ZipPath -Force
