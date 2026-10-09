#!/usr/bin/env bash
# LabGuide backend: migratsiyalar va qabul testlarini LOKAL PostgreSQL'da
# ishga tushiradi (Supabase auth/storage o'rniga supabase/tests/00_*.sql shim).
#
#   tool/backend_test.sh
#
# Vaqtinchalik klaster yaratiladi va oxirida o'chiriladi. Root bo'lsa
# `postgres` foydalanuvchisi nomidan ishlaydi.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)
PGBIN=${PGBIN:-$(ls -d /usr/lib/postgresql/*/bin 2>/dev/null | sort -V | tail -1)}
[ -x "$PGBIN/initdb" ] || { echo "PostgreSQL topilmadi (PGBIN)"; exit 1; }
WORK=$(mktemp -d)
PORT=${PGPORT_TEST:-55432}
RUN=()
if [ "$(id -u)" = 0 ]; then
  chown postgres "$WORK"
  RUN=(runuser -u postgres --)
fi
cleanup() {
  "${RUN[@]}" "$PGBIN/pg_ctl" -D "$WORK/data" -m immediate stop >/dev/null 2>&1 || true
  rm -rf "$WORK"
}
trap cleanup EXIT
"${RUN[@]}" "$PGBIN/initdb" -D "$WORK/data" -U postgres -A trust >/dev/null
"${RUN[@]}" "$PGBIN/pg_ctl" -D "$WORK/data" -o "-p $PORT -k $WORK -c listen_addresses=''" -l "$WORK/log" start >/dev/null
PSQL=("${RUN[@]}" "$PGBIN/psql" -h "$WORK" -p "$PORT" -U postgres -d postgres -v ON_ERROR_STOP=1 -q -X)
"${PSQL[@]}" -f "$ROOT/supabase/tests/00_supabase_shim.sql"
for f in "$ROOT"/supabase/migrations/*.sql; do
  echo "migration: $(basename "$f")"
  "${PSQL[@]}" -f "$f"
done
for f in "$ROOT"/supabase/tests/[1-9]*.sql; do
  echo "test: $(basename "$f")"
  "${PSQL[@]}" -f "$f"
done
echo "backend tests: OK"
