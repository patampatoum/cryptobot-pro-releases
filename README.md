# CryptoBot Pro

Desktop grid trading bot for BTC spot. The pair is BTC/USDC everywhere except Aster, which trades
BTC/USDT. The interface is Electron, the trading engine is a Go binary, and both run on your own
machine. There is no server of mine in the trading loop: the app talks to your exchange directly.
Shortly after start-up and then every 24 hours while it is open, it sends the email address of your
subscription, and nothing else, to a function on the website, which asks Stripe whether the
subscription is still active; the license expires when it is not. There is no account to create.
Your exchange API keys, and the wallet key used to sign on Hyperliquid and Aster, sit in clear text
in a config file on your disk, readable by anything running under your user account.

This repository holds the release binaries. The application is closed source.

- Website: https://gribbot-btc-usdc.netlify.app
- Setup guide: https://gribbot-btc-usdc.netlify.app/docs/Setup%20Guide.html

![CryptoBot Pro dashboard](https://raw.githubusercontent.com/patampatoum/cryptobot-pro-releases/main/media/dashboard-light.png)

## How it trades

One pair, one strategy: BTC/USDC, and BTC/USDT on Aster. The bot places a limit buy below the
market. Once that buy fills, the next update places a sell above the buy price. When the sell fills,
the cycle closes and the spread minus fees is booked. No prediction, no signals, no leverage, no
shorts, no futures.

A cycle closes only when its sell fills above its buy, so a losing position stays open instead of
being sold at a loss. If BTC leaves the bottom of your range, the bot keeps buying on the way down,
the cycles go quiet, and you hold spot BTC bought higher until the price comes back. The risk you
are taking is that your money stays locked up in BTC bought too high, for as long as it takes. It
does not protect you from a bear market. There is no liquidation, because there is no leverage.

## Exchanges

Hyperliquid, Bitvavo, Aster, Kraken, MEXC, KuCoin, and Binance outside the EU.

On Binance, Kraken, MEXC, KuCoin and Bitvavo, create the API key with trading allowed and
withdrawals disabled. The bot never needs withdrawal rights. Hyperliquid and Aster work differently:
since 3.0.6 you connect Hyperliquid with either an API wallet (created in the Hyperliquid app under
More, then API, valid for 180 days at most) or the private key of your wallet. An API wallet can
place and cancel orders but cannot withdraw to another address, while the private key of your
wallet cannot be limited to trading. Aster also signs with an API wallet key: allow spot trading
only and disable withdrawals where the option is offered. Hyperliquid has no IP whitelist, so a
stolen API wallet key can still place orders: on both exchanges, use a wallet that holds nothing
but your trading capital.
Your machine has to be running for the bot to trade.

## Install

Windows x64: download `CryptoBot-Pro-Setup-3.0.7.exe` and run it. The binaries are not code signed,
so SmartScreen shows a warning. Click "More info", then "Run anyway". Chocolatey users can run
`choco install cryptobot-pro`, which downloads the same installer and runs it silently, and upgrade
with `choco upgrade cryptobot-pro`. Installing or upgrading through Chocolatey closes CryptoBot Pro
if it is running and opens it when the installer finishes; if the app already updated itself to a
newer version, `choco upgrade` leaves it alone. The package source is in `packaging/chocolatey` of
this repository and the listing is at https://community.chocolatey.org/packages/cryptobot-pro.

Debian and Ubuntu: `sudo apt install ./cryptobot-pro_3.0.7_amd64.deb`

Other Linux: download `CryptoBot-Pro-3.0.7.AppImage`, then `chmod +x CryptoBot-Pro-3.0.7.AppImage`
and run it. On Ubuntu 22.04 and later, install FUSE 2 first: `sudo apt install libfuse2`, or
`sudo apt install libfuse2t64` on releases that ship it under that name, such as Ubuntu 24.04.
Without it the launch fails with an error about libfuse.so.2.

macOS on Apple Silicon: `CryptoBot-Pro-3.0.7-arm64.dmg`. macOS on Intel: `CryptoBot-Pro-3.0.7.dmg`.
The build is not notarized, so macOS blocks the first launch. Open System Settings, go to Privacy
and Security, allow the app there, then open it again. Homebrew users can install the same disk
image from the developer's tap:

```
brew install --cask patampatoum/tap/cryptobot-pro
xattr -dr com.apple.quarantine "/Applications/CryptoBot Pro.app"
```

Homebrew quarantines the download, and the quarantine flag stops the trading engine inside the
app, so run the `xattr` line after every install and every upgrade. Upgrade with
`brew update && brew upgrade --cask patampatoum/tap/cryptobot-pro`. The cask source is at
https://github.com/patampatoum/homebrew-tap.

Auto-update works on Windows and on the AppImage, the latter from 3.0.4 on. The .deb package and
the macOS builds do not update themselves, but the app checks this releases page once a day and
shows a banner with a link to the new version. The feed is
https://github.com/patampatoum/cryptobot-pro-releases/releases.atom

## For package maintainers

The Windows installer is NSIS, one-click and per-machine, so it asks for elevation. Silent install
is `/S`. The installer application identifier, the one to put in a manifest, is
`com.cryptobotpro.tradingbot`. Note that the running app sets a different Windows AppUserModelID,
`com.cryptobot.pro`, so do not take the manifest identifier from an installed copy.

Windows is x86_64 only, there is no arm64 Windows build. Linux ships as a .deb for amd64 and an
AppImage for x86_64, with no arm64 and no 32-bit build. macOS ships as two .dmg files, one for Apple
Silicon and one for Intel, neither signed nor notarized.

SHA-256 for 3.0.7:

```
CryptoBot-Pro-Setup-3.0.7.exe    c51fa956df4a66a8c1ede1194c99da6b9bb619591f45543dfef3c9551c35ff97
cryptobot-pro_3.0.7_amd64.deb    c775f1c536eeda8a1380af3bb3564b437cc98edebfbbcc861d9d289894304f1c
CryptoBot-Pro-3.0.7.AppImage     2a19ea545a95b2d70016e0f9a5f46370ce09938d63cb9639e4c3497c15537139
CryptoBot-Pro-3.0.7-arm64.dmg    2f105af0cc8ec9a96bab92d33a9ea7d459bbdb05555408ded483942aabd62012
CryptoBot-Pro-3.0.7.dmg          ffecf06b03d514e333acb4c97f04b450f7b95cac47b15131750406c40c3798cd
```

Packaging terms are in the "License and redistribution" section below.

## Features

Grid restructuring: regroup or split sells, or move a whole grid to another exchange. You get a
preview before anything is cancelled, and there is no way back once it runs.

A Telegram interface: one notification per closed cycle, read commands, and any mutation behind a
confirmation. It answers only while the scheduler is running.

Per-exchange sizing modes, an Excel tax export, automatic database backups, and a light and dark
theme.

An analytics dashboard, including Drop Cover: how far BTC can fall before a given exchange runs out
of free USDC.

Since 3.0.6, Hyperliquid can be connected with an API wallet, which can trade but cannot withdraw;
the private key of your wallet still works.

## Price

5.99 USD per month, 29.99 USD for 6 months, 49.99 USD for 12 months. Every plan has every feature.

The trial runs 90 days with everything included. No account is needed to download. Payment details
are taken when the trial starts, and the first charge is on day 91.

## Live results

My own money, net of real fees. The figures below were generated on 20 October 2026, and the last
cycle they include closed on 20 October 2026.

4,359 closed cycles since 19 December 2025, for +507.98 USDC net (573.93 gross, 65.95 paid in fees).
That is 0.1165 USDC net per cycle on average, on a capital base of 4,761 USDC: 10.67 % since the
start, 2.32 % over 30 days, 0.34 % over the last 7 days. This is ten months of a single grid on a
single pair, and the last 30 days alone account for 110.29 of the 507.98 USDC, a little over a
fifth of the total, so the recent figures are not a yearly rate.

All 4,359 closed cycles are winners, which is exactly what the rule above produces: a cycle closes
only when its sell fills above its buy, and losing positions stay open instead.

The Hyperliquid part is verifiable on chain at 0xc2E2c523A41F66b09448AC432BEf01ab23cDF2Bd on
hypurrscan.io, and covers 1,912 of those cycles. The other 2,447 ran on Binance (942), Kraken
(498), Aster (495), Bitvavo (315) and MEXC (197); Hyperliquid is the only one where a published
address lets you check the cycles yourself. KuCoin is supported by the app, but I have no cycles of
my own there.

Live figures: https://gribbot-btc-usdc.netlify.app

## Bugs and questions

Open an issue here, or write to CryptoBro_Bot_Pro@proton.me

## License and redistribution

CryptoBot Pro is proprietary software. The terms are in LICENSE.txt in this repository and at
https://gribbot-btc-usdc.netlify.app/terms.html

Package maintainers and download sites: package repositories (such as winget, Chocolatey, the AUR,
Homebrew and AppImageHub) and software download sites may list CryptoBot Pro and either point at
the official files on this releases page or mirror those files unchanged. A recipe that downloads
an official file and unpacks it at install time, such as an AUR -bin PKGBUILD, is allowed. The
binaries must not be modified or bundled with other software. Write to CryptoBro_Bot_Pro@proton.me
if you want that permission in writing.

## Legal

CryptoBot Pro is a software tool. It is not an investment service and nothing here is financial
advice. A grid strategy can lose money, in particular during a long drawdown.

- Terms of sale and licence: https://gribbot-btc-usdc.netlify.app/terms.html
- Privacy: https://gribbot-btc-usdc.netlify.app/legal.html
