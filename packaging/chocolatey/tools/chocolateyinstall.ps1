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
  url64bit       = 'https://github.com/patampatoum/cryptobot-pro-releases/releases/download/v3.0.6/CryptoBot-Pro-Setup-3.0.6.exe'
  checksum64     = '290454a901a532d4231c33b839332283af08e5399085e9be1b493f273cb6691a'
  checksumType64 = 'sha256'
  silentArgs     = '/S --force-run'
  validExitCodes = @(0)
  softwareName   = 'CryptoBot Pro*'
}

Install-ChocolateyPackage @packageArgs
