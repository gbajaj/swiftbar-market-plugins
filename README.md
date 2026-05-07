# SwiftBar Market Plugins

Three macOS menu bar plugins for US equity market monitoring, built on [SwiftBar](https://swiftbar.app).

---

## Plugins

### 📉📈 Market Scanner — `market_scanner.5m.sh`

Live counts from TradingView momentum scanners.

- Stocks up or down **4%+ today**
- Stocks up or down **20%+ this week**

Menu bar shows `▼{down} ▲{up}` at a glance.

**Updated:** every 30 minutes on US trading days, from 6:35 AM PT (pre-market) through 5:00 PM PT (post-market). Not updated on weekends or US market holidays.

---

### 👁 Watchlist — `watchlist.5m.sh`

Active momentum watchlist grouped by recurrence — how many times a symbol has appeared in the 20%+/week scanner.

- Grouped into New / Recurring / High conviction tiers
- Shows week change %, price, and volume spike level per symbol
- Volume icons: 🚀 near 52-week vol high · 📊 significantly elevated · 📈 2× average
- 🚩 flagging status · ✅ triggered

**Updated:** in sync with the market scanner — every 30 minutes on trading days, 6:35 AM – 5:00 PM PT. New symbols are auto-added when they hit the 20%+/week threshold; entries expire after ~10 trading days.

---

### 📅 Earnings Calendar — `earnings.5m.sh`

Upcoming earnings for QQQ components (large-cap Nasdaq stocks), with watchlist symbols highlighted in green.

- Menu bar shows count of earnings in the next 7 days
- Grouped by date with Today / Tomorrow labels
- Market cap sorted within each day
- Watchlist overlap marked with 👁

**Updated:** once daily after 1:00 PM PT on trading days. Shows earnings up to 14 days ahead.

---

## Prerequisites

- macOS (tested on Sonoma / Sequoia)
- [SwiftBar](https://swiftbar.app) — free, open source
- Python 3 — built-in on macOS, no extra packages needed
- `curl` — built-in on macOS

---

## Installation

**1. Install SwiftBar**

Download from [swiftbar.app](https://swiftbar.app) and open it. It will ask you to choose a plugins folder — note that path.

**2. Copy the scripts**

```bash
git clone https://github.com/gbajaj/swiftbar-market-plugins.git
cp swiftbar-market-plugins/*.sh ~/path/to/your/swiftbar/plugins/
```

**3. Make them executable**

```bash
chmod +x ~/path/to/your/swiftbar/plugins/*.sh
```

**4. Configure the Gist URL** (see below)

**5. Reload SwiftBar** — plugins appear in the menu bar automatically.

---

## Configuration

Each script has a single `GIST_BASE_URL` variable near the top:

```sh
# ── Configuration ─────────────────────────────────────────────
GIST_BASE_URL="https://gist.githubusercontent.com/gbajaj/75621283a9a38bd1877c89130c88daae/raw"
# ──────────────────────────────────────────────────────────────
```

### Option A — Use the author's public feed (zero setup)

Leave `GIST_BASE_URL` as-is. The default URL points to a live Gist updated automatically during US market hours (Mon–Fri, roughly 6:30 AM – 5:00 PM PT). No account or API key needed — just install and run.

### Option B — Run your own backend

Point `GIST_BASE_URL` to your own Gist and push JSON files matching the schemas below on whatever schedule you prefer. The scripts only need a reachable Gist URL — the backend can be anything.

---

## Data Format

The plugins read JSON from three files in the Gist. If you want to build your own backend, here are the schemas:

### `scanner_counts.json`

```json
{
  "trade_date": "2026-05-07",
  "updated_at": "2026-05-07T20:35:00Z",
  "scanners": {
    "4pct_down":       { "count": 42 },
    "4pct_up":         { "count": 18 },
    "20pct_up_week":   { "count": 7  },
    "20pct_down_week": { "count": 3  }
  }
}
```

### `watchlist.json`

```json
{
  "updated_at": "2026-05-07T20:35:00Z",
  "stocks": [
    {
      "symbol": "NVDA",
      "price": 118.42,
      "status": "watching",
      "entries": 3,
      "week_change_pct": 22.5,
      "volume_spike": "2x_avg",
      "notes": "+22% week  -8% from 52w high"
    }
  ]
}
```

`status` values: `watching` · `flagging` · `triggered` · `expired` · `stopped`

`volume_spike` values: `52w_high` · `near_52w_high` · `2x_avg` · `normal` · `unknown`

### `earnings.json`

```json
{
  "updated_at": "2026-05-07T20:35:00Z",
  "earnings": [
    {
      "symbol": "AAPL",
      "date": "2026-05-08",
      "price": 211.30,
      "mcap_b": 3180.5
    }
  ]
}
```

---

## Refresh Rate

All scripts are named `*.5m.sh` — SwiftBar reads the filename and refreshes every 5 minutes. Rename to `*.1m.sh` for 1-minute refreshes or `*.15m.sh` for 15-minute refreshes.

---

## Troubleshooting

**Plugin shows `--` or blank**

- Check that `curl` can reach the Gist URL: `curl -sf "https://gist.githubusercontent.com/gbajaj/.../raw/scanner_counts.json"`
- Check the script is executable: `chmod +x market_scanner.5m.sh`
- Open SwiftBar preferences → Refresh All

**Wrong timezone displayed**

The scripts detect DST automatically using the system clock. If your Mac's timezone differs from PT, the displayed time will still be correct local time — just the label (PDT/PST) may not match your zone.

**Permission denied on first run**

macOS may block the script on first run. Go to System Settings → Privacy & Security → scroll down and click Allow.

