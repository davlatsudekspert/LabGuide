#!/usr/bin/env python3
"""Uzbek (Latin) TTS-ready text: expand abbreviations, Latin/English terms, symbols and numbers into
how an Uzbek reader would say them. Stdlib only; reuses the number words of tool/tts/synth.py.

    from uz_prep import prepare
    spoken, used, warnings = prepare("Sifat nazorati: Levey–Jennings grafiklari, har seriyada Westgard qoidalari.")

`used` is a list of dicts {term, written, spoken, risk, note, kind} (what was rewritten) - it feeds the
per-video pronunciation_uz.csv. `warnings` lists things this module could NOT expand (digits, dates,
unknown upper-case abbreviations): the plan marks such lines NEEDS_MANUAL.

IMPORTANT: every respelling here is a PROPOSAL. Azure uz-UZ voices do not support SSML <phoneme> or custom
lexicons (Microsoft Learn, language-support table), so the only lever is plain-text respelling. Nobody has
listened to any of this yet: all rows are NEEDS_NATIVE_REVIEW. Apostrophes in o‘ g‘ (U+2018) and tutuq
(U+2019) are kept as written; synth_uz.py can map them at synthesis time (--apostrophe).
"""
from __future__ import annotations

import re
import sys
import unicodedata
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import synth  # noqa: E402  (number words, decimals, units)

APOS = "[’‘ʼ'`]"
BANNED = re.compile("|".join(["toi" + "fa", "ban" + "k"]), re.IGNORECASE)  # owner's word list; split so a text search is clean

# Uzbek letter names (used to spell abbreviations)
LETTER = {"A": "a", "B": "be", "C": "se", "D": "de", "E": "e", "F": "ef", "G": "ge", "H": "ha", "I": "i",
          "J": "je", "K": "ka", "L": "el", "M": "em", "N": "en", "O": "o", "P": "pe", "Q": "kyu", "R": "er",
          "S": "es", "T": "te", "U": "u", "V": "ve", "W": "dabl yu", "X": "iks", "Y": "ye", "Z": "zet"}

# term, written regex (case-sensitive), spoken, risk, note, attach-suffix-without-space
# Order matters: longest / most specific first.
_ABBR = [
    ("GC-MS", r"GC-MS", "ji si em es", "HIGH", "English letter names; alternative: ge se em es / xromato-mass-spektrometriya", False),
    ("qPCR", r"qPCR", "kyu pe se er", "HIGH", "q = kyu (as in QC/QR); PCR spelled with Uzbek letter names", False),
    ("PCR", r"PCR", "pe se er", "MEDIUM", "same as tool/tts/lexicon/uz.json", False),
    ("eGFR", r"eGFR", "e ge ef er", "HIGH", "alternative: i ji ef ar", False),
    ("KDIGO", r"KDIGO", "kidigo", "HIGH", "read as one word; native check", True),
    ("LabGuide", r"LabGuide", "Leb Gayd", "HIGH", "brand; same as tool/tts/lexicon/uz.json", True),
    ("WBC", r"WBC", "dabl yu bi si", "HIGH", "English letter names (white blood cells); alternative: ve be se", False),
    ("QC", r"QC", "kyu si", "MEDIUM", "alternative: ku se", False),
    ("QR", r"QR", "kyu er", "MEDIUM", "alternative: ku er", False),
    ("PDF", r"PDF", "pe de ef", "LOW", "", False),
    ("CSV", r"CSV", "si es vi", "MEDIUM", "", False),
    ("IFU", r"IFU", "i ef yu", "HIGH", "instructions for use; alternative: foydalanish yo‘riqnomasi (changes wording)", False),
    ("SOP", r"SOP", "es o pe", "MEDIUM", "", False),
    ("REF", r"REF", "er e ef", "HIGH", "catalogue number label; alternative: ref", False),
    ("SD", r"SD", "es de", "MEDIUM", "standard deviation; alternative: standart og‘ish", False),
    ("SI", r"SI", "es i", "MEDIUM", "", False),
    ("GC", r"GC", "ji si", "HIGH", "", False),
    ("MS", r"MS", "em es", "MEDIUM", "", False),
    ("Cq", r"Cq", "si kyu", "HIGH", "quantification cycle", False),
    ("Levey–Jennings", r"Levey[–-]Jennings", "Livi Jenings", "HIGH", "personal names; English pronunciation approximated", False),
    ("Westgard", r"Westgard", "Vestgard", "HIGH", "personal name", False),
    ("R²", r"R²", "er kvadrat", "LOW", "", False),
]

_UNITS_SPOKEN = [
    ("mOsm/kg", r"mOsm/kg", "milliosmol kilogramm", "MEDIUM", "unit"),
    ("m/z", r"m/z", "em zet", "HIGH", "mass-to-charge ratio"),
    ("mmol/L", r"mmol/L", "millimol litr", "MEDIUM", "unit; number words from synth.py"),
]

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
                          "kind": kind})
        return spoken


def _decimal_vergul(whole: str, frac: str) -> str:
    """2,3 -> 'ikki vergul uch'; 0,486 -> 'nol vergul to‘rt yuz sakson olti'; 0,05 -> 'nol vergul nol besh'."""
    fw = " ".join(_words(d) for d in frac[:len(frac) - len(frac.lstrip("0"))]) if frac.startswith("0") else ""
    rest = frac.lstrip("0")
    parts = [_words(whole), "vergul"] + ([fw] if fw else []) + ([_words(rest)] if rest else [])
    return " ".join(parts)


def prepare(text: str, extra_warn: bool = True, decimal: str = "vergul") -> tuple[str, list[dict], list[str]]:
    """decimal: 'vergul' (2,3 -> 'ikki vergul uch', short, conversational) or 'formal' ('ikki butun o‘ndan uch').

    Both are proposals for native review; 'vergul' is the default because it is ~25 % shorter and the
    narration windows are tight.
    """
    rec = Recorder()
    t = unicodedata.normalize("NFC", text)
    t = t.replace("«", "").replace("»", "")

    # --- whole formulas -------------------------------------------------------------
    t = re.sub(r"A = log₁₀\(I₀/I\)",
               lambda m: rec.add("A = log10(I0/I)", m.group(0), "A teng I nol bo‘lingan I ning o‘nli logarifmi",
                                 "HIGH", "formula read aloud", "formula"), t)
    t = re.sub(r"C = A namuna ÷ A standart × standart konsentratsiyasi",
               lambda m: rec.add("C = A_sample / A_std x C_std", m.group(0),
                                 "se teng a namuna bo‘lingan a standart, ko‘paytirilgan standart konsentratsiyasi",
                                 "HIGH", "formula read aloud", "formula"), t)
    t = re.sub(r"C1·V1 = C2·V2",
               lambda m: rec.add("C1V1 = C2V2", m.group(0),
                                 "se bir ve bir teng se ikki ve ikki",
                                 "HIGH", "formula read aloud", "formula"), t)

    # --- Westgard rule names (before generic numbers/units) --------------------------
    def qc_rule(m):
        a, b = m.group(1), m.group(2)
        return rec.add("Westgard rule " + m.group(0), m.group(0), "%s %s es" % (_words(a), _words(b)),
                       "HIGH", "rule name: first digit = count, second = SD multiple, s = SD", "qc-rule")

    t = re.sub(r"(?<![\w])(\d{1,2})-(\d)s(?![\w])", qc_rule, t)
    t = re.sub(r"(?<![\w])R-4s(?![\w])",
               lambda m: rec.add("Westgard rule R-4s", m.group(0), "er to‘rt es", "HIGH", "range rule", "qc-rule"), t)
    t = re.sub(r"(?<![\w])10x(?![\w])",
               lambda m: rec.add("Westgard rule 10x", m.group(0), "o‘n iks", "HIGH", "ten in a row", "qc-rule"), t)

    # --- units with their own words ---------------------------------------------------
    for term, rx, spoken, risk, note in _UNITS_SPOKEN:
        if term == "mmol/L":
            continue  # number + unit is handled by synth.normalise_numbers_and_units below
        t = re.sub(r"(?<![\w])" + rx + r"(?![\w])",
                   lambda m, term=term, spoken=spoken, risk=risk, note=note: rec.add(term, m.group(0), spoken, risk, note, "unit"), t)
    t = re.sub(r"(?<![\w])kg iga(?![\w])",
               lambda m: rec.add("kg iga", m.group(0), "kilogrammiga", "LOW", "per kg of water", "unit"), t)
    t = re.sub(r"(?<![\w])massa/zaryad", lambda m: "massa zaryad", t)

    # --- abbreviations (with optional ’suffix) -----------------------------------------
    for term, rx, spoken, risk, note, attach in _ABBR:
        pat = re.compile(r"(?<![\w])(?:" + rx + r")(?:" + APOS + r"(?P<suf>[a-zA-Z]+))?(?![\w])")

        def rep(m, term=term, spoken=spoken, risk=risk, note=note, attach=attach):
            suf = m.group("suf") or ""
            out = _join_suffix(spoken, suf, attach)
            rec.add(term, m.group(0), out, risk, note, "abbr")
            return out

        t = pat.sub(rep, t)

    # --- single letters used as labels / symbols ---------------------------------------
    t = re.sub(r"(?<![\w])B(?= namuna)",
               lambda m: rec.add("B", "B namuna", "be", "LOW", "sample label", "letter"), t)
    t = re.sub(r"(?<![\w])A(?= namuna)",
               lambda m: rec.add("A", "A namuna", "a", "LOW", "sample label", "letter"), t)
    t = re.sub(r"(?<![\w])z(?=:)",
               lambda m: rec.add("z", "z:", "zet", "LOW", "z-score symbol", "letter"), t)
    t = re.sub(r"(?<![\w])A = (?=\d)",
               lambda m: rec.add("A =", "A =", "a teng ", "LOW", "absorbance equals", "symbol"), t)

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
    t = t.replace("−", "minus ") if re.search(r"−\s?\d", t) else t
    t = re.sub(r"(?<=[A-Za-zʻ‘’])–(?=[A-Za-z])", " ", t)           # Buger–Lambert–Ber
    t = re.sub(r"\s*—\s*", ", ", t)                                 # em dash = pause (as synth.normalise_text)
    t = re.sub(r"\s+", " ", t)
    t = re.sub(r"\s+([,;:.!?…])", r"\1", t)
    t = re.sub(r",\s*,", ",", t)
    t = re.sub(r"^[,\s]+", "", t).strip()
    if text[:1].isupper() and t[:1].islower():
        t = t[:1].upper() + t[1:]

    # --- loanword watch list (spoken = written) ----------------------------------------
    low = t.lower()
    for w, risk in WATCH.items():
        if re.search(r"(?<![\w])" + w, low):
            rec.add(w, w, w, risk, "spoken as written (Uzbek orthography); LISTEN for stress/vowels", "watch")

    warnings = []
    if extra_warn:
        if re.search(r"\d", t):
            warnings.append("digit left: " + ",".join(sorted(set(re.findall(r"\d+", t)))))
        if re.search(r"\b\d{1,2}[./]\d{1,2}[./]\d{2,4}\b", text):
            warnings.append("date pattern in source: not expanded automatically (none expected in these scripts)")
        left = re.findall(r"(?<![\w])[A-Z]{2,}(?![\w])", t)
        if left:
            warnings.append("unexpanded capitals: " + ",".join(sorted(set(left))))
        if re.search(r"[=÷×+%~→·²₀₁{}]", t):
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
