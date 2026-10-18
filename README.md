# CryptoBot Pro

Desktop grid trading bot for BTC spot. The pair is BTC/USDC everywhere except Aster, which trades
BTC/USDT. The interface is Electron, the trading engine is a Go binary, and both run on your own
machine. There is no server of mine in the loop: the app talks to your exchange, and at most once a
day it calls Stripe with your email address to check that the subscription is still active. There is
no account to create. Your exchange API keys, and the wallet key used to sign on Hyperliquid and
Aster, sit in clear text in a config file on your disk, readable by anything running under your user
account.

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

Windows x64: download `CryptoBot-Pro-Setup-3.0.6.exe` and run it. The binaries are not code signed,
so SmartScreen shows a warning. Click "More info", then "Run anyway".

Debian and Ubuntu: `sudo apt install ./cryptobot-pro_3.0.6_amd64.deb`

Other Linux: download `CryptoBot-Pro-3.0.6.AppImage`, then `chmod +x CryptoBot-Pro-3.0.6.AppImage`
and run it. On Ubuntu 22.04 and later, install FUSE 2 first: `sudo apt install libfuse2`, or
`sudo apt install libfuse2t64` on releases that ship it under that name, such as Ubuntu 24.04.
Without it the launch fails with an error about libfuse.so.2.

macOS on Apple Silicon: `CryptoBot-Pro-3.0.6-arm64.dmg`. macOS on Intel: `CryptoBot-Pro-3.0.6.dmg`.
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

SHA-256 for 3.0.6:

```
CryptoBot-Pro-Setup-3.0.6.exe    290454a901a532d4231c33b839332283af08e5399085e9be1b493f273cb6691a
cryptobot-pro_3.0.6_amd64.deb    6d8b7551d48db9cb14797ac9326070f07501389e67a93bb612da454859752d44
CryptoBot-Pro-3.0.6.AppImage     9f0843f57199eb98712100215a8b9d4781cdd65050513ed94305f694b1ae0b52
CryptoBot-Pro-3.0.6-arm64.dmg    18ed918e349bc3d4939204541b5d39e4856656ed2f55349ec9726f6fb09ac48e
CryptoBot-Pro-3.0.6.dmg          0a2fec231473454264d4f19cc028ac5e5df288bc49e06367e12ad2ef165bf802
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

My own money, net of real fees. The figures below were generated on 16 October 2026, and the last
cycle they include closed on 15 October 2026.

4,278 closed cycles since 19 December 2025, for +496.87 USDC net (562.03 gross, 65.16 paid in fees).
That is 0.1161 USDC net per cycle on average, on a capital base of 4,750 USDC: 10.46 % since the
start, 2.52 % over 30 days, 0.35 % over the last 7 days. This is ten months of a single grid on a
single pair, and the last 30 days alone account for 119.68 of the 496.87 USDC, a little under a
quarter of the total, so the recent figures are not a yearly rate.

All 4,278 closed cycles are winners, which is exactly what the rule above produces: a cycle closes
only when its sell fills above its buy, and losing positions stay open instead.

The Hyperliquid part is verifiable on chain at 0xc2E2c523A41F66b09448AC432BEf01ab23cDF2Bd on
hypurrscan.io, and covers 1,862 of those cycles. The other 2,416 ran on Binance (942), Kraken
(498), Aster (474), Bitvavo (305) and MEXC (197); Hyperliquid is the only one where a published
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
