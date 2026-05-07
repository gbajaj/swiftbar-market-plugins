#!/bin/zsh
# <bitbar.title>QQQ Earnings Calendar</bitbar.title>
# <bitbar.version>1.0</bitbar.version>
# <bitbar.author>Gaurav Bajaj</bitbar.author>
# <bitbar.desc>Shows upcoming earnings for QQQ components, with watchlist stocks highlighted.</bitbar.desc>
# <bitbar.refreshEvery>5m</bitbar.refreshEvery>

# ── Configuration ──────────────────────────────────────────────────────────────
# Point this to the raw base URL of a Gist containing earnings.json and watchlist.json.
# See README for how to generate these files or use the author's public feed.
GIST_BASE_URL="https://gist.githubusercontent.com/gbajaj/75621283a9a38bd1877c89130c88daae/raw"
# ──────────────────────────────────────────────────────────────────────────────

data_raw=$(curl -sf --max-time 10 "${GIST_BASE_URL}/earnings.json" 2>/dev/null)
wl_raw=$(curl -sf --max-time 10 "${GIST_BASE_URL}/watchlist.json" 2>/dev/null)

if [[ -z "$data_raw" ]]; then
  echo "📅 -- | color=gray"
  exit 0
fi

export EARNINGS_DATA="$data_raw"
export WATCHLIST_DATA="$wl_raw"

/usr/bin/python3 - <<'PYEOF'
import json, sys, os
from datetime import date, timedelta
from collections import defaultdict

data_raw = os.environ.get('EARNINGS_DATA', '')
wl_raw = os.environ.get('WATCHLIST_DATA', '')

try:
    data = json.loads(data_raw)
    earnings = data.get('earnings', [])
except Exception:
    print("📅 -- | color=gray")
    sys.exit(0)

wl_symbols = set()
try:
    wl = json.loads(wl_raw)
    wl_symbols = {s['symbol'] for s in wl.get('stocks', [])}
except Exception:
    pass

today = date.today()
week_end = today + timedelta(days=7)

this_week = [e for e in earnings
             if today.isoformat() <= e['date'] <= week_end.isoformat()]

count = len(this_week)
print(f"📅 {count}" if count > 0 else "📅 -- | color=gray")
print("---")

updated = data.get('updated_at', '')[:10]
print(f"Earnings Calendar | color=gray size=11")
print(f"Updated: {updated} | color=gray size=10")
print("---")

if not earnings:
    print("No upcoming earnings")
    sys.exit(0)

by_date = defaultdict(list)
for e in earnings:
    by_date[e['date']].append(e)

day_labels = {
    today.isoformat(): '📌 Today',
    (today + timedelta(days=1)).isoformat(): '⏭ Tomorrow',
}

for d in sorted(by_date.keys()):
    label = day_labels.get(d, d)
    entries = sorted(by_date[d], key=lambda x: -x['mcap_b'])
    print(f"{label} ({len(entries)}) | color=gray size=11")
    for e in entries:
        sym = e['symbol']
        mcap = e['mcap_b']
        price = e['price']
        wl_mark = ' 👁' if sym in wl_symbols else ''
        size = 12 if mcap >= 100 else 11
        color = '#00cc44' if sym in wl_symbols else 'white'
        print(f"-- {sym:<7} ${price:<8.2f} ${mcap}B{wl_mark} | font=Menlo size={size} color={color}")

PYEOF
