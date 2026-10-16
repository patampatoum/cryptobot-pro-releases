$ErrorActionPreference = 'Stop'

$keys = @(Get-UninstallRegistryKey -SoftwareName 'CryptoBot Pro [0-9]*' |
  Where-Object { $_.PSPath -like '*HKEY_LOCAL_MACHINE*' })

if ($keys.Count -eq 0) {
  Write-Warning 'CryptoBot Pro has already been uninstalled by other means.'
  return
}
if ($keys.Count -gt 1) {
  Write-Warning "$($keys.Count) matches found, nothing uninstalled: $($keys.DisplayName -join ', ')"
  return
}

$key  = $keys[0]
$file = $key.UninstallString -replace '^"([^"]+)".*$', '$1'
if (-not (Test-Path -LiteralPath $file)) {
  Write-Warning "Uninstaller not found, nothing uninstalled: $file"
  return
}

Uninstall-ChocolateyPackage -PackageName $env:ChocolateyPackageName `
  -FileType 'exe' `
  -SilentArgs '/allusers /S' `
  -ValidExitCodes @(0) `
  -File $file

$deadline = (Get-Date).AddMinutes(2)
while ((Test-Path -LiteralPath $key.PSPath) -and ((Get-Date) -lt $deadline)) { Start-Sleep -Seconds 1 }
if (Test-Path -LiteralPath $key.PSPath) { Write-Warning 'The uninstaller is still running after 2 minutes.' }
