#!/usr/bin/env python3
"""LabGuide AI vazifalari: Claude API orqali ikkinchi fikr (faqat qo'lda ishga tushiriladi).

    python tool/ai/run_task.py --task content_review --target cytology --dry-run
    ANTHROPIC_API_KEY=... python tool/ai/run_task.py --task content_review --target analyte:alt

Natija: docs/ai_reports/<sana>_<vazifa>_<target>.md va .json. Ilova mazmuniga TEGILMAYDI;
hammasi "AI taklifi — odam tekshiruvi shart".

Xavfsizlik: kalit faqat muhit o'zgaruvchisidan o'qiladi, hech qayerga yozilmaydi/chop
etilmaydi; chiqishda kalit namunasi topilsa fayl yozilmaydi. Logda faqat token sonlari.
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import re
import sys
from pathlib import Path
from typing import Any, Callable

sys.path.insert(0, str(Path(__file__).resolve().parent))

import budget as budget_mod  # noqa: E402
import extract  # noqa: E402
import llm as llm_mod  # noqa: E402
import prompt_builder  # noqa: E402
import schemas  # noqa: E402
import targets  # noqa: E402

REPO_ROOT = Path(__file__).resolve().parents[2]
MODELS = ("claude-sonnet-5-5", "claude-opus-5-5")
OPUS_TASKS = ("content_review",)
DEFAULT_BUDGET_USD = 3.0
MAX_CONSECUTIVE_FAILURES = 3
DISCLAIMER = (
    "**AI taklifi — odam tekshiruvi shart.** Bu hisobot Claude modeli tomonidan tuzilgan ikkinchi fikr. "
    "Model manba hujjatlarini KO'RMAYDI (faqat ilova matni va havola ma'lumotlari), shuning uchun xulosalar "
    "tasdiqlangan haqiqat emas. Ilova mazmuni o'zgartirilmagan. / "
    "AI suggestions only - human review required. The model did not see the source documents; no app "
    "content was changed."
)
SEV_ORDER = {"critical": 0, "major": 1, "minor": 2, "info": 3}


class ArgError(ValueError):
    pass


# --------------------------------------------------------------------------
# Argumentlar
# --------------------------------------------------------------------------
def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--task", required=True, choices=prompt_builder.TASKS)
    p.add_argument("--target", required=True)
    p.add_argument("--model", default="claude-sonnet-5-5")
    p.add_argument("--max-items", default="20")
    p.add_argument("--budget-usd", default=str(DEFAULT_BUDGET_USD))
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--effort", default="medium", choices=["low", "medium", "high"])
    p.add_argument("--options", type=int, default=prompt_builder.DEFAULT_OPTIONS, choices=[3, 4],
                   help="quiz_draft: variantlar soni (spetsifikatsiya 4; ilovadagi testlarda hozir 3)")
    p.add_argument("--max-tokens", type=int, default=0, help="javob chegarasini qo'lda belgilash (0 = vazifa standarti)")
    p.add_argument("--date", default="", help="YYYY-MM-DD (standart: bugun, UTC)")
    p.add_argument("--out-dir", default="docs/ai_reports")
    p.add_argument("--root", default=str(REPO_ROOT))
    return p


def validate_args(ns: argparse.Namespace) -> argparse.Namespace:
    try:
        ns.target = targets.validate_target(ns.target)
        ns.max_items = targets.clamp_max_items(ns.max_items)
    except targets.TargetError as e:
        raise ArgError(str(e)) from e
    if ns.model not in MODELS:
        raise ArgError(f"model ruxsat etilganlardan emas: {ns.model!r} (ruxsat: {', '.join(MODELS)})")
    if ns.model == "claude-opus-5-5" and ns.task not in OPUS_TASKS:
        raise ArgError("claude-opus-5-5 faqat content_review uchun ruxsat etilgan")
    try:
        ns.budget_usd = float(ns.budget_usd)
    except ValueError as e:
        raise ArgError(f"budget_usd son bo'lishi kerak: {ns.budget_usd!r}") from e
    if not (0 < ns.budget_usd <= budget_mod.MAX_BUDGET_USD):
        raise ArgError(f"budget_usd 0 dan katta va {budget_mod.MAX_BUDGET_USD} dan oshmasligi kerak")
    if ns.date and not re.fullmatch(r"\d{4}-\d{2}-\d{2}", ns.date):
        raise ArgError("date YYYY-MM-DD ko'rinishida bo'lishi kerak")
    if ns.max_tokens < 0 or ns.max_tokens > 32000:
        raise ArgError("max_tokens 0..32000 oralig'ida bo'lishi kerak")
    # chiqish papkasi faqat repo ichida bo'lishi mumkin
    root = Path(ns.root).resolve()
    out = (root / ns.out_dir).resolve()
    if root != out and root not in out.parents:
        raise ArgError("out-dir repo ichida bo'lishi kerak")
    ns.out_path = out
    ns.root_path = root
    return ns


def slug(text: str, n: int = 50) -> str:
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")[:n].strip("-") or "x"


# --------------------------------------------------------------------------
# Hisobot
# --------------------------------------------------------------------------
def _cell(v: Any) -> str:
    return str(v if v is not None else "").replace("|", "\\|").replace("\n", " ").strip()


def _table(headers: list[str], rows: list[list[Any]]) -> str:
    out = ["| " + " | ".join(headers) + " |", "|" + "|".join("---" for _ in headers) + "|"]
    out += ["| " + " | ".join(_cell(c) for c in r) + " |" for r in rows]
    return "\n".join(out)


def render_item_md(task: str, rec: dict[str, Any]) -> str:
    head = f"### `{rec['item_id']}` — {_cell(rec.get('title'))}\n\n_{rec.get('origin', '')}_ · tokens in/out: {rec['tokens_in']}/{rec['tokens_out']}\n"
    if not rec["ok"]:
        return head + f"\n**Xato / error:** {_cell(rec.get('error'))}\n"
    r = rec["result"]
    body = ""
    if task == "content_review":
        fs = sorted(r.get("findings", []), key=lambda f: SEV_ORDER.get(f["severity"], 9))
        if fs:
            body = _table(
                ["severity", "category", "field / lang", "quote", "reason", "what to check"],
                [[f["severity"], f["category"], f"{f['field']} / {f['language']}",
                  f["quote"] + ("" if f.get("quote_verified") else " (!) quote not found in item"),
                  f["reason"], f["what_to_check"]] for f in fs],
            )
        else:
            body = "No findings."
    elif task == "ru_terminology":
        ss = r.get("suggestions", [])
        body = _table(["field", "original", "suggested", "confidence", "basis", "issue / rationale"],
                      [[s["field"], s["original_term"], s["suggested_term"], s["confidence"], s["basis"],
                        f"{s['issue']} {s['rationale']}"] for s in ss]) if ss else "No suggestions."
    elif task == "translate_check":
        ms = sorted(r.get("mismatches", []), key=lambda m: SEV_ORDER.get(m["severity"], 9))
        body = _table(["severity", "type", "field", "uz", "ru", "en", "explanation"],
                      [[m["severity"], m["type"], m["field"], m["quote_uz"], m["quote_ru"], m["quote_en"],
                        m["explanation"]] for m in ms]) if ms else "No mismatches."
    elif task == "quiz_draft":
        qs = r.get("questions", [])
        parts = []
        for q in qs:
            opts = "\n".join(
                f"  {'**' if i == q['correct_index'] else ''}{chr(65 + i)}. {q['options'][i]['text']['en']}"
                f"{'** (correct)' if i == q['correct_index'] else ''}" for i in range(len(q["options"])))
            parts.append(f"- **{q['id']}** (status: ai_draft) - {q['prompt']['en']}\n{opts}\n"
                         f"  - support ({q['ai_support']['lang']}, {q['ai_support']['field']}): \"{_cell(q['ai_support']['quote'])}\"")
        body = "\n".join(parts) if parts else f"No questions. {_cell(r.get('skipped_reason'))}"
        if r.get("rejected"):
            body += f"\n\n_{len(r['rejected'])} draft(s) rejected by local checks: " + "; ".join(
                _cell(x.get("reject_reason")) for x in r["rejected"]) + "_"
    summ = r.get("summary")
    return head + "\n" + body + (f"\n\n_Summary: {_cell(summ)}_" if summ else "") + "\n"


def render_markdown(meta: dict[str, Any], records: list[dict[str, Any]]) -> str:
    task = meta["task"]
    lines = [
        f"# AI report: {task} / {meta['target']} ({meta['date']})",
        "",
        DISCLAIMER,
        "",
        _table(["key", "value"], [
            ["model", meta["model"]], ["status", meta["status"]],
            ["items selected / done / failed / skipped (budget)",
             f"{meta['items_selected']} / {meta['items_done']} / {meta['items_failed']} / {meta['items_skipped_budget']}"],
            ["tokens in / out", f"{meta['tokens_in']} / {meta['tokens_out']}"],
            ["estimated cost (USD) / cap", f"{meta['cost_usd']:.4f} / {meta['budget_cap_usd']}"],
            ["workflow run", meta.get("run_url") or "-"],
        ]),
        "",
    ]
    for n in meta.get("notes", []):
        lines.append(f"- {n}")
    lines.append("")
    lines += [render_item_md(task, r) for r in records]
    return "\n".join(lines).rstrip() + "\n"


# --------------------------------------------------------------------------
# Asosiy oqim
# --------------------------------------------------------------------------
def post_process(task: str, item: dict[str, Any], data: dict[str, Any], n_options: int) -> dict[str, Any]:
    if task == "content_review":
        return schemas.annotate_content_review(data, item)
    if task == "quiz_draft":
        ok, bad = schemas.check_quiz(data, item, n_options)
        return {
            "questions": [schemas.to_repo_quiz(q, item, i + 1) for i, q in enumerate(ok)],
            "rejected": bad,
            "skipped_reason": data.get("skipped_reason", ""),
        }
    return data


def plan(ns: argparse.Namespace, loaded: dict[str, list[dict[str, Any]]]):
    items, notes = targets.select_items(ns.target, ns.task, loaded, ns.max_items)
    system = prompt_builder.build_system(ns.task, ns.options)
    max_tokens = ns.max_tokens or prompt_builder.MAX_TOKENS[ns.task]
    rows = []
    for it in items:
        user = prompt_builder.build_user(ns.task, it)
        rows.append({"item": it, "user": user,
                     "est_in": budget_mod.estimate_tokens(system) + budget_mod.estimate_tokens(user)})
    return items, notes, system, max_tokens, rows


def dry_run_report(ns: argparse.Namespace, notes: list[str], rows: list[dict[str, Any]], max_tokens: int) -> str:
    typical_out = min(max_tokens, 2500)
    tot_in = sum(r["est_in"] for r in rows)
    typ = budget_mod.cost_usd(ns.model, tot_in, typical_out * len(rows))
    worst = budget_mod.cost_usd(ns.model, tot_in, max_tokens * len(rows))
    lines = [
        f"# DRY RUN - {ns.task} / {ns.target} ({ns.model})",
        "",
        "Hech qanday API chaqiruvi qilinmadi. / No API call was made.",
        "",
        _table(["#", "item id", "domain", "chars sent", "est. input tokens"],
               [[i + 1, r["item"]["id"], r["item"]["domain"], len(r["user"]), r["est_in"]] for i, r in enumerate(rows)]),
        "",
        f"- items: {len(rows)} (max_items={ns.max_items})",
        f"- estimated input tokens: {tot_in}",
        f"- estimated cost: ~${typ:.2f} typical (output ~{typical_out} tokens/item), up to ${worst:.2f} worst case "
        f"(output = max_tokens={max_tokens}/item). Cap for the real run: ${ns.budget_usd:.2f} (stops early).",
    ]
    lines += [f"- {n}" for n in notes]
    lines.append("- Token estimate is a rough character-based estimate; real usage is billed from API usage counts.")
    return "\n".join(lines) + "\n"


def write_summary(text: str, env: dict[str, str]) -> None:
    path = env.get("GITHUB_STEP_SUMMARY")
    if path:
        with open(path, "a", encoding="utf-8") as f:
            f.write(text + "\n")


def run(
    argv: list[str] | None = None,
    env: dict[str, str] | None = None,
    client_factory: Callable[[str], Any] | None = None,
    sleep: Callable[[float], None] | None = None,
    log: Callable[[str], None] = print,
) -> int:
    env = dict(os.environ) if env is None else env
    try:
        ns = validate_args(build_parser().parse_args(argv))
    except ArgError as e:
        log(f"XATO: {e}")
        return 2
    key = llm_mod.api_key_from_env(env)  # dry-run'da ham o'qiladi, lekin ISHLATILMAYDI

    try:
        loaded = extract.load_all(ns.root_path, targets.domains_needed(ns.target))
        items, notes, system, max_tokens, rows = plan(ns, loaded)
    except (targets.TargetError, OSError, KeyError, ValueError) as e:
        log(f"XATO: {llm_mod.redact(str(e), key)}")
        return 2

    if ns.dry_run:
        text = dry_run_report(ns, notes, rows, max_tokens)
        log(text)
        write_summary(text, env)
        return 0

    if not key:
        log("XATO: ANTHROPIC_API_KEY topilmadi (repo secret sifatida saqlangan bo'lishi va workflow'da "
            "env orqali berilishi kerak). API chaqirilmadi. / ANTHROPIC_API_KEY is missing; no API call was made.")
        return 3

    bud = budget_mod.Budget(ns.budget_usd, ns.model)
    client = (client_factory or llm_mod.make_client)(key)
    kw: dict[str, Any] = {"effort": ns.effort, "api_key": key, "log": log}
    if sleep:
        kw["sleep"] = sleep
    client_llm = llm_mod.LLM(client, ns.model, **kw)
    schema = schemas.SCHEMAS[ns.task]
    if ns.task == "quiz_draft":
        schema = schemas.quiz_draft_schema()

    records: list[dict[str, Any]] = []
    stopped_for_budget = False
    fatal = False
    consecutive_fail = 0
    for i, row in enumerate(rows):
        item = row["item"]
        if stopped_for_budget or fatal or consecutive_fail >= MAX_CONSECUTIVE_FAILURES:
            records.append({"item_id": item["id"], "title": item["title"].get("en", ""), "origin": item["origin"],
                            "ok": False, "error": "o'tkazib yuborildi" if not stopped_for_budget else "skipped: budget cap",
                            "skipped": "budget" if stopped_for_budget else "aborted", "tokens_in": 0, "tokens_out": 0})
            continue
        if not bud.can_afford(row["est_in"], max_tokens):
            stopped_for_budget = True
            log(f"BUDGET: keyingi chaqiruv byudjetdan oshadi (sarf ${bud.spent_usd:.4f} / ${bud.cap_usd:.2f}); to'xtatildi")
            records.append({"item_id": item["id"], "title": item["title"].get("en", ""), "origin": item["origin"],
                            "ok": False, "error": "skipped: budget cap", "skipped": "budget", "tokens_in": 0, "tokens_out": 0})
            continue
        reply = client_llm.call(system, row["user"], schema, max_tokens)
        cost = bud.record(reply.in_tokens, reply.out_tokens) if (reply.in_tokens or reply.out_tokens) else 0.0
        rec: dict[str, Any] = {"item_id": item["id"], "title": item["title"].get("en", ""), "origin": item["origin"],
                               "tokens_in": reply.in_tokens, "tokens_out": reply.out_tokens,
                               "cost_usd": round(cost, 6), "attempts": reply.attempts}
        if reply.ok and reply.parsed is not None:
            errs = schemas.validate(reply.parsed, schema)
            if errs:
                rec.update(ok=False, error="sxemaga mos emas: " + "; ".join(errs[:3]))
            else:
                rec.update(ok=True, result=post_process(ns.task, item, reply.parsed, ns.options))
        else:
            rec.update(ok=False, error=reply.error)
        fatal = fatal or reply.fatal
        consecutive_fail = 0 if rec["ok"] else consecutive_fail + 1
        records.append(rec)
        # faqat sonlar:
        log(f"[{i + 1}/{len(rows)}] {item['id']} ok={rec['ok']} in={reply.in_tokens} out={reply.out_tokens} "
            f"spent=${bud.spent_usd:.4f}/${bud.cap_usd:.2f}")

    done = sum(1 for r in records if r["ok"])
    skipped = sum(1 for r in records if r.get("skipped") == "budget")
    aborted = sum(1 for r in records if r.get("skipped") == "aborted")
    failed = len(records) - done - skipped - aborted
    status = "complete" if done == len(records) else ("failed" if done == 0 else "partial")
    date = ns.date or dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%d")
    run_url = ""
    if env.get("GITHUB_RUN_ID") and env.get("GITHUB_REPOSITORY"):
        run_url = f"{env.get('GITHUB_SERVER_URL', 'https://github.com')}/{env['GITHUB_REPOSITORY']}/actions/runs/{env['GITHUB_RUN_ID']}"
    meta = {
        "task": ns.task, "target": ns.target, "model": ns.model, "effort": ns.effort, "date": date,
        "generated_at": dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "status": status, "review_status": "ai_suggestions_unreviewed",
        "items_selected": len(records), "items_done": done, "items_failed": failed, "items_skipped_budget": skipped,
        "items_aborted": aborted,
        "tokens_in": bud.in_tokens, "tokens_out": bud.out_tokens, "cost_usd": round(bud.spent_usd, 6),
        "budget_cap_usd": ns.budget_usd, "max_tokens": max_tokens, "run_url": run_url,
        "prices_usd_per_mtok": {"input": budget_mod.PRICES[ns.model][0], "output": budget_mod.PRICES[ns.model][1]},
        "notes": notes + (["Byudjet chegarasi tufayli to'xtatildi / stopped at budget cap"] if stopped_for_budget else [])
                 + (["Kalit/ruxsat xatosi tufayli to'xtatildi / aborted on auth error"] if fatal else []),
    }
    md = render_markdown(meta, records)
    js = json.dumps({"meta": meta, "disclaimer": DISCLAIMER, "results": records}, ensure_ascii=False, indent=1) + "\n"
    for blob in (md, js):
        if llm_mod.SECRET_RE.search(blob) or key in blob:
            log("XATO: chiqishda kalitga o'xshash matn topildi - fayl YOZILMADI.")
            return 4
    base = f"{date}_{ns.task}_{slug(ns.target)}"
    ns.out_path.mkdir(parents=True, exist_ok=True)
    k = 1
    while (ns.out_path / f"{base}{'' if k == 1 else f'_r{k}'}.json").exists():
        k += 1
    base = base if k == 1 else f"{base}_r{k}"
    (ns.out_path / f"{base}.md").write_text(md, encoding="utf-8")
    (ns.out_path / f"{base}.json").write_text(js, encoding="utf-8")
    summary = (f"## ai_tasks: {ns.task} / {ns.target}\n\n- status: **{status}**; items {done}/{len(records)} ok, "
               f"{failed} failed, {skipped} skipped\n- tokens in/out: {bud.in_tokens}/{bud.out_tokens}; "
               f"cost ~${bud.spent_usd:.4f} of ${ns.budget_usd:.2f}\n- report: `{ns.out_path.name}/{base}.md`")
    log(summary)
    write_summary(summary, env)
    return 0 if done > 0 else 1


if __name__ == "__main__":
    sys.exit(run())
