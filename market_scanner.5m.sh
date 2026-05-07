#!/bin/zsh
# <bitbar.title>Market Scanner</bitbar.title>
# <bitbar.version>1.0</bitbar.version>
# <bitbar.author>Gaurav Bajaj</bitbar.author>
# <bitbar.desc>Shows live 4%/day and 20%/week scanner counts from TradingView.</bitbar.desc>
# <bitbar.refreshEvery>5m</bitbar.refreshEvery>

# ── Configuration ──────────────────────────────────────────────────────────────
# Point this to the raw base URL of a Gist containing scanner_counts.json.
# See README for how to generate this file or use the author's public feed.
GIST_BASE_URL="https://gist.githubusercontent.com/gbajaj/75621283a9a38bd1877c89130c88daae/raw"
# ──────────────────────────────────────────────────────────────────────────────

data=$(curl -sf --max-time 10 "${GIST_BASE_URL}/scanner_counts.json" 2>/dev/null)

if [[ -z "$data" ]]; then
  echo "📉 -- | color=gray"
  echo "---"
  echo "Scanner data unavailable"
  exit 0
fi

down=$(echo "$data"   | /usr/bin/python3 -c "import json,sys; d=json.load(sys.stdin); print(d['scanners']['4pct_down']['count'])" 2>/dev/null)
up=$(echo "$data"     | /usr/bin/python3 -c "import json,sys; d=json.load(sys.stdin); print(d['scanners']['4pct_up']['count'])" 2>/dev/null)
up_wk=$(echo "$data"  | /usr/bin/python3 -c "import json,sys; d=json.load(sys.stdin); print(d['scanners']['20pct_up_week']['count'])" 2>/dev/null)
down_wk=$(echo "$data"| /usr/bin/python3 -c "import json,sys; d=json.load(sys.stdin); print(d['scanners']['20pct_down_week']['count'])" 2>/dev/null)
trade_date=$(echo "$data" | /usr/bin/python3 -c "import json,sys; d=json.load(sys.stdin); print(d['trade_date'])" 2>/dev/null)
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

echo "▼${down} ▲${up} | font=Menlo size=12"
echo "---"
echo "${trade_date} | color=gray size=11"
echo "---"
echo "4% Down      ${down} | font=Menlo"
echo "4% Up        ${up} | font=Menlo"
echo "20% Up/Wk    ${up_wk} | font=Menlo"
echo "20% Dn/Wk    ${down_wk} | font=Menlo"
echo "---"
echo "Updated: ${updated_at} | color=gray size=10"
echo "Refresh | refresh=true"
