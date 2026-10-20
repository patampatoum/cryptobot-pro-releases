$ErrorActionPreference = 'Stop'

$installed = Get-UninstallRegistryKey -SoftwareName 'CryptoBot Pro [0-9]*' |
  Where-Object { $_.PSPath -like '*HKEY_LOCAL_MACHINE*' } |
  Select-Object -First 1
$installedVersion = if ($installed) { $installed.DisplayVersion -as [version] }
$packageVersion = $env:ChocolateyPackageVersion -as [version]
if ($installedVersion -and $packageVersion -and $installedVersion -ge $packageVersion -and $env:ChocolateyForce -ne 'true') {
  Write-Host "CryptoBot Pro $installedVersion is already installed (the app updates itself). Skipping the installer."
  return
}

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'exe'
  url64bit       = 'https://github.com/patampatoum/cryptobot-pro-releases/releases/download/v3.0.7/CryptoBot-Pro-Setup-3.0.7.exe'
  checksum64     = 'c51fa956df4a66a8c1ede1194c99da6b9bb619591f45543dfef3c9551c35ff97'
  checksumType64 = 'sha256'
  silentArgs     = '/S --force-run'
  validExitCodes = @(0)
  softwareName   = 'CryptoBot Pro*'
}

Install-ChocolateyPackage @packageArgs
