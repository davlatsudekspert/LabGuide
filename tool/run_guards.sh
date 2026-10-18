#!/usr/bin/env bash
# LabGuide: barcha qorovul (guard) qatlamlarini lokal ishga tushiradi —
# CI (`.github/workflows/ci.yml`: tests + worker joblari) bilan bir xil.
#
#   tool/run_guards.sh            # hammasi: Python, Flutter (analyze + test), Worker
#   tool/run_guards.sh --quick    # tez: Python + faqat test/guards + Worker qorovuli
#
# Muhit: FLUTTER (standart: PATH dagi `flutter`, bo'lmasa /root/sdk/flutter/bin/flutter),
# PYTHON (standart: python3). Worker uchun Node.js 22 + npm; node_modules bo'lmasa
# `npm ci` qilinadi (oxirida o'chirilmaydi). Jadval: docs/GUARDS.md.
set -euo pipefail
cd "$(dirname "$0")/.."

QUICK=0
[ "${1:-}" = "--quick" ] && QUICK=1

PY=${PYTHON:-python3}
if [ -n "${FLUTTER:-}" ]; then
  FL=$FLUTTER
elif command -v flutter >/dev/null 2>&1; then
  FL=flutter
else
  FL=/root/sdk/flutter/bin/flutter
fi

step() { printf '\n== %s\n' "$*"; }

step "Python: tool/slides (unittest)"
"$PY" -m unittest discover -s tool/slides -p 'test_*.py'

step "Python: tool/site (check_site + self-test + qorovullar)"
"$PY" tool/site/check_site.py
"$PY" tool/site/check_site.py --self-test
"$PY" -m unittest discover -s tool/site -p 'test_*.py'

step "Python: tool/ai (oflayn testlar)"
"$PY" -m unittest discover -s tool/ai/tests

step "Flutter: pub get"
"$FL" pub get --enforce-lockfile >/dev/null

if [ "$QUICK" = 1 ]; then
  step "Flutter: test/guards"
  "$FL" test test/guards
else
  step "Flutter: analyze"
  "$FL" analyze
  step "Flutter: test (test/guards bilan birga hammasi)"
  "$FL" test
fi

if command -v npm >/dev/null 2>&1; then
  step "Worker (cloudflare/): typecheck + vitest"
  (
    cd cloudflare
    [ -d node_modules ] || npm ci --no-audit --no-fund
    npm run typecheck
    if [ "$QUICK" = 1 ]; then
      npx vitest run test/guards.test.ts
    else
      npm test
    fi
  )
else
  echo "OGOHLANTIRISH: npm topilmadi — Worker qorovullari o'tkazib yuborildi" >&2
fi

step "Barcha qorovullar o'tdi"
