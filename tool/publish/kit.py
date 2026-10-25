"""Renders the publishing kit texts (YouTube / Instagram / metadata / markdown) from topics.py (stdlib).

Pure functions; no I/O except `topic_status`. Nothing is published or uploaded by this code.
"""
import re

import chapters as chapters_mod
from topics import ALIASES
from common import (ABOUT, APP_HEADING, CHAPTERS_HEADING, CREDITS, CREDITS_HEADING, DISCLOSURE_ORDER,
                    DISCLOSURES, DISCLOSURES_EN_EDITION_VOICE, GATES, GET_HEADING, IG_CAPTION_MAX,
                    INTERNAL_LICENCE_NOTES, LANGS, LANG_NAMES, LIMITS_HEADING, OFFLINE, OUT_ROOT,
                    PAID_GATE, PAID_LINE, SAFE_CONTENT_COMMON, SHOWS_HEADING, YT_TAGS_MAX)

HASHTAG_BASE = {
    "en": ["#LabGuide", "#MedicalLaboratory", "#ClinicalLaboratory", "#LabTech", "#MedLabScience", "#LabEducation",
           "#MedicalStudent", "#HealthcareEducation", "#LaboratoryMedicine"],
    "ru": ["#LabGuide", "#лаборатория", "#клиническаялаборатория", "#КДЛ", "#лабораторнаядиагностика", "#лаборант",
           "#студентмедик", "#медицинскоеобразование", "#медицинскаялаборатория"],
    "uz": ["#LabGuide", "#laboratoriya", "#klinikalaboratoriya", "#laborant", "#laboratoriyadiagnostikasi",
           "#tibbiyot", "#tibbiyottalimi", "#talaba", "#tibbiyotkolleji"],
}
IG_CTA = {
    "en": "Link in bio: [[LINK_BIO]]. Save this and share it with a colleague.",
    "ru": "Ссылка в профиле: [[LINK_BIO]]. Сохраните и перешлите коллеге.",
    "uz": "Havola profilda: [[LINK_BIO]]. Saqlab qo‘ying va hamkasbingizga yuboring.",
}
STORE_LINE = "[[LINK_APP_STORE]] · [[LINK_PLAY]]"
THUMB_ALT_TEMPLATE = {
    "en": "LabGuide logo and the title “{headline}”, with a schematic or app visual and the notice “{note}”. "
          "(Draft alt text: compare with the rendered thumbnail before use.)",
    "ru": "Логотип LabGuide и заголовок «{headline}», схематичное или экранное изображение и пометка «{note}». "
          "(Черновик альтернативного текста: сверьте с готовой обложкой.)",
    "uz": "LabGuide logotipi va «{headline}» sarlavhasi, sxematik yoki ilova tasviri hamda «{note}» belgisi. "
          "(Alt-matn qoralamasi: foydalanishdan oldin tayyor muqova bilan solishtiring.)",
}

FILE_PATTERNS = {
    "yt_video": "{id}_{lang}_horizontal.mp4",
    "ig_video": "{id}_{lang}_vertical.mp4",
    "thumb": "{id}_{lang}_thumb_1280x720.jpg",
    "cover": "{id}_{lang}_cover_1080x1920.jpg",
    "srt": "{id}_{lang}.srt",
    "vtt": "{id}_{lang}.vtt",
}


def fname(kind, topic_id, lang):
    return FILE_PATTERNS[kind].format(id=topic_id, lang=lang)


def bullets(items):
    return "\n".join(f"• {x}" for x in items)


def disclosure_lines(lang, edition=None):
    """The four mandatory disclosures, public wording. `edition` = the language of the video edition."""
    edition = edition or lang
    lines = []
    for key in DISCLOSURE_ORDER:
        text = DISCLOSURES[key][lang]
        if key == "voice" and lang == "en" and edition == "en":
            text = DISCLOSURES_EN_EDITION_VOICE
        lines.append(text)
    return lines


def hashtags(topic, lang):
    seen, out = set(), []
    for tag in HASHTAG_BASE[lang] + topic["hashtags_topic"][lang]:
        key = tag.lower()
        if key not in seen:
            seen.add(key)
            out.append(tag)
    return out


def youtube_hashtags(topic, lang):
    """YouTube shows the first three hashtags of a description above the title."""
    tags = hashtags(topic, lang)
    return [tags[0]] + [t for t in topic["hashtags_topic"][lang]][:2]


def youtube_tags(topic, lang):
    seen, out, total = set(), [], 0
    for tag in topic["keywords"][lang] + topic["keywords"]["en"]:
        key = tag.lower()
        if key in seen or len(tag) > 30:
            continue
        add = len(tag) + (2 if out else 0)
        if total + add > YT_TAGS_MAX - 20:
            break
        seen.add(key)
        out.append(tag)
        total += add
    return out


def paid_block(topic, lang):
    return [PAID_LINE[lang]] if topic["tier"] == "paid" else []


def youtube_description(topic, lang, ch=None):
    """Full YouTube description for the `lang` edition. First two lines are the hook."""
    parts = []
    hook = topic["hook"][lang]
    parts.append(f"{hook[0]}\n{hook[1]}")
    parts.append(f"{SHOWS_HEADING[lang]}:\n{bullets(topic['shows'][lang])}")
    if ch and ch.get("chapters"):
        parts.append(f"{CHAPTERS_HEADING[lang]}\n" + "\n".join(chapters_mod.chapter_lines(ch["chapters"], lang)))
    parts.append(f"{APP_HEADING[lang]}:\n{bullets(topic['app'][lang])}")
    if topic["tier"] == "paid":
        parts.append(PAID_LINE[lang])
    parts.append(f"{LIMITS_HEADING[lang]}:\n{bullets(topic['limits'][lang])}")
    about = ABOUT[lang] + (f" {OFFLINE[lang]}" if topic["tier"] == "free" else "")
    parts.append(f"{about}\n{GET_HEADING[lang]}: {STORE_LINE}")
    parts.append("\n".join(disclosure_lines(lang)))
    credits = list(CREDITS[lang])
    if topic.get("sources"):
        credits.append(("Sources: " if lang == "en" else "Источники: " if lang == "ru" else "Manbalar: ")
                       + " ".join(topic["sources"]))
    parts.append(f"{CREDITS_HEADING[lang]}\n{bullets(credits)}")
    parts.append(" ".join(youtube_hashtags(topic, lang)))
    return "\n\n".join(parts)


def instagram_caption(topic, lang):
    """(caption, hashtag_line). The caption already contains the disclosures and the CTA; the hashtag
    line is meant to be pasted at the end of the caption or as the first comment."""
    parts = list(topic["ig"][lang])
    if topic["tier"] == "paid":
        parts.append(PAID_LINE[lang])
    parts.append("\n".join(disclosure_lines(lang)))
    parts.append(IG_CTA[lang])
    return "\n\n".join(parts), " ".join(hashtags(topic, lang))


def instagram_total(topic, lang):
    caption, tags = instagram_caption(topic, lang)
    return len(caption) + 2 + len(tags)


def alt_text(topic, lang, ui=None):
    if topic.get("thumb_alt"):
        return topic["thumb_alt"][lang]
    ui = ui or {}
    headline = ui.get("thumbHeadline") or topic["title"][lang].split(":")[0]
    note = ui.get("illustrative") or DISCLOSURES["illustrative"][lang].rstrip(".")
    return THUMB_ALT_TEMPLATE[lang].format(headline=headline, note=note)


def topic_status(topic, out_root=OUT_ROOT, ready_ids=None):
    """('READY' | 'NOT READY', reason). READY = listed in READY.txt or all rendered files present."""
    base = out_root / topic["id"]
    missing = []
    for lang in LANGS:
        for kind in FILE_PATTERNS:
            if not (base / lang / fname(kind, topic["id"], lang)).is_file():
                missing.append(fname(kind, topic["id"], lang))
    in_ready = ready_ids is not None and topic["id"] in ready_ids
    if not missing:
        return "READY", "all 18 rendered files present" + (" · listed in READY.txt" if in_ready else "")
    if in_ready:
        return "READY", f"listed in READY.txt, but {len(missing)} expected files are missing: re-render"
    if base.is_dir() and any(base.rglob("*.mp4")):
        return "NOT READY", f"rendering in progress or incomplete ({len(missing)} files missing)"
    return "NOT READY", "video not rendered yet"


def read_ready_ids(out_root=OUT_ROOT):
    p = out_root / "READY.txt"
    if not p.is_file():
        return None
    ids = set()
    for line in p.read_text(encoding="utf-8").splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            ids.add(ALIASES.get(line, line))
    return ids


def metadata(topic, ch=None, status=("NOT READY", ""), ui_by_lang=None):
    """JSON-serialisable per-topic metadata (what the packager ships next to the videos)."""
    ui_by_lang = ui_by_lang or {}
    chs = None
    if ch and ch.get("chapters"):
        chs = [{"start_sec": round(c["start"], 2), "timestamp": chapters_mod.fmt_ts(c["start"]),
                "titles": c["titles"], "auto_title": c["auto"]} for c in ch["chapters"]]
    meta = {
        "id": topic["id"],
        "tier": topic["tier"],
        "video_status": status[0],
        "copy_verified_against_final_video": bool(topic["verified"]),
        "review_status": "EXPERT_REVIEW_PENDING",
        "owner_approval": "REQUIRED (nothing is published by the studio)",
        "publish_blocked_until": (["G1", "G2", "G3", "G4", "G5", "G6"] + (["GP"] if topic["tier"] == "paid" else [])),
        "app_path": topic["path"],
        "titles": topic["title"],
        "chapters": chs,
        "chapters_note": (None if chs else (ch or {}).get("reason", "no chapters available")),
        "chapter_problems": (ch or {}).get("problems", []),
        "youtube": {lang: {"title": topic["title"][lang],
                           "description": youtube_description(topic, lang, ch),
                           "tags": youtube_tags(topic, lang),
                           "hashtags": youtube_hashtags(topic, lang),
                           "audio_language": "en",
                           "subtitle_language": lang,
                           "video_file": fname("yt_video", topic["id"], lang),
                           "thumbnail_file": fname("thumb", topic["id"], lang),
                           "captions": [fname("srt", topic["id"], lang), fname("vtt", topic["id"], lang)],
                           "pinned_comment": topic["pinned"][lang],
                           "thumbnail_alt": alt_text(topic, lang, ui_by_lang.get(lang))}
                    for lang in LANGS},
        "instagram": {lang: {"caption": instagram_caption(topic, lang)[0],
                             "hashtags": instagram_caption(topic, lang)[1],
                             "caption_plus_hashtags_chars": instagram_total(topic, lang),
                             "video_file": fname("ig_video", topic["id"], lang),
                             "cover_file": fname("cover", topic["id"], lang),
                             "cover_alt": alt_text(topic, lang, ui_by_lang.get(lang))}
                      for lang in LANGS},
        "credits": {lang: CREDITS[lang] + ([("Sources: " if lang == "en" else "Источники: " if lang == "ru"
                                             else "Manbalar: ") + " ".join(topic["sources"])]
                                            if topic.get("sources") else []) for lang in LANGS},
        "disclosures": {lang: disclosure_lines(lang) for lang in LANGS},
        "next_topics": topic["next"],
        "internal_notes": topic["internal"] + INTERNAL_LICENCE_NOTES,
    }
    if topic["tier"] == "paid":
        meta["paid"] = {**topic["paid"], "public_line": PAID_LINE}
    return meta


# ------------------------------------------------------------------------------ markdown
def fence(text):
    return "```text\n" + text + "\n```"


def render_md(topic, ch, status, ui_by_lang=None):
    ui_by_lang = ui_by_lang or {}
    tid = topic["id"]
    out = []
    ap = out.append
    ap(f"# Publishing kit — `{tid}`")
    ap("")
    ap("<!-- GENERATED by tool/publish/build_kit.py from tool/publish/topics.py: edit topics.py, not this file -->")
    ap("")
    ap("**PROPOSAL / DRAFT TEXT. Nothing is published, uploaded or scheduled by the studio. The owner approves every "
       "text and decides the date after expert review.**")
    ap("")
    ap("| | |")
    ap("|---|---|")
    ap(f"| Video | **{status[0]}** — {status[1]} |")
    ap(f"| Copy status | {'verified against the rendered video, its lines and CLAIMS_AND_EVIDENCE.md' if topic['verified'] else '**DRAFT** — written before the video existed; re-check every sentence against the final `lines.en.json` and `CLAIMS_AND_EVIDENCE.md`, then set `verified=True` in topics.py'} |")
    ap(f"| Tier | {'free (everything described exists in the free app today)' if topic['tier'] == 'free' else '**paid** — Pro feature; NOT live (see gate GP)'} |")
    ap(f"| Review status | EXPERT_REVIEW_PENDING (science), NEEDS_NATIVE_REVIEW (RU/UZ) |")
    ap(f"| App path | {topic['path']['en']} · {topic['path']['ru']} · {topic['path']['uz']} |")
    ap(f"| Language editions | en / ru / uz — each a separate video: English synthetic narration in all three; "
       f"subtitles and on-screen text in the edition's language |")
    ap("")
    ap("## 0. Gates before this topic may be published")
    ap("")
    gates = list(GATES) + ([PAID_GATE] if topic["tier"] == "paid" else [])
    for gid, text in gates:
        ap(f"* **{gid}** — {text}")
    for note in topic["internal"]:
        ap(f"* *Topic note* — {note}")
    ap("")
    ap("Placeholders in the texts below (`[[LINK_APP_STORE]]`, `[[LINK_PLAY]]`, `[[LINK_BIO]]`) are the owner's to fill; "
       "we never invent a link, a store listing or an availability date. No price and no product id appears anywhere.")
    ap("")
    ap("## 1. Titles (≤ 70 characters; no overstatement of what the app does)")
    ap("")
    ap("| Lang | Title | Chars |")
    ap("|---|---|---|")
    for lang in LANGS:
        t = topic["title"][lang]
        ap(f"| {lang.upper()} | {t} | {len(t)} |")
    ap("")
    ap("## 2. YouTube description (the first two lines are the hook shown before “more”)")
    for lang in LANGS:
        ap("")
        label = {"en": "English (main)", "ru": "Русский", "uz": "O‘zbekcha (Latin)"}[lang]
        d = youtube_description(topic, lang, ch)
        ap(f"### 2.{LANGS.index(lang) + 1} {label} — {len(d)} characters (limit 5000)")
        ap("")
        ap(fence(d))
    ap("")
    ap("Upload settings: audio language English; add the edition's SRT as a caption track (the same words are also "
       "burned into the picture: leave captions off by default); category Education; not made for kids; "
       "answer the platform's synthetic-voice question honestly (NEEDS_OWNER_CHECK for the current wording).")
    ap("")
    ap("## 3. Chapters / timestamps")
    ap("")
    if ch and ch.get("chapters"):
        ap(f"Computed from `docs/video/{tid}/storyboard.json` and the English narration timing "
           f"(total {ch['total']:.1f} s). The same timestamps serve all three editions.")
        ap("")
        ap("| Time | EN | RU | UZ |")
        ap("|---|---|---|---|")
        for c in ch["chapters"]:
            ap(f"| {chapters_mod.fmt_ts(c['start'])} | {c['titles']['en']} | {c['titles']['ru']} | {c['titles']['uz']} |")
        if ch["problems"]:
            ap("")
            ap("Chapter notes: " + "; ".join(ch["problems"]) + ".")
    else:
        ap(f"Not available yet: {(ch or {}).get('reason', 'no chapter data')}. They are filled in automatically when "
           f"`docs/video/{tid}/storyboard.json` and the timing manifest exist (re-run `python3 tool/publish/build_kit.py`); "
           f"automatic titles must be edited.")
    ap("")
    ap("## 4. Keywords / tags (YouTube tags field, ≤ 500 characters per edition)")
    ap("")
    for lang in LANGS:
        tags = youtube_tags(topic, lang)
        ap(f"* **{lang.upper()}** ({len(', '.join(tags))} chars): {', '.join(tags)}")
    ap("")
    ap("## 5. Instagram caption (≤ 2200 characters including hashtags; hook first)")
    for lang in LANGS:
        ap("")
        cap, tags = instagram_caption(topic, lang)
        ap(f"### 5.{LANGS.index(lang) + 1} {LANG_NAMES[lang]} — {len(cap)} + hashtags {len(tags)} = {instagram_total(topic, lang)} characters")
        ap("")
        ap(fence(cap))
    ap("")
    ap("## 6. Hashtags (15–25 per language; paste at the end of the caption or as the first comment)")
    ap("")
    for lang in LANGS:
        tags = hashtags(topic, lang)
        ap(f"* **{lang.upper()}** ({len(tags)}): {' '.join(tags)}")
    ap(f"* YouTube (first three, shown above the title): " + " · ".join(
        f"{lang.upper()} {' '.join(youtube_hashtags(topic, lang))}" for lang in LANGS))
    ap("")
    ap("## 7. Pinned comment")
    for lang in LANGS:
        ap("")
        ap(f"**{lang.upper()}**")
        ap("")
        ap(fence(topic["pinned"][lang]))
    ap("")
    ap("## 8. Credits")
    ap("")
    for lang in LANGS:
        ap(f"**{lang.upper()}**")
        ap("")
        for c in CREDITS[lang]:
            ap(f"* {c}")
        if topic.get("sources"):
            ap(f"* {'Sources' if lang == 'en' else 'Источники' if lang == 'ru' else 'Manbalar'}: " + " ".join(topic["sources"]))
        ap("")
    ap("Internal licence notes (not for the public text):")
    ap("")
    for n in INTERNAL_LICENCE_NOTES:
        ap(f"* {n}")
    ap("")
    ap("## 9. Files, thumbnails and alt text")
    ap("")
    ap("| Lang | YouTube video | Thumbnail | Subtitles | Instagram video | Cover |")
    ap("|---|---|---|---|---|---|")
    for lang in LANGS:
        ap(f"| {lang} | `{fname('yt_video', tid, lang)}` | `{fname('thumb', tid, lang)}` | "
           f"`{fname('srt', tid, lang)}`, `{fname('vtt', tid, lang)}` | `{fname('ig_video', tid, lang)}` | "
           f"`{fname('cover', tid, lang)}` |")
    ap("")
    ap("All under `video_studio/out/" + tid + "/<lang>/`. Alt text (thumbnail and cover show the same content):")
    ap("")
    for lang in LANGS:
        ap(f"* **{lang.upper()}**: {alt_text(topic, lang, ui_by_lang.get(lang))}")
    ap("")
    ap("## 10. End screen / CTA suggestion")
    ap("")
    nxt = ", ".join(f"`{n}`" for n in topic["next"])
    ap(f"* YouTube end screen (last ~7–20 s): subscribe + the next video in the SAME language edition ({nxt}) + the "
       f"playlist `[[LINK_PLAYLIST]]`. Place elements so they do not cover the end card's path pill or disclosure "
       f"notices (check against the final scene).")
    ap("* Description and pinned comment carry the store links (`[[LINK_APP_STORE]]`, `[[LINK_PLAY]]`); the video itself "
       "shows only the in-app path, no URL and no price.")
    ap("* Instagram: link in bio (`[[LINK_BIO]]`); ask viewers to save/share, not to \"download now\".")
    ap("")
    ap("## 11. Safe-content notes")
    ap("")
    for n in SAFE_CONTENT_COMMON:
        ap(f"* {n}")
    ap("")
    ap("## 12. Evidence the public text rests on")
    ap("")
    for e in topic["evidence"]:
        ap(f"* {e}")
    ap("")
    return "\n".join(out) + "\n"


# ------------------------------------------------------------------------------ lint
UZ_BAD_APOSTROPHES = re.compile(r"['`ʻʼ]|(?<![oOgG])‘")
PRICE_RE = re.compile(r"(\$\s?\d|\d\s?\$|\bUSD\b|\bUZS\b|\bEUR\b|€|\bсум\b|so‘m|\bсом\b|\bprice\s*[:=]|"
                      r"com\.[a-z0-9_]+\.[a-z0-9_.]+)", re.IGNORECASE)


def lint_topic(topic):
    """Return a list of problems (empty = fine). Used by build_kit.py and the tests."""
    from common import HASHTAGS_MAX, HASHTAGS_MIN, YT_DESC_MAX, YT_TITLE_MAX
    problems = []
    tid = topic["id"]
    for lang in LANGS:
        t = topic["title"][lang]
        if len(t) > YT_TITLE_MAX:
            problems.append(f"{tid}: {lang} title is {len(t)} > {YT_TITLE_MAX} chars")
        tags = hashtags(topic, lang)
        if not HASHTAGS_MIN <= len(tags) <= HASHTAGS_MAX:
            problems.append(f"{tid}: {lang} has {len(tags)} hashtags (need {HASHTAGS_MIN}-{HASHTAGS_MAX})")
        for tag in tags:
            if not re.fullmatch(r"#\w+", tag):
                problems.append(f"{tid}: bad hashtag {tag!r}")
        if instagram_total(topic, lang) > IG_CAPTION_MAX:
            problems.append(f"{tid}: {lang} Instagram text is {instagram_total(topic, lang)} > {IG_CAPTION_MAX}")
        d = youtube_description(topic, lang, None)
        if len(d) > YT_DESC_MAX:
            problems.append(f"{tid}: {lang} YouTube description {len(d)} > {YT_DESC_MAX}")
        for line in topic["hook"][lang]:
            if len(line) > 130:
                problems.append(f"{tid}: {lang} hook line is {len(line)} chars (keep <= 130)")
        tg = youtube_tags(topic, lang)
        if len(", ".join(tg)) > YT_TAGS_MAX:
            problems.append(f"{tid}: {lang} tags exceed {YT_TAGS_MAX}")
        for label, text in _public_texts(topic, lang):
            if PRICE_RE.search(text):
                problems.append(f"{tid}: {lang} {label} contains a price / product-id-like token")
            if lang == "uz" and UZ_BAD_APOSTROPHES.search(text):
                problems.append(f"{tid}: uz {label} has a wrong apostrophe (use o‘ g‘ U+2018 and ’ U+2019)")
            if "[[" in text.replace("[[LINK_APP_STORE]]", "").replace("[[LINK_PLAY]]", "") \
                    .replace("[[LINK_BIO]]", "").replace("[[LINK_PLAYLIST]]", "").replace("[[LINK_SITE]]", ""):
                problems.append(f"{tid}: {lang} {label} has an unknown placeholder")
        # mandatory disclosures must be in both public texts
        d_text = youtube_description(topic, lang, None)
        i_text = instagram_caption(topic, lang)[0]
        for key in DISCLOSURE_ORDER:
            want = DISCLOSURES[key][lang]
            if key == "voice" and lang == "en":
                want = "English synthetic narration (Kokoro-82M, Apache-2.0)"
            if want.rstrip(".") not in d_text:
                problems.append(f"{tid}: {lang} YouTube text lacks disclosure {key!r}")
            if want.rstrip(".") not in i_text:
                problems.append(f"{tid}: {lang} Instagram text lacks disclosure {key!r}")
        if topic["tier"] == "paid" and PAID_LINE[lang] not in d_text:
            problems.append(f"{tid}: {lang} paid topic lacks the paid line")
        if topic["tier"] == "free" and re.search(r"\bPro\b|Premium|subscription|подписк|obuna", d_text) \
                and topic["id"] != "premium_overview":
            problems.append(f"{tid}: {lang} free topic mentions a paid plan")
    return problems


def _public_texts(topic, lang):
    yield "title", topic["title"][lang]
    yield "hook", "\n".join(topic["hook"][lang])
    yield "shows", "\n".join(topic["shows"][lang])
    yield "app", "\n".join(topic["app"][lang])
    yield "limits", "\n".join(topic["limits"][lang])
    yield "ig", "\n".join(topic["ig"][lang])
    yield "pinned", topic["pinned"][lang]
    yield "keywords", ", ".join(topic["keywords"][lang])
    yield "youtube description", youtube_description(topic, lang, None)
    yield "instagram caption", instagram_caption(topic, lang)[0]
