#!/usr/bin/env python3
"""Uzbek (Latin) TTS-ready text: expand abbreviations, Latin/English terms, symbols and numbers into
how an Uzbek reader would say them. Stdlib only; reuses the number words of tool/tts/synth.py.

    from uz_prep import prepare
    spoken, used, warnings = prepare("Sifat nazorati: Levey–Jennings grafiklari, har seriyada Westgard qoidalari.")

`used` is a list of dicts {term, written, spoken, risk, note, kind} (what was rewritten) - it feeds the
per-video pronunciation_uz.csv. `warnings` lists things this module could NOT expand (digits, dates,
unknown upper-case abbreviations): the plan marks such lines NEEDS_MANUAL.

SPOKEN-UZBEK-ONLY RULE (owner, from listening tests of UzbekVoice 'shoira'): the voice cannot read English/Latin
terms and letter-by-letter respellings ('pe de ef', 'e ge ef er') sound bad. The voice text therefore contains
ONLY ordinary Uzbek words (loanwords in Uzbek orthography such as kalkulyator, kyuveta count as ordinary). Every
abbreviation / Latin term is replaced by an Uzbek term, a descriptive phrase, or dropped (the on-screen subtitle
keeps it). The replacements live in tool/tts/lexicon/spoken_uz_only.json (terms, line_terms, line_overrides);
personal names are the only unavoidable foreign tokens and are listed as NEEDS_OWNER_APPROVAL there.

Nobody has listened to any of this yet: all rows are NEEDS_NATIVE_REVIEW. Apostrophes in o‘ g‘ (U+2018) and tutuq
(U+2019) are kept as written; synth_uz.py can map them at synthesis time (--apostrophe).
"""
from __future__ import annotations

import json
import re
import sys
import unicodedata
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import synth  # noqa: E402  (number words, decimals, units)

APOS = "[’‘ʼ'`]"
BANNED = re.compile("|".join(["toi" + "fa", "ban" + "k"]), re.IGNORECASE)  # owner's word list; split so a text search is clean

_UNITS_SPOKEN = [
    ("mOsm/kg", r"mOsm/kg", "milliosmol kilogramm", "MEDIUM", "unit"),
    ("mmol/L", r"mmol/L", "millimol litr", "MEDIUM", "unit; number words from synth.py"),
]

LEXICON_FILE = Path(__file__).resolve().parent / "lexicon" / "spoken_uz_only.json"
_LEX_CACHE: dict = {}


def load_lexicon(path: Path | None = None) -> dict:
    """The spoken-Uzbek-only lexicon (cached)."""
    p = Path(path or LEXICON_FILE)
    if str(p) not in _LEX_CACHE:
        lex = json.loads(p.read_text(encoding="utf-8"))
        for t in lex["terms"]:
            suf = "|".join(t.get("detached_suffixes", []))
            t["_rx"] = re.compile(
                ("" if t["pattern"].startswith(":") else r"(?<![\w])") + r"(?:" + t["pattern"] + r")" +
                (r"(?:" + APOS + r"(?P<suf>[a-zA-Z]+))?(?![\w])" if t["action"] == "replace" else "") +
                ((r"(?:\s+(?P<dsuf>" + suf + r")(?![\w]))?") if suf else ""))
        _LEX_CACHE[str(p)] = lex
    return _LEX_CACHE[str(p)]


# loanwords written in Uzbek orthography: spoken = written, but each is a pronunciation risk to listen for
WATCH = {
    "spektrofotometr": "MEDIUM", "xromatografiya": "MEDIUM", "xromatogramma": "MEDIUM", "leykotsit": "MEDIUM",
    "neytrofil": "MEDIUM", "eozinofil": "MEDIUM", "bazofil": "MEDIUM", "limfotsit": "MEDIUM",
    "monotsit": "MEDIUM", "eritrotsit": "MEDIUM", "trombotsit": "MEDIUM", "osmolyallik": "HIGH",
    "osmolyarlik": "HIGH", "osmolyal": "HIGH", "kvadrupol": "MEDIUM", "derivatizatsiya": "HIGH",
    "fluoressensiya": "HIGH", "termosiklator": "MEDIUM", "praymer": "MEDIUM", "polimeraza": "MEDIUM",
    "immersiya": "MEDIUM", "kyuveta": "MEDIUM", "glyukoza": "MEDIUM", "mochevina": "MEDIUM",
    "kreatinin": "LOW", "kalibrlash": "LOW", "kalibrator": "LOW", "konsentratsiya": "LOW",
    "termistor": "MEDIUM", "avtonamunaoluvchi": "HIGH", "peltye": "HIGH", "leykoformula": "MEDIUM",
    "toksikologiya": "MEDIUM", "biokimyo": "LOW", "analizator": "LOW", "fotometr": "LOW", "osmometr": "MEDIUM",
    "mikroskop": "LOW", "reagent": "LOW", "atlas": "LOW", "molekulyar": "MEDIUM",
}

_ORD_VOWELS = "aeiouoʻ‘"


def _words(n: int) -> str:
    return synth.int_to_words(int(n), "uz")


def _ordinal(n: int) -> str:
    w = _words(n)
    return w + ("nchi" if w[-1] in "aeiou" else "inchi")


def _gacha(w: str) -> str:
    return w + ("qacha" if w[-1] == "q" else "kacha" if w[-1] == "k" else "gacha")


def _join_suffix(base: str, suf: str, attach: bool) -> str:
    if not suf:
        return base
    return base + suf if attach else base + " " + suf


class Recorder:
    def __init__(self):
        self.used: list[dict] = []

    def add(self, term, written, spoken, risk, note="", kind="term"):
        self.used.append({"term": term, "written": written, "spoken": spoken, "risk": risk, "note": note,
                          "kind": kind, "action": "replaced", "approval": "no"})
        return spoken


def _decimal_vergul(whole: str, frac: str) -> str:
    """2,3 -> 'ikki vergul uch'; 0,486 -> 'nol vergul to‘rt yuz sakson olti'; 0,05 -> 'nol vergul nol besh'."""
    fw = " ".join(_words(d) for d in frac[:len(frac) - len(frac.lstrip("0"))]) if frac.startswith("0") else ""
    rest = frac.lstrip("0")
    parts = [_words(whole), "vergul"] + ([fw] if fw else []) + ([_words(rest)] if rest else [])
    return " ".join(parts)


_VOWELS = "aeiou"


def attach_suffix(spoken: str, suf: str) -> str:
    """Attach an Uzbek case/possessive suffix (written after an apostrophe in the subtitle, e.g. PDF’da) to the
    last word of the spoken replacement, with the few Uzbek sound rules that matter here."""
    if not suf:
        return spoken
    last = spoken[-1]
    if last == "i" and suf.startswith("si"):      # yo‘riqnomasi + sidan -> yo‘riqnomasidan
        suf = suf[2:]
    elif last in _VOWELS and suf.startswith("ing"):  # protsedura + ingizdan -> procedurangizdan
        suf = suf[1:]
    elif last in _VOWELS and suf.startswith("i"):    # protsedura + idan -> protsedurasidan
        suf = "s" + suf
    elif suf.startswith("ga") and last in "kq":      # ga -> ka / qa
        suf = ("k" if last == "k" else "q") + suf[1:]
    return spoken + suf


def _sentence_start(text: str, pos: int) -> bool:
    return re.search(r"(?:^|[.!?…]\s*|[«\"]\s*)$", text[:pos]) is not None


def _check_override_source(ov: dict, text: str) -> list[str]:
    return [] if ov["source"] == unicodedata.normalize("NFC", text) else [
        "STALE_OVERRIDE: the subtitle text changed since the override in spoken_uz_only.json was written"]


def prepare(text: str, extra_warn: bool = True, decimal: str = "vergul", key: str | None = None,
            lexicon: dict | None = None) -> tuple[str, list[dict], list[str]]:
    """decimal: 'vergul' (2,3 -> 'ikki vergul uch', short, conversational) or 'formal' ('ikki butun o‘ndan uch').

    key: "<video>:<line id>" (suffix ":S" for the suggested shorter text) selects line-specific entries of the
    lexicon (line_overrides = whole spoken line written by hand, line_terms = replace one term differently).
    Both decimals variants are proposals for native review; 'vergul' is the default because it is ~25 % shorter and
    the narration windows are tight.
    """
    lex = lexicon or load_lexicon()
    rec = Recorder()
    t = unicodedata.normalize("NFC", text)
    t = t.replace("«", "").replace("»", "")
    warnings: list[str] = []

    ov = (lex.get("line_overrides") or {}).get(key) if key else None
    if ov:
        warnings += _check_override_source(ov, text)
        for tok in ov["tokens"]:
            rec.add(tok["term"], tok["term"], tok["spoken"], tok.get("risk", "MEDIUM"), tok["note"], tok["kind"])
            rec.used[-1].update(action=tok["action"], approval=tok["approval"])
        # numerals that stayed in the sentence are spelled in the override itself
        t = ov["spoken"]
        _numbers_in_source(text, rec)
        return _finish(text, t, rec, warnings, extra_warn)

    line_terms = (lex.get("line_terms") or {}).get(key, {}) if key else {}
    protected: list[str] = []   # replaced text is hidden from the later rules (so 'Lab Gayd' is not hit by the 'Lab' rule)

    # --- Westgard names, abbreviations, Latin terms (lexicon, in file order) --------------------------
    for term in lex["terms"]:
        rx = term["_rx"]
        spoken0 = line_terms.get(term["term"], term["spoken"])

        def rep(m, term=term, spoken0=spoken0):
            gd = m.groupdict()
            if term["action"] == "drop":
                rec.add(term["term"], m.group(0).strip(), "", term["risk"], term["note"], term["kind"])
                rec.used[-1].update(action="dropped", approval=term["approval"])
                return ""
            out = attach_suffix(spoken0, gd.get("suf") or "")
            if gd.get("dsuf"):
                out = attach_suffix(out, gd["dsuf"])
            if _sentence_start(m.string, m.start()) or term["kind"] == "label" and term["term"] == "Lab":
                out = out[:1].upper() + out[1:]
            rec.add(term["term"], m.group(0), out, term["risk"], term["note"], term["kind"])
            rec.used[-1].update(action="replaced", approval=term["approval"])
            protected.append(out)
            return chr(0xE000 + len(protected) - 1)

        t = rx.sub(rep, t)
    t = re.sub("[\ue000-\uefff]", lambda m: protected[ord(m.group(0)) - 0xE000], t)

    # --- units with their own words ---------------------------------------------------
    for term, rx, spoken, risk, note in _UNITS_SPOKEN:
        if term == "mmol/L":
            continue  # number + unit is handled by synth.normalise_numbers_and_units below
        t = re.sub(r"(?<![\w])" + rx + r"(?![\w])",
                   lambda m, term=term, spoken=spoken, risk=risk, note=note: rec.add(term, m.group(0), spoken, risk, note, "unit"), t)
    t = re.sub(r"(?<![\w])kg iga(?![\w])",
               lambda m: rec.add("kg iga", m.group(0), "kilogrammiga", "LOW", "per kg of water", "unit"), t)
    t = re.sub(r"(?<![\w])massa/zaryad", lambda m: rec.add("massa/zaryad", m.group(0), "massa-zaryad", "LOW", "", "symbol"), t)

    if re.search(r"(?<![\w])(?:\d{1,2}-\ds|R-\ds|\d{1,2}x)(?![\w])", t):   # synth.py would read '3s' as 3 seconds
        warnings.append("Westgard rule token without a lexicon entry (would be misread): " +
                        ",".join(re.findall(r"(?<![\w])(?:\d{1,2}-\ds|R-\ds|\d{1,2}x)(?![\w])", t)))
    return _finish(text, t, rec, warnings, extra_warn, decimal)


def _numbers_in_source(text: str, rec: "Recorder") -> None:
    for m in re.finditer(r"(?<![\w.,])\d+(?:[.,]\d+)?(?![\w])", text):
        rec.add("number " + m.group(0), m.group(0), "(in words)", "LOW", "", "number")


def _finish(text: str, t: str, rec: "Recorder", warnings: list[str], extra_warn: bool, decimal: str = "vergul"):
    # --- numbers -----------------------------------------------------------------------
    t = re.sub(r"(?<![\w.,])(\d+)\s?%\s?i(?![\w])",
               lambda m: rec.add("N % i", m.group(0), _words(m.group(1)) + " foizi", "LOW", "percent + possessive", "number"), t)
    # 2–5  -> ikkidan beshgacha
    t = re.sub(r"(?<![\w.,])(\d+)–(\d+)(?![\w])",
               lambda m: rec.add("range N–M", m.group(0), _words(m.group(1)) + "dan " + _gacha(_words(m.group(2))),
                                 "MEDIUM", "numeric range spoken as 'N-dan M-gacha'", "number"), t)
    # 22-siklda / 10-hujayrada  (hyphenated numeral + noun = ordinal in Uzbek)
    t = re.sub(r"(?<![\w.,])(\d+)-(?=[A-Za-zʻ‘’])",
               lambda m: rec.add("N-noun ordinal", m.group(0), _ordinal(m.group(1)) + " ", "MEDIUM",
                                 "hyphenated numeral read as ordinal (…inchi)", "number"), t)
    t = re.sub(r"~\s?(?=\d)", lambda m: rec.add("~", m.group(0), "taxminan ", "LOW", "approximately", "symbol"), t)
    t = re.sub(r"\+(?=\d)", lambda m: rec.add("+", m.group(0), "plyus ", "LOW", "plus sign", "symbol"), t)

    if decimal == "vergul":
        t = re.sub(r"(?<![\w.,])(\d+),(\d+)(?![\w])(?!\s?(?:" + synth._UNIT_RE + r")(?![\w]))",
                   lambda m: rec.add("decimal " + m.group(0), m.group(0), _decimal_vergul(m.group(1), m.group(2)),
                                     "MEDIUM", "decimal comma read as 'vergul' (alternative: butun … dan …)", "number"), t)
    before = t
    t = synth.normalise_numbers_and_units(t, "uz")
    if t != before:  # record remaining numbers (decimals are the risky ones)
        for m in re.finditer(r"(?<![\w.,])\d+(?:[.,]\d+)?(?:\s?(?:mmol/L|%))?(?![\w])", before):
            s = m.group(0)
            sp = synth.normalise_numbers_and_units(s, "uz")
            dec = bool(re.search(r"\d[.,]\d", s))
            rec.add("number " + s, s, sp, "MEDIUM" if dec or "mmol" in s or "%" in s else "LOW",
                    "decimal read as 'butun … dan …'" if dec else "", "number")

    # --- symbols -----------------------------------------------------------------------
    sym = [("=", " teng "), ("÷", " bo‘lingan "), ("×", " ko‘paytirilgan "), ("→", ", ")]
    for s, sp in sym:
        if s in t:
            rec.add(s, s, sp.strip() or ",", "LOW", "symbol read aloud" if s != "→" else "menu path: pause", "symbol")
            t = t.replace(s, sp)
    if re.search(r"−\s?\d", t):
        rec.add("−", "−", "minus", "LOW", "minus sign", "symbol")
        t = t.replace("−", "minus ")
    t = re.sub(r"(?<=[A-Za-zʻ‘’])–(?=[A-Za-z])", " ", t)           # en dash between words
    t = re.sub(r"\s*—\s*", ", ", t)                                 # em dash = pause (as synth.normalise_text)
    t = re.sub(r"([?!]),", r"\1", t)                                 # '?, ' after a quoted question
    t = re.sub(r"\s+", " ", t)
    t = re.sub(r"\s+([,;:.!?…])", r"\1", t)
    t = re.sub(r",\s*,", ",", t)
    t = re.sub(r"^[,\s]+", "", t).strip()
    if not text[:1].islower() and t[:1].islower():
        t = t[:1].upper() + t[1:]

    # --- loanword watch list (spoken = written) ----------------------------------------
    low = t.lower()
    for w, risk in WATCH.items():
        if re.search(r"(?<![\w])" + w, low):
            rec.add(w, w, w, risk, "ordinary Uzbek-orthography loanword, spoken as written; LISTEN for stress/vowels", "watch")
            rec.used[-1].update(action="kept", approval="no")

    if extra_warn:
        if re.search(r"\d", t):
            warnings.append("digit left: " + ",".join(sorted(set(re.findall(r"\d+", t)))))
        if re.search(r"\b\d{1,2}[./]\d{1,2}[./]\d{2,4}\b", text):
            warnings.append("date pattern in source: not expanded automatically (none expected in these scripts)")
        left = re.findall(r"(?<![\w])[A-Z]{2,}(?![\w])", t)
        if left:
            warnings.append("unexpanded capitals: " + ",".join(sorted(set(left))))
        if re.search(r"[=÷×+%~→·²₀₁{}/]", t):
            warnings.append("symbol left in spoken text")
        if BANNED.search(t):
            warnings.append("banned term in output")
    return t, rec.used, warnings


def glossary_rows(used: list[dict]) -> list[dict]:
    """Merge `used` entries (many lines) into unique glossary rows with line ids attached by the caller."""
    seen: dict[tuple, dict] = {}
    for u in used:
        k = (u["term"], u["written"], u["spoken"])
        seen.setdefault(k, u)
    return list(seen.values())


if __name__ == "__main__":
    for line in sys.argv[1:]:
        sp, used, warn = prepare(line)
        print(sp)
        if warn:
            print("WARN:", warn)
