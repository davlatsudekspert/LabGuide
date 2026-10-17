"""So'rov matnlarini qurish (tarmoqsiz): tizim prompti + element ko'rinishi (JSON)."""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

TASKS = ("content_review", "ru_terminology", "quiz_draft", "translate_check")
PROMPT_DIR = Path(__file__).resolve().parent / "prompts"
DEFAULT_OPTIONS = 4
# Task bo'yicha standart max_tokens (fikrlash tokenlari ham shu chegaraga kiradi).
MAX_TOKENS = {"content_review": 8000, "ru_terminology": 5000, "quiz_draft": 9000, "translate_check": 6000}


def read_prompt(name: str) -> str:
    return (PROMPT_DIR / f"{name}.md").read_text(encoding="utf-8").strip()


def build_system(task: str, n_options: int = DEFAULT_OPTIONS) -> str:
    if task not in TASKS:
        raise ValueError(f"noma'lum vazifa: {task}")
    body = read_prompt(task).replace("{{N_OPTIONS}}", str(n_options))
    return read_prompt("_common") + "\n\n" + body


def _texts(item: dict[str, Any], langs: tuple[str, ...], with_refs: bool) -> list[dict[str, Any]]:
    out = []
    for t in item.get("texts", []):
        row: dict[str, Any] = {"field": t["field"]}
        for lang in langs:
            row[lang] = t.get(lang, "")
        if t.get("templated"):
            row["templated"] = True
        if with_refs and t.get("refs"):
            row["refs"] = t["refs"]
        out.append(row)
    return out


def item_view(task: str, item: dict[str, Any]) -> dict[str, Any]:
    """Vazifaga kerakli maydonlargina — ortiqcha ma'lumot yuborilmaydi."""
    base: dict[str, Any] = {"item_id": item["id"], "domain": item["domain"]}
    if task == "content_review":
        view = {**base, "title": item.get("title", {}), "texts": _texts(item, ("uz", "ru", "en"), True)}
        if item.get("refs"):
            view["refs"] = item["refs"]
        if item.get("facts"):
            view["facts"] = item["facts"]
        return view
    if task == "ru_terminology":
        return {**base, "title": {k: item.get("title", {}).get(k, "") for k in ("ru", "en")}, "texts": _texts(item, ("ru", "en"), False)}
    if task == "translate_check":
        return {**base, "title": item.get("title", {}), "texts": _texts(item, ("uz", "ru", "en"), False)}
    if task == "quiz_draft":
        return {**base, "title": item.get("title", {}), "texts": _texts(item, ("uz", "ru", "en"), False)}
    raise ValueError(f"noma'lum vazifa: {task}")


def build_user(task: str, item: dict[str, Any]) -> str:
    payload = json.dumps(item_view(task, item), ensure_ascii=False, indent=1)
    # element ichidagi yopuvchi teg orqali "chiqib ketish"ning oldini olish
    payload = payload.replace("</item_json>", "<\\/item_json>")
    return f"<item_json>\n{payload}\n</item_json>"
