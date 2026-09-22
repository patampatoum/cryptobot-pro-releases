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
the bot authenticates by signing with a wallet key, and a wallet key cannot be restricted to trading
only, so use a wallet that holds nothing but your trading capital. Your machine has to be running
for the bot to trade.

## Install

Windows x64: download `CryptoBot-Pro-Setup-3.0.2.exe` and run it. The binaries are not code signed,
so SmartScreen shows a warning. Click "More info", then "Run anyway".

Debian and Ubuntu: `sudo apt install ./cryptobot-pro_3.0.2_amd64.deb`

Other Linux: download `CryptoBot-Pro-3.0.2.AppImage`, then `chmod +x CryptoBot-Pro-3.0.2.AppImage`
and run it. On Ubuntu 22.04 and later, install FUSE 2 first: `sudo apt install libfuse2`, or
`sudo apt install libfuse2t64` on releases that ship it under that name, such as Ubuntu 24.04.
Without it the launch fails with an error about libfuse.so.2.

macOS on Apple Silicon: `CryptoBot-Pro-3.0.2-arm64.dmg`. macOS on Intel: `CryptoBot-Pro-3.0.2.dmg`.
The build is not notarized, so macOS blocks the first launch. Open System Settings, go to Privacy
and Security, allow the app there, then open it again.

Auto-update works on Windows. On the .deb package and on the macOS builds the app does not update
itself, but it checks this releases page once a day and shows a banner with a link to the new
version. On the AppImage, 3.0.2 does neither: it looks for an update file that has never been
published, fails silently, and shows no banner, so you have to watch the releases yourself. The feed
is https://github.com/patampatoum/cryptobot-pro-releases/releases.atom

## For package maintainers

The Windows installer is NSIS, one-click and per-machine, so it asks for elevation. Silent install
is `/S`. The installer application identifier, the one to put in a manifest, is
`com.cryptobotpro.tradingbot`. Note that the running app sets a different Windows AppUserModelID,
`com.cryptobot.pro`, so do not take the manifest identifier from an installed copy.

Windows is x86_64 only, there is no arm64 Windows build. Linux ships as a .deb for amd64 and an
AppImage for x86_64, with no arm64 and no 32-bit build. macOS ships as two .dmg files, one for Apple
Silicon and one for Intel, neither signed nor notarized.

SHA-256 for 3.0.2:

```
CryptoBot-Pro-Setup-3.0.2.exe    4e197ef517da3fcbe4e0b487cba0e60607da02f9a9b76c50da68d1268bc0f472
cryptobot-pro_3.0.2_amd64.deb    70b6ea28ea3666a7d3da27788878040dd5c987d997030690832400219727d6a1
CryptoBot-Pro-3.0.2.AppImage     b8a76e8714f47ccf4b09dd72239ab80b68f991076959b66728cee3f11f26903e
CryptoBot-Pro-3.0.2-arm64.dmg    05065eb7f0375de301a6757e3486e8fd2107f9457f04f15dfc48fa7a5fc0b8e9
CryptoBot-Pro-3.0.2.dmg          162f66bd5546e0ff0bc839f789dc1c2207ad8b3a661e38c2cb0cbf9497ab101a
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

## Price

5.99 USD per month, 29.99 USD for 6 months, 49.99 USD for 12 months. Every plan has every feature.

The trial runs 90 days with everything included. No account is needed to download. Payment details
are taken when the trial starts, and the first charge is on day 91.

## Live results

My own money, net of real fees. The figures below were generated on 22 September 2026, and the last
cycle they include closed on 21 September 2026.

3,732 closed cycles since 19 December 2025, for +413.36 USDC net (472.40 gross, 59.04 paid in fees).
That is 0.1108 USDC net per cycle on average, on a capital base of 4,676 USDC: 8.84 % since the
start, 2.49 % over 30 days, 0.85 % over the last 7 days. This is nine months of a single grid on a
single pair, and the last 30 days alone account for 116.66 of the 413.36 USDC, a little over a
quarter of the total, so the recent figures are not a yearly rate.

All 3,732 closed cycles are winners, which is exactly what the rule above produces: a cycle closes
only when its sell fills above its buy, and losing positions stay open instead.

The Hyperliquid part is verifiable on chain at 0xc2E2c523A41F66b09448AC432BEf01ab23cDF2Bd on
hypurrscan.io, and covers 1,598 of those cycles. The other 2,134 ran on Binance (942), Kraken
(498), Aster (325), MEXC (197) and Bitvavo (172); Hyperliquid is the only one where a published
address lets you check the cycles yourself. KuCoin is supported by the app, but I have no cycles of
my own there.

Live figures: https://gribbot-btc-usdc.netlify.app

## Bugs and questions

Open an issue here, or write to CryptoBro_Bot_Pro@proton.me

## License and redistribution

CryptoBot Pro is proprietary software. The terms are in LICENSE.txt in this repository and at
https://gribbot-btc-usdc.netlify.app/terms.html

Package maintainers: you may reference CryptoBot Pro in winget, Chocolatey, the AUR or AppImageHub,
as long as the manifest points at the official installer URLs on this releases page. Do not rehost,
repackage or modify the binaries. Write to CryptoBro_Bot_Pro@proton.me if you want that permission
in writing.

## Legal

CryptoBot Pro is a software tool. It is not an investment service and nothing here is financial
advice. A grid strategy can lose money, in particular during a long drawdown.

- Terms of sale and licence: https://gribbot-btc-usdc.netlify.app/terms.html
- Privacy: https://gribbot-btc-usdc.netlify.app/legal.html
