"""6-week publishing cadence PROPOSAL (SCHEDULE.md + SCHEDULE.csv) and the ad-readiness checklist (stdlib).

Weeks are RELATIVE (week 1 = the first week after the owner approves the first topic); there are no calendar
dates. Nothing is published by the studio. Every row is gated by the topic's gates (kit.GATES + GP for paid).
"""
import csv
import io

from common import GATE_SHORT, GATES, PAID_GATE
from kit import fname
from topics import BY_ID

# (week, slot, topic id or None, note)
PLAN = [
    (1, "A", "calibration", "Flagship 1. Rendered."),
    (1, "B", "leukocyte", "Flagship 2. Rendered."),
    (2, "A", "qc", "Pairs with calibration (both are 'documenting quality')."),
    (2, "B", "photometry", "Background for calibration (blank, standard, sample, linearity limit); built on the app's Lecture-mode protocol."),
    (3, "A", "calculators", "Broad, practical; good for sharing."),
    (3, "B", "osmometry", "Schematic topic; links to the osmolality calculator."),
    (4, "A", "gcms", "Schematic topic (toxicology direction)."),
    (4, "B", "qpcr", "Schematic topic (molecular direction)."),
    (5, "A", "exam_simulation", "PAID topic: only when the paid build is live (gate GP)."),
    (5, "B", "teacher_pro", "PAID topic: only when the paid build and server are live (gate GP)."),
    (6, "A", "premium_overview", "PAID topic: last, only when the paid build is live (gate GP)."),
    (6, "B", None, "Buffer: fixes from comments, re-share the best-performing post, answer questions. No new video."),
]

# Slot A: Mon YouTube x3, Tue IG uz, Wed IG ru, Wed IG en.  Slot B: Thu YouTube x3, Fri IG uz, Sat IG ru, Sun IG en.
SLOT_DAYS = {
    "A": [("Mon", "YouTube", "uz"), ("Mon", "YouTube", "ru"), ("Mon", "YouTube", "en"),
          ("Tue", "Instagram", "uz"), ("Wed", "Instagram", "ru"), ("Wed", "Instagram", "en")],
    "B": [("Thu", "YouTube", "uz"), ("Thu", "YouTube", "ru"), ("Thu", "YouTube", "en"),
          ("Fri", "Instagram", "uz"), ("Sat", "Instagram", "ru"), ("Sun", "Instagram", "en")],
}
FORMATS = {
    "YouTube": "16:9 long-form, 1920×1080",
    "Instagram": "9:16 Reel, 1080×1920",
}
CSV_FIELDS = ["week", "slot", "day", "platform", "topic_id", "language_edition", "format", "file", "gates",
              "video_status_at_build", "proposal_status", "note"]

CHECKLIST = [
    # (area, item, status, detail)
    ("Rights", "Music", "OK", "None used in any video (storyboards, QA notes)."),
    ("Rights", "Voice", "OK (licence) — listening review OPEN",
     "Synthetic: Kokoro-82M, Apache-2.0, voice af_heart, via kokoro-onnx (MIT); no attribution required, credited anyway. "
     "`docs/video/tts/VOICE_DECISION.md`. Residual risk noted there: provenance of Kokoro's synthetic training audio."),
    ("Rights", "Fonts", "OK", "Inter and Instrument Serif, SIL OFL (`assets/fonts/*-OFL.txt`)."),
    ("Rights", "Imagery", "OK",
     "Original schematics and drawings by LabGuide plus real app screens; no third-party photograph, stock footage, "
     "micrograph or logo (`docs/SCHEMATICS_PROVENANCE.md`, each video's CLAIMS_AND_EVIDENCE.md §2)."),
    ("Rights", "Logo", "OK — owner to confirm", "Owner's app icon (`assets/images/logo_mark_large.png`)."),
    ("Rights", "Render tool licence (Remotion)", "OPEN — blocker (G4)",
     "Free for individuals, non-profits and for-profit companies of up to 3 people; a larger company needs a Company "
     "licence. The owner checks the company size (`video_studio/node_modules/remotion/LICENSE.md`)."),
    ("Quality", "Listening review of the English synthetic voice", "OPEN — blocker (G2)",
     "Nobody has listened to it yet. Do not call it natural or professional."),
    ("Quality", "Expert science review", "OPEN — blocker (G1)",
     "Every video is EXPERT_REVIEW_PENDING. Rows tagged NEEDS_EXPERT in each CLAIMS_AND_EVIDENCE.md go to a "
     "laboratory specialist (calibration: E2, E7, E9; leukocyte: E7, E10, E11)."),
    ("Quality", "Native RU / UZ review (subtitles, on-screen text, this kit's RU/UZ texts)", "OPEN — blocker (G3)",
     "All RU/UZ wording is NEEDS_NATIVE_REVIEW (`docs/L10N_TERMINOLOGY_DECISIONS.md`)."),
    ("Quality", "Honest audience expectation about language", "Info",
     "All editions have English narration; RU/UZ editions are subtitled. No Russian or Uzbek voice exists that is both "
     "good and cleared for commercial use (`VOICE_DECISION.md`). Say so in the first pinned comment (already in the kit)."),
    ("Quality", "Disclosures on screen and in text", "OK",
     "On screen: illustrative-data badge, schematic badge (QA.md). In text: illustrative data, educational use, "
     "synthetic English narration (Kokoro-82M, Apache-2.0), expert review pending — in every description and caption "
     "(checked by `tool/publish/test_kit.py`)."),
    ("Product truth", "App availability and store approval status", "OPEN — blocker (G5)",
     "The free version is, per `docs/PAID_BRANCH_STATUS.md`, in store review; this kit knows no public store link, so "
     "every link is a placeholder. Owner confirms the approval status and fills the links."),
    ("Product truth", "Video matches the advertised build", "OPEN — owner check",
     "Frames were rendered from the free app (`fix/images-apparatus@215d3e8`); the video says nothing about price or "
     "tiers. Confirm the advertised build behaves the same."),
    ("Product truth", "Paid features (Student/Teacher/Specialist Pro, Premium)", "OPEN — blocker for paid topics (GP)",
     "Not live: flags off, nothing deployed, store products unconfirmed, no real sandbox purchase run, device "
     "attestation for the 7-day trial not written (`docs/PAID_BRANCH_STATUS.md`, D-77/D-78). Paid-topic videos stay "
     "unpublished until the owner confirms the paid build is live."),
    ("Platform", "Health / medical advertising policy of each platform", "OPEN — NEEDS_OWNER_CHECK",
     "Not read by us. The videos make no diagnosis, treatment, accuracy or time-saved claim."),
    ("Platform", "Synthetic / altered-content disclosure setting", "OPEN — NEEDS_OWNER_CHECK",
     "Answer the platform's own question honestly; the text already states the voice is synthetic."),
    ("Platform", "Format limits (length, safe zones)", "OPEN — NEEDS_OWNER_CHECK",
     "Videos run about 1.5–2 minutes. Vertical subtitles were kept inside x 70–1010 and above y 1640 (QA.md); "
     "check on the real app UI before paid promotion."),
    ("Platform", "Landing page and privacy-policy URL live", "OPEN — NEEDS_OWNER_CHECK",
     "The app links `https://labguide.nfcstore.uz/privacy/`; whether the site is live is the owner's to confirm."),
    ("Text", "No price, product id, discount or availability date", "OK", "Enforced by the lint in `tool/publish/test_kit.py`."),
]


def rows(statuses):
    """statuses: {topic_id: ('READY'|'NOT READY', reason)}."""
    out = []
    for week, slot, tid, note in PLAN:
        if tid is None:
            out.append({"week": week, "slot": slot, "day": "Mon–Sun", "platform": "—", "topic_id": "—",
                        "language_edition": "—", "format": "—", "file": "—", "gates": "—",
                        "video_status_at_build": "—", "proposal_status": "PROPOSAL", "note": note})
            continue
        topic = BY_ID[tid]
        gates = "G1–G6" + ("+GP" if topic["tier"] == "paid" else "")
        for day, platform, lang in SLOT_DAYS[slot]:
            kind = "yt_video" if platform == "YouTube" else "ig_video"
            out.append({"week": week, "slot": slot, "day": day, "platform": platform, "topic_id": tid,
                        "language_edition": lang, "format": FORMATS[platform],
                        "file": fname(kind, tid, lang), "gates": gates,
                        "video_status_at_build": statuses.get(tid, ("NOT READY", ""))[0],
                        "proposal_status": "PROPOSAL — needs owner approval", "note": note})
    return out


def render_csv(statuses):
    buf = io.StringIO()
    w = csv.DictWriter(buf, fieldnames=CSV_FIELDS, lineterminator="\n")
    w.writeheader()
    for r in rows(statuses):
        w.writerow(r)
    return buf.getvalue()


def render_md(statuses, date_label):
    out = []
    ap = out.append
    ap("# Publishing schedule — 6-week proposal")
    ap("")
    ap("<!-- GENERATED by tool/publish/build_kit.py (tool/publish/schedule.py): edit schedule.py, not this file -->")
    ap("")
    ap("> **PROPOSAL — needs the owner's approval. Nothing is published, uploaded or scheduled by us.**")
    ap("> **Unreviewed-science rule:** every video is EXPERT_REVIEW_PENDING. The owner decides when (and whether) to "
       "publish, after the expert review and the other gates below. Weeks are relative: week 1 starts when the owner "
       "approves the first topic. A slot whose topic has an open gate is skipped and the next ready topic moves up.")
    ap("")
    ap(f"Status below = state of the rendered files when this file was generated ({date_label}).")
    ap("")
    ap("## 1. Cadence")
    ap("")
    ap("Two topic slots per week. Each slot publishes one topic in three language editions: three YouTube videos "
       "(UZ, RU, EN: separate videos, separate playlists, same English narration, subtitles in the edition's language) "
       "and three Instagram Reels (the 9:16 files).")
    ap("")
    ap("| Slot | Mon | Tue | Wed | Thu | Fri | Sat | Sun |")
    ap("|---|---|---|---|---|---|---|---|")
    ap("| A | YouTube UZ + RU + EN | Reel UZ | Reel RU + Reel EN | | | | |")
    ap("| B | | | | YouTube UZ + RU + EN | Reel UZ | Reel RU | Reel EN |")
    ap("")
    ap("Time of day: the owner decides after looking at the channel's own analytics (none exist yet; we make no "
       "assumption about the audience's time zone).")
    ap("")
    ap("Lower-intensity option: one slot per week (the 11 topics then take 11 weeks); or one language edition per "
       "platform first (UZ), the others a week later. Optional: the vertical file can also go to YouTube Shorts "
       "(check the platform's current length limit first: NEEDS_OWNER_CHECK).")
    ap("")
    ap("## 2. Topic order")
    ap("")
    ap("| Week | Slot | Topic | Tier | Video now | Gates | Note |")
    ap("|---|---|---|---|---|---|---|")
    for week, slot, tid, note in PLAN:
        if tid is None:
            ap(f"| {week} | {slot} | — | — | — | — | {note} |")
            continue
        t = BY_ID[tid]
        st = statuses.get(tid, ("NOT READY", ""))
        gates = "G1–G6" + (" + GP" if t["tier"] == "paid" else "")
        ap(f"| {week} | {slot} | `{tid}` — {t['title']['en']} | {t['tier']} | **{st[0]}** | {gates} | {note} |")
    ap("")
    ap("Gates: " + "; ".join(f"**{g}** {GATE_SHORT[g]}" for g, _ in GATES)
       + f"; **{PAID_GATE[0]}** {GATE_SHORT['GP']}. Full wording in every `<id>.md` §0.")
    ap("")
    ap("## 3. Every post (also in `SCHEDULE.csv`)")
    ap("")
    ap("| Wk | Day | Platform | Topic | Edition | Format | File | Video now |")
    ap("|---|---|---|---|---|---|---|---|")
    for r in rows(statuses):
        if r["platform"] == "—":
            ap(f"| {r['week']} | {r['day']} | — | — | — | — | {r['note']} | — |")
        else:
            ap(f"| {r['week']} | {r['day']} | {r['platform']} | `{r['topic_id']}` | {r['language_edition']} | "
               f"{r['format']} | `{r['file']}` | {r['video_status_at_build']} |")
    ap("")
    ap("## 4. Ad-readiness checklist")
    ap("")
    ap("Use before any paid promotion (and before the first organic post). `OK` = verified in the repository; "
       "`OPEN` = needs a person; `NEEDS_OWNER_CHECK` = we have not read the platform's current rules.")
    ap("")
    ap("| Area | Item | Status | Detail |")
    ap("|---|---|---|---|")
    for area, item, status, detail in CHECKLIST:
        ap(f"| {area} | {item} | **{status}** | {detail} |")
    ap("")
    ap("### Remaining blockers (summary)")
    ap("")
    ap("1. Listening review of the English synthetic voice (G2).")
    ap("2. Expert science review of each topic (G1).")
    ap("3. Native RU and UZ review of subtitles, on-screen text and the RU/UZ kit texts (G3).")
    ap("4. Remotion licence company-size check (G4).")
    ap("5. App availability and store approval status; the store links (G5).")
    ap("6. Paid features not live: paid topics (`exam_simulation`, `teacher_pro`, `premium_overview`) cannot be "
       "published until the paid build is live (GP).")
    ap("7. Platform rules (health ads, synthetic-voice setting, format limits) and a live landing/privacy page: owner checks.")
    ap("")
    return "\n".join(out) + "\n"
