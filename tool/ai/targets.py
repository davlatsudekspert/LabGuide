"""`target` kiritmasini (masalan `cytology`, `analyte:alt`, `all-small`) elementlarga aylantirish.

Sintaksis (vergul bilan bir nechta bo'lishi mumkin):
  all | all-small          — barcha sohalardan navbat bilan namunalar (max_items bilan cheklanadi)
  pack                     — analitlar + holatlar (conditions)
  analytes | conditions | quiz | cytology | spermogram | bloodgroup   — butun soha
  analyte:<id> | condition:<id> | quiz:<id> | group:<guruh-id>
  id:<to'liq element id> | contains:<qism>      — element identifikatori bo'yicha
  <repo-nisbiy yo'l>       — `.dart` fayl yoki `assets/content/core/pack.json`
  <so'z>                   — analit/holat/guruh/soha nomi, aks holda element id'sida qism
"""
from __future__ import annotations

import re
from typing import Any

from extract import ALL_DOMAINS, DART_DOMAINS, PACK_DOMAINS, PACK_REL

TARGET_RE = re.compile(r"^[A-Za-z0-9_:.,/#~\-]{1,120}$")
MAX_ITEMS_HARD_CAP = 60
ROUND_ROBIN = ("analytes", "conditions", "cytology", "spermogram", "bloodgroup")
# vazifa -> ruxsat etilgan sohalar
ELIGIBLE: dict[str, tuple[str, ...]] = {
    "content_review": ("analytes", "conditions", "cytology", "spermogram", "bloodgroup", "quiz"),
    "ru_terminology": ("analytes", "conditions", "cytology", "spermogram", "bloodgroup", "quiz"),
    "translate_check": ("analytes", "conditions", "cytology", "spermogram", "bloodgroup", "quiz"),
    "quiz_draft": ("analytes", "cytology", "spermogram", "bloodgroup"),  # manba matn kerak; tayyor testlar emas
}


class TargetError(ValueError):
    pass


def validate_target(target: str) -> str:
    target = (target or "").strip()
    if not TARGET_RE.match(target):
        raise TargetError("target faqat harf/raqam va _ : . , / # ~ - belgilaridan iborat bo'lishi kerak (1..120 belgi)")
    if ".." in target:
        raise TargetError("target ichida '..' bo'lishi mumkin emas")
    return target


def clamp_max_items(value: Any) -> int:
    try:
        n = int(float(value))
    except (TypeError, ValueError) as e:
        raise TargetError(f"max_items son bo'lishi kerak: {value!r}") from e
    if n < 1:
        raise TargetError("max_items kamida 1 bo'lishi kerak")
    return min(n, MAX_ITEMS_HARD_CAP)


def _by_domain(loaded: dict[str, list[dict[str, Any]]], domain: str) -> list[dict[str, Any]]:
    return list(loaded.get(domain, []))


def _all_items(loaded: dict[str, list[dict[str, Any]]]) -> list[dict[str, Any]]:
    return [it for d in ALL_DOMAINS for it in loaded.get(d, [])]


def domains_needed(target: str) -> tuple[str, ...]:
    """Yuklanishi kerak bo'lgan sohalar (keraksiz Dart parsing'dan qochish uchun)."""
    # Aniq soha/yo'l nomi bo'lsa, faqat shu; aks holda hammasi.
    need: set[str] = set()
    for tok in (x.strip() for x in target.split(",") if x.strip()):
        low = tok.lower()
        if low in ("all", "all-small"):
            return ALL_DOMAINS
        if low == "pack":
            need.update(("analytes", "conditions"))
        elif low in ALL_DOMAINS:
            need.add(low)
        elif low.startswith(("analyte:", "group:")):
            need.add("analytes")
        elif low.startswith("condition:"):
            need.add("conditions")
        elif low.startswith("quiz:"):
            need.add("quiz")
        elif "/" in tok or tok.endswith(".dart") or tok.endswith(".json"):
            for dom, files in DART_DOMAINS.items():
                if tok in files:
                    need.add(dom)
            if tok == PACK_REL:
                need.update(("analytes", "conditions"))
        else:
            return ALL_DOMAINS
    return tuple(d for d in ALL_DOMAINS if d in need) or ALL_DOMAINS


def _resolve_token(tok: str, loaded: dict[str, list[dict[str, Any]]]) -> list[dict[str, Any]]:
    low = tok.lower()
    if low in ("all", "all-small"):
        lists = [_by_domain(loaded, d) for d in ROUND_ROBIN]
        out: list[dict[str, Any]] = []
        for i in range(max((len(x) for x in lists), default=0)):
            for lst in lists:
                if i < len(lst):
                    out.append(lst[i])
        return out
    if low == "pack":
        return _by_domain(loaded, "analytes") + _by_domain(loaded, "conditions")
    if low in ALL_DOMAINS:
        return _by_domain(loaded, low)
    prefix, _, rest = tok.partition(":")
    pl = prefix.lower()
    if rest and pl in ("analyte", "condition", "quiz"):
        wanted = f"{pl}:{rest}"
        return [it for it in _all_items(loaded) if it["id"].lower() == wanted.lower()]
    if rest and pl == "group":
        return [it for it in _by_domain(loaded, "analytes") if (it.get("group") or "").lower() == rest.lower()]
    if rest and pl == "id":
        return [it for it in _all_items(loaded) if it["id"] == rest]
    if rest and pl == "contains":
        return [it for it in _all_items(loaded) if rest.lower() in it["id"].lower()]
    if "/" in tok or tok.endswith((".dart", ".json")):
        for dom, files in DART_DOMAINS.items():
            if tok in files:
                return [it for it in _by_domain(loaded, dom) if it["origin"].startswith(tok)]
        if tok == PACK_REL:
            return _by_domain(loaded, "analytes") + _by_domain(loaded, "conditions")
        raise TargetError(f"fayl qo'llab-quvvatlanmaydi: {tok}")
    # oddiy so'z
    for dom in ("analytes", "conditions", "quiz"):
        hit = [it for it in _by_domain(loaded, dom) if it["id"].lower() == f"{dom[:-1] if dom != 'quiz' else 'quiz'}:{low}"]
        if hit:
            return hit
    grp = [it for it in _by_domain(loaded, "analytes") if (it.get("group") or "").lower() == low]
    if grp:
        return grp
    return [it for it in _all_items(loaded) if low in it["id"].lower()]


def select_items(
    target: str, task: str, loaded: dict[str, list[dict[str, Any]]], max_items: int
) -> tuple[list[dict[str, Any]], list[str]]:
    """(tanlangan elementlar, izohlar). Hech narsa topilmasa TargetError."""
    target = validate_target(target)
    max_items = clamp_max_items(max_items)
    notes: list[str] = []
    picked: list[dict[str, Any]] = []
    seen: set[str] = set()
    for tok in (x.strip() for x in target.split(",") if x.strip()):
        found = _resolve_token(tok, loaded)
        if not found:
            raise TargetError(f"target bo'yicha hech narsa topilmadi: {tok!r}")
        for it in found:
            if it["id"] not in seen:
                seen.add(it["id"])
                picked.append(it)
    ok = ELIGIBLE[task]
    eligible = [it for it in picked if it["domain"] in ok]
    skipped = len(picked) - len(eligible)
    if skipped:
        notes.append(f"{task} uchun mos kelmagan {skipped} ta element o'tkazib yuborildi (soha: {', '.join(sorted({it['domain'] for it in picked if it['domain'] not in ok}))})")
    if not eligible:
        raise TargetError(f"{task} uchun mos element yo'q")
    if len(eligible) > max_items:
        notes.append(f"{len(eligible)} ta moslardan faqat birinchi {max_items} tasi olindi (max_items)")
        eligible = eligible[:max_items]
    return eligible, notes


__all__ = ["TargetError", "select_items", "validate_target", "clamp_max_items", "domains_needed", "MAX_ITEMS_HARD_CAP", "PACK_DOMAINS"]
