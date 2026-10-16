# Chocolatey package source: cryptobot-pro

Source of the `cryptobot-pro` package published on https://community.chocolatey.org/packages/cryptobot-pro.

The package does not contain the application. At install time it downloads the official Windows
installer from this repository's releases page and checks its SHA-256 against `checksum64` in
`tools/chocolateyinstall.ps1`.

## Files

- `cryptobot-pro.nuspec`: package metadata and description.
- `tools/chocolateyinstall.ps1`: download URL, checksum, silent install (`/S`).
- `tools/chocolateyuninstall.ps1`: runs the uninstaller registered by the application.

## New release

1. Update `version` and `releaseNotes` in the nuspec, `url64bit` and `checksum64` in `tools/chocolateyinstall.ps1`
   (the SHA-256 is shown on the release page and in the README of this repository).
2. `choco pack` then `choco push cryptobot-pro.<version>.nupkg --source https://push.chocolatey.org/`.
3. Commit the updated files here, so that `packageSourceUrl` always shows the current source.

On Windows the application installs its own updates when the user clicks Update, so the version
in this package can be behind the one that is running.
