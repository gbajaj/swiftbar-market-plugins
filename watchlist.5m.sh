#!/bin/zsh
# <bitbar.title>Market Watchlist</bitbar.title>
# <bitbar.version>1.0</bitbar.version>
# <bitbar.author>Gaurav Bajaj</bitbar.author>
# <bitbar.desc>Shows active watchlist from TradingView momentum scanner.</bitbar.desc>
# <bitbar.refreshEvery>5m</bitbar.refreshEvery>

# ── Configuration ──────────────────────────────────────────────────────────────
# Point this to the raw base URL of a Gist containing watchlist.json.
# See README for how to generate this file or use the author's public feed.
GIST_BASE_URL="https://gist.githubusercontent.com/gbajaj/75621283a9a38bd1877c89130c88daae/raw"
# ──────────────────────────────────────────────────────────────────────────────

data=$(curl -sf --max-time 10 "${GIST_BASE_URL}/watchlist.json" 2>/dev/null)

if [[ -z "$data" ]]; then
  echo "👁 -- | color=gray"
  echo "---"
  echo "Watchlist unavailable"
  exit 0
fi

count=$(echo "$data" | /usr/bin/python3 -c "
import json, sys
d = json.load(sys.stdin)
print(len(d.get('stocks', [])))
" 2>/dev/null)

updated_at=$(echo "$data" | /usr/bin/python3 -c "
import json, sys, time
from datetime import datetime, timezone, timedelta
d = json.load(sys.stdin)
raw = d.get('updated_at', '')
try:
    dt = datetime.fromisoformat(raw.replace('Z', '+00:00'))
    is_dst = time.daylight and time.localtime().tm_isdst
    offset = timedelta(hours=-7) if is_dst else timedelta(hours=-8)
    label = 'PDT' if is_dst else 'PST'
    local = dt.astimezone(timezone(offset))
    print(local.strftime('%-I:%M %p') + ' ' + label)
except Exception:
    print(raw)
" 2>/dev/null)

echo "👁 ${count} | font=Menlo size=12"
echo "---"
echo "Watchlist — ${count} stocks | color=gray size=11"
echo "Updated: ${updated_at} | color=gray size=10"
echo "---"

echo "$data" | /usr/bin/python3 -c "
import json, sys
d = json.load(sys.stdin)
stocks = sorted(d.get('stocks', []), key=lambda x: (-x.get('entries', 1), -(x.get('week_change_pct') or 0)))

VOL_ICONS = {
    '52w_high':      '🚀',
    'near_52w_high': '📊',
    '2x_avg':        '📈',
    'normal':        '  ',
    'unknown':       '  ',
}

prev_entries = None
for s in stocks:
    entries = s.get('entries', 1)
    symbol = s['symbol']
    price = s.get('price', 0)
    status = s.get('status', 'watching')
    week_chg = s.get('week_change_pct')
    vol_spike = s.get('volume_spike', 'unknown')
    notes = s.get('notes', '')

    if entries != prev_entries:
        label = '🔥 High conviction' if entries >= 5 else ('📈 Recurring' if entries >= 2 else '🆕 New')
        print(f'-- {label} ({entries}×) | color=gray size=10')
        prev_entries = entries

    status_icon = '🚩' if status == 'flagging' else ('✅' if status == 'triggered' else '·')
    vol_icon = VOL_ICONS.get(vol_spike, '  ')
    week_str = f'{week_chg:+.0f}%' if week_chg is not None else '   '
    line = f'{status_icon} {symbol:<6} {week_str:>5}  \${price:.2f}  {vol_icon} {entries}× | font=Menlo size=11'
    if notes:
        line += f' tooltip={notes}'
    print(line)
" 2>/dev/null

echo "---"
echo "Refresh | refresh=true"
