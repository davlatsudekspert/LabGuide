"""Model javoblari uchun qat'iy JSON-sxemalar va oflayn tekshiruv.

API'ga yuboriladigan sxemalar faqat tarmoq tomonidan qo'llab-quvvatlanadigan
oddiy kalitlardan iborat (type/properties/required/items/enum/additionalProperties).
Qo'shimcha (semantik) tekshiruvlar — kodda: iqtibos matnda bormi, variantlar soni va h.k.
"""
from __future__ import annotations

import re
from typing import Any

LANGS = ("uz", "ru", "en")
SEVERITIES = ["info", "minor", "major", "critical"]
LANG_OR_ALL = ["uz", "ru", "en", "all"]


def _s() -> dict[str, Any]:
    return {"type": "string"}


def _obj(props: dict[str, Any]) -> dict[str, Any]:
    return {"type": "object", "properties": props, "required": list(props), "additionalProperties": False}


def _arr(items: dict[str, Any]) -> dict[str, Any]:
    return {"type": "array", "items": items}


LOCALIZED = _obj({lang: _s() for lang in LANGS})

CONTENT_REVIEW = _obj(
    {
        "findings": _arr(
            _obj(
                {
                    "field": _s(),
                    "language": {"type": "string", "enum": LANG_OR_ALL},
                    "category": {
                        "type": "string",
                        "enum": [
                            "numeric_unit",
                            "translation_inconsistency",
                            "overclaim",
                            "missing_caveat",
                            "cannot_verify",
                        ],
                    },
                    "severity": {"type": "string", "enum": SEVERITIES},
                    "quote": _s(),
                    "reason": _s(),
                    "what_to_check": _s(),
                }
            )
        ),
        "summary": _s(),
    }
)

RU_TERMINOLOGY = _obj(
    {
        "suggestions": _arr(
            _obj(
                {
                    "field": _s(),
                    "original_term": _s(),
                    "issue": _s(),
                    "suggested_term": _s(),
                    "basis": {
                        "type": "string",
                        "enum": ["common_clinical_lab_usage", "iso_15189_style_wording", "unsure"],
                    },
                    "confidence": {"type": "string", "enum": ["low", "medium", "high"]},
                    "rationale": _s(),
                }
            )
        ),
        "summary": _s(),
    }
)

TRANSLATE_CHECK = _obj(
    {
        "mismatches": _arr(
            _obj(
                {
                    "field": _s(),
                    "type": {
                        "type": "string",
                        "enum": [
                            "meaning_difference",
                            "number_or_unit_mismatch",
                            "omission",
                            "addition",
                            "terminology",
                            "strength_of_claim",
                            "other",
                        ],
                    },
                    "severity": {"type": "string", "enum": SEVERITIES},
                    "quote_uz": _s(),
                    "quote_ru": _s(),
                    "quote_en": _s(),
                    "explanation": _s(),
                }
            )
        ),
        "summary": _s(),
    }
)


def quiz_draft_schema() -> dict[str, Any]:
    question = _obj(
        {
            "source_field": _s(),
            "support_lang": {"type": "string", "enum": list(LANGS)},
            "support_quote": _s(),
            "prompt": LOCALIZED,
            "options": _arr(_obj({"text": LOCALIZED, "explanation": LOCALIZED})),
            "correct_index": {"type": "integer"},
            "basis": LOCALIZED,
        }
    )
    return _obj({"questions": _arr(question), "skipped_reason": _s()})


SCHEMAS = {
    "content_review": CONTENT_REVIEW,
    "ru_terminology": RU_TERMINOLOGY,
    "translate_check": TRANSLATE_CHECK,
    "quiz_draft": quiz_draft_schema(),
}


def validate(instance: Any, schema: dict[str, Any], path: str = "$") -> list[str]:
    """Kichik JSON-sxema tekshiruvchi (faqat yuqoridagi kalitlar). Xatolar ro'yxatini qaytaradi."""
    errs: list[str] = []
    t = schema.get("type")
    if t == "object":
        if not isinstance(instance, dict):
            return [f"{path}: object kutilgan"]
        props = schema.get("properties", {})
        for k in schema.get("required", []):
            if k not in instance:
                errs.append(f"{path}.{k}: yo'q")
        if schema.get("additionalProperties") is False:
            for k in instance:
                if k not in props:
                    errs.append(f"{path}.{k}: ortiqcha kalit")
        for k, sub in props.items():
            if k in instance:
                errs.extend(validate(instance[k], sub, f"{path}.{k}"))
    elif t == "array":
        if not isinstance(instance, list):
            return [f"{path}: array kutilgan"]
        for i, v in enumerate(instance):
            errs.extend(validate(v, schema["items"], f"{path}[{i}]"))
    elif t == "string":
        if not isinstance(instance, str):
            return [f"{path}: string kutilgan"]
    elif t == "integer":
        if isinstance(instance, bool) or not isinstance(instance, int):
            return [f"{path}: integer kutilgan"]
    if "enum" in schema and instance not in schema["enum"]:
        errs.append(f"{path}: {instance!r} ruxsat etilgan qiymatlardan emas")
    return errs


# --------------------------------------------------------------------------
# Semantik tekshiruvlar
# --------------------------------------------------------------------------
_WS = re.compile(r"\s+")


def norm(s: str) -> str:
    return _WS.sub(" ", s.replace(" ", " ")).strip().casefold()


def _item_texts(item: dict[str, Any]) -> list[tuple[str, str, str]]:
    """(maydon, til, matn) uchliklari."""
    return [(t["field"], lang, t[lang]) for t in item.get("texts", []) for lang in LANGS if isinstance(t.get(lang), str)]


def quote_in_item(item: dict[str, Any], quote: str, lang: str | None = None, field: str | None = None) -> bool:
    q = norm(quote)
    if not q:
        return False
    for f, lg, text in _item_texts(item):
        if lang and lang != "all" and lg != lang:
            continue
        if field and f != field:
            continue
        if q in norm(text):
            return True
    return False


def annotate_content_review(result: dict[str, Any], item: dict[str, Any]) -> dict[str, Any]:
    """Har bir topilmaga `quote_verified` qo'shadi (iqtibos element matnida bormi)."""
    facts_blob = norm(str(item.get("facts", "")))
    for f in result.get("findings", []):
        q = f.get("quote", "")
        ok = quote_in_item(item, q) or (bool(norm(q)) and norm(q) in facts_blob)
        f["quote_verified"] = bool(ok)
    return result


def check_quiz(
    result: dict[str, Any], item: dict[str, Any], n_options: int
) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    """(qabul qilingan, rad etilgan) savollar. Rad etilganlarda `reject_reason` bor."""
    accepted: list[dict[str, Any]] = []
    rejected: list[dict[str, Any]] = []
    for q in result.get("questions", []):
        reason = None
        opts = q.get("options", [])
        if len(opts) != n_options:
            reason = f"variantlar soni {len(opts)}, kerak {n_options}"
        elif not (0 <= q.get("correct_index", -1) < len(opts)):
            reason = "correct_index chegaradan tashqarida"
        elif not quote_in_item(item, q.get("support_quote", ""), q.get("support_lang"), q.get("source_field")):
            reason = "support_quote ko'rsatilgan maydon/tilda so'zma-so'z topilmadi"
        else:
            keys = [norm(o["text"].get("en", "")) for o in opts]
            if len(set(keys)) != len(keys):
                reason = "variantlar takrorlanadi"
            elif any(not all(o[k][lg].strip() for lg in LANGS for k in ("text", "explanation")) for o in opts):
                reason = "variant matni yoki izohi bo'sh"
        if reason:
            rejected.append({**q, "reject_reason": reason})
        else:
            accepted.append(q)
    return accepted, rejected


def to_repo_quiz(q: dict[str, Any], item: dict[str, Any], n: int) -> dict[str, Any]:
    """Savolni repo quiz sxemasiga (assets/content/core/pack.json `quiz`) yaqin shaklda yig'adi.

    `status`/`review_state` = `ai_draft`: ilova bu qiymatni tanimaydi — pack.json'ga
    odam ko'zdan kechirib, qo'lda o'tkazmaguncha yuklanmaydi.
    """
    field_refs: list[dict[str, Any]] = []
    for t in item.get("texts", []):
        if t["field"] == q.get("source_field"):
            field_refs = [{"source_id": r.get("source_id"), "locator": r.get("locator", "")} for r in t.get("refs", [])]
    if not field_refs:
        field_refs = [{"source_id": r.get("source_id"), "locator": r.get("locator", "")} for r in item.get("refs", [])]
    slug = re.sub(r"[^a-z0-9]+", "-", item["id"].lower()).strip("-")[:48]
    return {
        "id": f"aidraft-{slug}-{n}",
        "status": "ai_draft",
        "review_state": "ai_draft",
        "source_ids": sorted({r["source_id"] for r in field_refs if r.get("source_id")}),
        "correct_index": q["correct_index"],
        "prompt": q["prompt"],
        "basis": q["basis"],
        "options": q["options"],
        "refs": field_refs,
        "topic_ids": [item["id"]],
        "ai_support": {"field": q["source_field"], "lang": q["support_lang"], "quote": q["support_quote"]},
    }
