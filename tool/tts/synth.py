#!/usr/bin/env python3
"""LabGuide narration synthesiser (stdlib only; backends load their libs lazily).

    python3 tool/tts/synth.py script.json --out OUT_DIR --backend none
    python3 tool/tts/synth.py script.json --out OUT_DIR --backend piper  --voice-file en_US-ljspeech-medium.onnx
    python3 tool/tts/synth.py script.json --out OUT_DIR --backend kokoro --voice-file kokoro.onnx --voices-file voices.npz
    AZURE_SPEECH_KEY=... AZURE_SPEECH_REGION=... \
    python3 tool/tts/synth.py script.json --out OUT_DIR --backend azure

Script JSON:
    {"lang": "uz" | "en" | "ru",
     "voice": "uz-UZ-MadinaNeural",            # backend specific (optional)
     "gap_s": 0.35,                            # default pause after each line (optional)
     "lines": [{"id": "intro", "text": "...", "gap_s": 0.6}, ...]}

Output (OUT_DIR):
    <id>.wav            mono 16-bit PCM, one per line (also <id>.mp3 with --mp3, needs ffmpeg)
    manifest.json       timing manifest for the video compositor (see build_manifest)
    narration.wav       all lines concatenated with the gaps (with --concat)
    narration.srt       subtitles from the manifest (with --srt)

Backends
    none    silent placeholders with ESTIMATED durations (build videos before voices exist)
    stub    audible test tones, duration ~ text length (used by the unit tests)
    piper   local, needs `pip install piper-tts` and a voice .onnx (+ .onnx.json beside it)
    kokoro  local, needs `pip install kokoro-onnx soundfile`, a Kokoro ONNX model + voices file
    azure   Azure Speech REST (own key from env: AZURE_SPEECH_KEY, AZURE_SPEECH_REGION)
    silero  Silero v5_cis_base (MIT) incl. uzb_saida; needs `pip install silero torch` (NOT RUN in the
            report: torch was too big for the test box)

The pronunciation lexicon (tool/tts/lexicon/<lang>.json) is applied after text normalisation.
Nothing here ever upgrades or buys anything: Azure usage is counted locally and refused above a
safety limit (default 450 000 chars/month, F0 allowance is 500 000).
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import math
import os
import re
import shutil
import struct
import subprocess
import sys
import time
import unicodedata
import urllib.error
import urllib.request
import wave
import xml.sax.saxutils as _xml
from pathlib import Path

HERE = Path(__file__).resolve().parent
LEXICON_DIR = HERE / "lexicon"
SCHEMA = "labguide.tts.manifest/1"

# --------------------------------------------------------------------------- numbers

_EN_ONES = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
            "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen",
            "eighteen", "nineteen"]
_EN_TENS = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]

_UZ_ONES = ["nol", "bir", "ikki", "uch", "to‘rt", "besh", "olti", "yetti", "sakkiz", "to‘qqiz"]
_UZ_TENS = ["", "o‘n", "yigirma", "o‘ttiz", "qirq", "ellik", "oltmish", "yetmish", "sakson", "to‘qson"]

_RU_ONES_M = ["ноль", "один", "два", "три", "четыре", "пять", "шесть", "семь", "восемь", "девять",
              "десять", "одиннадцать", "двенадцать", "тринадцать", "четырнадцать", "пятнадцать",
              "шестнадцать", "семнадцать", "восемнадцать", "девятнадцать"]
_RU_ONES_F = list(_RU_ONES_M)
_RU_ONES_F[1], _RU_ONES_F[2] = "одна", "две"
_RU_TENS = ["", "", "двадцать", "тридцать", "сорок", "пятьдесят", "шестьдесят", "семьдесят",
            "восемьдесят", "девяносто"]
_RU_HUND = ["", "сто", "двести", "триста", "четыреста", "пятьсот", "шестьсот", "семьсот",
            "восемьсот", "девятьсот"]


def _en_int(n: int) -> str:
    if n < 20:
        return _EN_ONES[n]
    if n < 100:
        t, o = divmod(n, 10)
        return _EN_TENS[t] + ("-" + _EN_ONES[o] if o else "")
    if n < 1000:
        h, r = divmod(n, 100)
        return _EN_ONES[h] + " hundred" + (" " + _en_int(r) if r else "")
    for size, name in ((10**9, "billion"), (10**6, "million"), (1000, "thousand")):
        if n >= size:
            q, r = divmod(n, size)
            return _en_int(q) + " " + name + (" " + _en_int(r) if r else "")
    raise ValueError(n)


def _uz_int(n: int) -> str:
    if n < 10:
        return _UZ_ONES[n]
    if n < 100:
        t, o = divmod(n, 10)
        return _UZ_TENS[t] + (" " + _UZ_ONES[o] if o else "")
    if n < 1000:
        h, r = divmod(n, 100)
        head = "yuz" if h == 1 else _UZ_ONES[h] + " yuz"
        return head + (" " + _uz_int(r) if r else "")
    for size, name in ((10**9, "milliard"), (10**6, "million"), (1000, "ming")):
        if n >= size:
            q, r = divmod(n, size)
            head = name if (q == 1 and size == 1000) else _uz_int(q) + " " + name
            return head + (" " + _uz_int(r) if r else "")
    raise ValueError(n)


def _ru_plural(n: int, forms: tuple[str, str, str]) -> str:
    n = abs(n) % 100
    if 11 <= n <= 19:
        return forms[2]
    n %= 10
    if n == 1:
        return forms[0]
    if 2 <= n <= 4:
        return forms[1]
    return forms[2]


def _ru_int(n: int, fem: bool = False) -> str:
    if n < 20:
        return (_RU_ONES_F if fem else _RU_ONES_M)[n]
    if n < 100:
        t, o = divmod(n, 10)
        return _RU_TENS[t] + (" " + _ru_int(o, fem) if o else "")
    if n < 1000:
        h, r = divmod(n, 100)
        return _RU_HUND[h] + (" " + _ru_int(r, fem) if r else "")
    scales = ((10**9, ("миллиард", "миллиарда", "миллиардов"), False),
              (10**6, ("миллион", "миллиона", "миллионов"), False),
              (1000, ("тысяча", "тысячи", "тысяч"), True))
    for size, forms, f in scales:
        if n >= size:
            q, r = divmod(n, size)
            return _ru_int(q, f) + " " + _ru_plural(q, forms) + (" " + _ru_int(r, fem) if r else "")
    raise ValueError(n)


def int_to_words(n: int, lang: str, fem: bool = False) -> str:
    if n < 0:
        return {"en": "minus ", "uz": "minus ", "ru": "минус "}[lang] + int_to_words(-n, lang, fem)
    if n >= 10**12:
        return " ".join(int_to_words(int(d), lang) for d in str(n))  # read digit by digit
    if lang == "en":
        return _en_int(n)
    if lang == "uz":
        return _uz_int(n)
    if lang == "ru":
        return _ru_int(n, fem)
    raise ValueError(f"unsupported lang {lang!r}")


def _digits(s: str, lang: str) -> str:
    return " ".join(int_to_words(int(d), lang) for d in s)


def decimal_to_words(whole: str, frac: str, lang: str) -> str:
    """3,5 -> 'three point five' / 'uch butun o‘ndan besh' / 'три целых пять десятых'."""
    w = int(whole)
    f = int(frac)
    if lang == "en":
        return int_to_words(w, "en") + " point " + _digits(frac, "en")
    if lang == "uz":
        den = {1: "o‘ndan", 2: "yuzdan", 3: "mingdan"}.get(len(frac))
        if den is None:
            return int_to_words(w, "uz") + " butun " + _digits(frac, "uz")
        return int_to_words(w, "uz") + " butun " + den + " " + int_to_words(f, "uz")
    if lang == "ru":
        names = {1: ("десятая", "десятых"), 2: ("сотая", "сотых"), 3: ("тысячная", "тысячных")}
        whole_forms = ("целая", "целых", "целых")
        wtxt = _ru_int(w, True) + " " + ("целая" if (w % 10 == 1 and w % 100 != 11) else "целых")
        if len(frac) in names:
            one, many = names[len(frac)]
            ftxt = _ru_int(f, True) + " " + (one if (f % 10 == 1 and f % 100 != 11) else many)
            return wtxt + " " + ftxt
        return wtxt + " " + _digits(frac, "ru")
    raise ValueError(lang)


# --------------------------------------------------------------------------- units

# (symbol regex without trailing boundary) -> words per language. Longest first on purpose.
# ru entries are (nominative-singular, genitive-singular(2-4), genitive-plural(5+)).
_UNITS = {
    "mmol/L": {"en": "millimoles per litre", "uz": "millimol litr",
               "ru": ("миллимоль на литр", "миллимоля на литр", "миллимолей на литр")},
    "mg/dL": {"en": "milligrams per decilitre", "uz": "milligramm detsilitr",
              "ru": ("миллиграмм на децилитр", "миллиграмма на децилитр", "миллиграммов на децилитр")},
    "g/dL": {"en": "grams per decilitre", "uz": "gramm detsilitr",
             "ru": ("грамм на децилитр", "грамма на децилитр", "граммов на децилитр")},
    "g/L": {"en": "grams per litre", "uz": "gramm litr",
            "ru": ("грамм на литр", "грамма на литр", "граммов на литр")},
    "U/L": {"en": "units per litre", "uz": "birlik litr",
            "ru": ("единица на литр", "единицы на литр", "единиц на литр")},
    "IU/L": {"en": "international units per litre", "uz": "xalqaro birlik litr",
             "ru": ("международная единица на литр", "международные единицы на литр",
                    "международных единиц на литр")},
    "µmol/L": {"en": "micromoles per litre", "uz": "mikromol litr",
               "ru": ("микромоль на литр", "микромоля на литр", "микромолей на литр")},
    "mg": {"en": "milligrams", "uz": "milligramm",
           "ru": ("миллиграмм", "миллиграмма", "миллиграммов")},
    "µg": {"en": "micrograms", "uz": "mikrogramm", "ru": ("микрограмм", "микрограмма", "микрограммов")},
    "kg": {"en": "kilograms", "uz": "kilogramm", "ru": ("килограмм", "килограмма", "килограммов")},
    "µL": {"en": "microlitres", "uz": "mikrolitr", "ru": ("микролитр", "микролитра", "микролитров")},
    "ul": {"en": "microlitres", "uz": "mikrolitr", "ru": ("микролитр", "микролитра", "микролитров")},
    "mL": {"en": "millilitres", "uz": "millilitr", "ru": ("миллилитр", "миллилитра", "миллилитров")},
    "ml": {"en": "millilitres", "uz": "millilitr", "ru": ("миллилитр", "миллилитра", "миллилитров")},
    "dL": {"en": "decilitres", "uz": "detsilitr", "ru": ("децилитр", "децилитра", "децилитров")},
    "fL": {"en": "femtolitres", "uz": "femtolitr", "ru": ("фемтолитр", "фемтолитра", "фемтолитров")},
    "pg": {"en": "picograms", "uz": "pikogramm", "ru": ("пикограмм", "пикограмма", "пикограммов")},
    "nm": {"en": "nanometres", "uz": "nanometr", "ru": ("нанометр", "нанометра", "нанометров")},
    "mm": {"en": "millimetres", "uz": "millimetr", "ru": ("миллиметр", "миллиметра", "миллиметров")},
    "cm": {"en": "centimetres", "uz": "santimetr", "ru": ("сантиметр", "сантиметра", "сантиметров")},
    "rpm": {"en": "revolutions per minute", "uz": "daqiqada aylanish",
            "ru": ("оборот в минуту", "оборота в минуту", "оборотов в минуту")},
    "min": {"en": "minutes", "uz": "daqiqa", "ru": ("минута", "минуты", "минут")},
    "°C": {"en": "degrees Celsius", "uz": "daraja Tselsiy",
           "ru": ("градус Цельсия", "градуса Цельсия", "градусов Цельсия")},
    "%": {"en": "percent", "uz": "foiz", "ru": ("процент", "процента", "процентов")},
    "s": {"en": "seconds", "uz": "soniya", "ru": ("секунда", "секунды", "секунд")},
    "L": {"en": "litres", "uz": "litr", "ru": ("литр", "литра", "литров")},
    "g": {"en": "grams", "uz": "gramm", "ru": ("грамм", "грамма", "граммов")},
}
# Cyrillic aliases (Russian scripts often write units in Russian letters)
for _alias, _key in {"мл": "mL", "мг": "mg", "мкл": "µL", "мкг": "µg", "дл": "dL", "нм": "nm", "мм": "mm",
                     "см": "cm", "кг": "kg", "г/дл": "g/dL", "г/л": "g/L", "мг/дл": "mg/dL",
                     "ммоль/л": "mmol/L", "мкмоль/л": "µmol/L", "мин": "min", "°С": "°C",
                     "г": "g", "л": "L", "фл": "fL", "пг": "pg"}.items():
    _UNITS[_alias] = _UNITS[_key]
_RU_FEM_UNITS = {"минута", "секунда", "единица на литр", "международная единица на литр"}
_UNIT_KEYS = sorted(_UNITS, key=len, reverse=True)
_UNIT_RE = "|".join(re.escape(k) for k in _UNIT_KEYS)
# number, optional space, unit (word boundary after letter units; % and °C need none)
_NUM_UNIT = re.compile(
    r"(?<![\w.,])(?P<neg>[-−])?(?P<int>\d{1,12})(?:(?P<sep>[.,])(?P<frac>\d{1,6}))?\s?"
    r"(?P<unit>" + _UNIT_RE + r")(?![\w])")
_NUM = re.compile(r"(?<![\w.,])(?P<neg>[-−])?(?P<int>\d{1,12})(?:(?P<sep>[.,])(?P<frac>\d{1,6}))?(?![\w])")


def _unit_words(unit: str, lang: str, count: int, is_decimal: bool) -> str:
    u = _UNITS[unit][lang]
    if lang == "ru":
        if is_decimal:
            return u[1]
        return _ru_plural(count, u)
    if lang == "en":
        if not is_decimal and count == 1:
            first, _, rest = u.partition(" ")
            if first.endswith("s") and first != "s":
                first = first[:-1]
            return (first + " " + rest).strip()
        return u
    return u


def normalise_numbers_and_units(text: str, lang: str) -> str:
    def with_unit(m: re.Match) -> str:
        whole, frac, unit = m.group("int"), m.group("frac"), m.group("unit")
        neg = "minus " if m.group("neg") and lang != "ru" else ("минус " if m.group("neg") else "")
        if frac:
            words = decimal_to_words(whole, frac, lang)
            return neg + words + " " + _unit_words(unit, lang, int(whole), True)
        fem = lang == "ru" and _UNITS[unit]["ru"][0] in _RU_FEM_UNITS
        words = int_to_words(int(whole), lang, fem=fem)
        return neg + words + " " + _unit_words(unit, lang, int(whole), False)

    text = _NUM_UNIT.sub(with_unit, text)

    def plain(m: re.Match) -> str:
        whole, frac = m.group("int"), m.group("frac")
        neg = {"en": "minus ", "uz": "minus ", "ru": "минус "}[lang] if m.group("neg") else ""
        if frac:
            return neg + decimal_to_words(whole, frac, lang)
        if len(whole) > 1 and whole.startswith("0"):
            return neg + _digits(whole, lang)
        return neg + int_to_words(int(whole), lang)

    return _NUM.sub(plain, text)


# --------------------------------------------------------------------------- uzbek script

_UZ_APOS = "‘’ʻʼʹ`´′ˈ'"
_UZ_APOS_RE = re.compile(r"(?i)([ogОГ])[" + re.escape(_UZ_APOS) + r"]")
_UZ_TSE_RE = re.compile(r"(?i)([a-z])[" + re.escape(_UZ_APOS) + r"](?=[a-z])")  # a'zo, ma'no, san'at


def normalise_uz_apostrophes(text: str, style: str = "'") -> str:
    """o‘ g‘ -> style+o/g; tutuq belgisi (ma’no, a’zo) -> style as well.

    style: "'" (ASCII, default), "‘" (U+2018, what the app texts use) or "ʻ" (U+02BB, official).
    """
    text = _UZ_APOS_RE.sub(lambda m: m.group(1) + style, text)
    text = _UZ_TSE_RE.sub(lambda m: m.group(1) + style, text)
    return text


_UZ_LAT2CYR = [  # order matters (digraphs first); input is lower-cased with ASCII apostrophe
    ("o'", "ў"), ("g'", "ғ"), ("sh", "ш"), ("ch", "ч"), ("ng", "нг"), ("ts", "ц"), ("yo", "ё"), ("yu", "ю"),
    ("ya", "я"), ("ye", "е"), ("a", "а"), ("b", "б"), ("d", "д"), ("f", "ф"), ("g", "г"), ("h", "ҳ"),
    ("i", "и"), ("j", "ж"), ("k", "к"), ("l", "л"), ("m", "м"), ("n", "н"), ("o", "о"), ("p", "п"),
    ("q", "қ"), ("r", "р"), ("s", "с"), ("t", "т"), ("u", "у"), ("v", "в"), ("x", "х"), ("y", "й"),
    ("z", "з"), ("c", "ц"), ("w", "в"), ("'", "ъ"),
]


def uz_latin_to_cyrillic(text: str) -> str:
    """Rough Latin -> Cyrillic mapping for Cyrillic-first engines (Silero). Azure does not need it.

    Not a full transliteration standard: e -> э only at word start, ts -> ц, apostrophe -> ъ.
    Unverified by a native speaker; check the output before relying on it.
    """
    s = normalise_uz_apostrophes(text.lower(), "'")
    out, i = [], 0
    while i < len(s):
        if s[i] == "e":
            out.append("э" if i == 0 or not (s[i - 1].isalpha() or s[i - 1] == "'") else "е")
            i += 1
            continue
        for lat, cyr in _UZ_LAT2CYR:
            if s.startswith(lat, i):
                out.append(cyr)
                i += len(lat)
                break
        else:
            out.append(s[i])
            i += 1
    return "".join(out)


# --------------------------------------------------------------------------- lexicon

def load_lexicon(lang: str, extra: list[str | Path] | None = None) -> dict:
    """Merge lexicon/<lang>.json with optional extra files. Returns {key_lower: str|dict}."""
    entries: dict = {}
    paths = []
    base = LEXICON_DIR / f"{lang}.json"
    if base.exists():
        paths.append(base)
    paths += [Path(p) for p in (extra or [])]
    for p in paths:
        data = json.loads(Path(p).read_text(encoding="utf-8"))
        for k, v in data.get("entries", {}).items():
            entries[k.lower()] = v
    return entries


def apply_lexicon(text: str, entries: dict, backend: str = "default") -> str:
    """Whole-word / whole-phrase, case-insensitive replacement, longest keys first.

    A value is either a string, or {"default": "...", "azure": "...", "piper": "..."}.
    """
    if not entries:
        return text
    keys = sorted(entries, key=len, reverse=True)
    pat = re.compile(r"(?<![\w])(" + "|".join(re.escape(k) for k in keys) + r")(?![\w])", re.IGNORECASE)

    def rep(m: re.Match) -> str:
        v = entries[m.group(1).lower()]
        if isinstance(v, dict):
            return v.get(backend, v.get("default", m.group(0)))
        return v

    return pat.sub(rep, text)


# --------------------------------------------------------------------------- text pipeline

def normalise_text(text: str, lang: str, uz_apostrophe: str = "'") -> str:
    t = unicodedata.normalize("NFC", text)
    t = t.replace(" ", " ").replace(" ", " ")
    if lang == "ru":
        t = t.replace("—", " — ").replace("–", "-")
    else:
        t = re.sub(r"\s*—\s*", ", ", t).replace("–", "-")
    t = normalise_numbers_and_units(t, lang)
    if lang == "uz":  # after numbers: number words contain o‘ too
        t = normalise_uz_apostrophes(t, uz_apostrophe)
    t = re.sub(r"\s+", " ", t).strip()
    t = re.sub(r"\s+([,;:.!?])", r"\1", t)
    return t


def prepare_text(text: str, lang: str, backend: str = "default", lexicon: dict | None = None,
                 uz_apostrophe: str = "'") -> str:
    t = normalise_text(text, lang, uz_apostrophe)
    t = apply_lexicon(t, lexicon if lexicon is not None else load_lexicon(lang), backend)
    return re.sub(r"\s+", " ", t).strip()


# --------------------------------------------------------------------------- wav helpers

def pcm_to_wav_bytes(pcm: bytes, sr: int) -> bytes:
    buf = io.BytesIO()
    with wave.open(buf, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(pcm)
    return buf.getvalue()


def wav_bytes_to_pcm(data: bytes) -> tuple[bytes, int]:
    with wave.open(io.BytesIO(data), "rb") as w:
        if w.getsampwidth() != 2:
            raise ValueError("expected 16-bit PCM")
        pcm = w.readframes(w.getnframes())
        sr = w.getframerate()
        if w.getnchannels() == 2:  # down-mix
            import array
            a = array.array("h")
            a.frombytes(pcm)
            pcm = array.array("h", [(a[i] + a[i + 1]) // 2 for i in range(0, len(a) - 1, 2)]).tobytes()
        return pcm, sr


def silence_pcm(seconds: float, sr: int) -> bytes:
    return b"\x00\x00" * int(round(seconds * sr))


# --------------------------------------------------------------------------- backends

class Backend:
    name = "base"
    estimated = False

    def synthesize(self, text: str, lang: str, voice: str | None) -> tuple[bytes, int]:
        """Return (16-bit mono PCM bytes, sample_rate)."""
        raise NotImplementedError

    def cache_key_extra(self) -> str:
        return ""


# chars per second used for estimates (typical calm narration)
_CPS = {"en": 15.0, "ru": 14.0, "uz": 13.0}


def estimate_duration(text: str, lang: str) -> float:
    cps = _CPS.get(lang, 14.0)
    words = len(text.split())
    secs = max(len(text) / cps, words / 2.6)  # whichever is slower
    secs += 0.25 * len(re.findall(r"[.!?;:]", text)) + 0.12 * len(re.findall(r",", text))
    return round(max(0.8, secs), 2)


class NoneBackend(Backend):
    name = "none"
    estimated = True

    def __init__(self, sample_rate: int = 24000):
        self.sr = sample_rate

    def synthesize(self, text, lang, voice):
        return silence_pcm(estimate_duration(text, lang), self.sr), self.sr


class StubBackend(Backend):
    """Audible 220 Hz tone, 0.06 s per character (deterministic; for tests)."""
    name = "stub"

    def __init__(self, sample_rate: int = 16000, sec_per_char: float = 0.06):
        self.sr, self.spc = sample_rate, sec_per_char
        self.calls: list[tuple[str, str, str | None]] = []

    def synthesize(self, text, lang, voice):
        self.calls.append((text, lang, voice))
        n = int(self.sr * max(0.1, len(text) * self.spc))
        pcm = struct.pack("<%dh" % n, *[int(8000 * math.sin(2 * math.pi * 220 * i / self.sr)) for i in range(n)])
        return pcm, self.sr


class PiperBackend(Backend):
    name = "piper"

    def __init__(self, voice_file: str, speaker_id: int | None = None, length_scale: float | None = None):
        from piper import PiperVoice  # type: ignore
        from piper.config import SynthesisConfig  # type: ignore
        p = Path(voice_file)
        self.voice = PiperVoice.load(p, config_path=p.with_suffix(p.suffix + ".json"))
        self.cfg = SynthesisConfig(speaker_id=speaker_id, length_scale=length_scale)
        self.voice_name = p.name
        self.sr = self.voice.config.sample_rate

    def synthesize(self, text, lang, voice):
        chunks = [c.audio_int16_bytes for c in self.voice.synthesize(text, self.cfg)]
        return b"".join(chunks), self.sr

    def cache_key_extra(self):
        return self.voice_name


class KokoroBackend(Backend):
    name = "kokoro"
    _LANG = {"en": "en-us"}

    def __init__(self, model_file: str, voices_file: str, speed: float = 1.0):
        from kokoro_onnx import Kokoro  # type: ignore
        self.k = Kokoro(model_file, voices_file)
        self.speed = speed
        self.model_name = Path(model_file).name

    def synthesize(self, text, lang, voice):
        if lang not in self._LANG:
            raise SystemExit("Kokoro has no voices for language %r (English only here)" % lang)
        import numpy as np  # type: ignore
        audio, sr = self.k.create(text, voice=voice or "af_heart", speed=self.speed, lang=self._LANG[lang])
        pcm = (np.clip(audio, -1, 1) * 32767).astype("<i2").tobytes()
        return pcm, sr

    def cache_key_extra(self):
        return self.model_name


class SileroBackend(Backend):
    """Silero v5_cis_base (MIT) -> speaker 'uzb_saida' (Uzbek), 'ru_*' for Russian.

    NOT RUN in the report (needs torch). The Silero README says Uzbek works in both alphabets, but
    its Latin alphabet list has no apostrophe (o' g'), so Uzbek text is converted to Cyrillic here
    with uz_latin_to_cyrillic(), matching the Cyrillic example in Silero's CIS notebook.
    """
    name = "silero"

    def __init__(self, model_id: str = "v5_cis_base_nostress", sample_rate: int = 48000):
        import torch  # type: ignore
        from silero import silero_tts  # type: ignore
        self.torch = torch
        self.model, _ = silero_tts(language="ru", speaker=model_id)
        self.model.to(torch.device("cpu"))
        self.sr = sample_rate
        self.model_id = model_id

    def synthesize(self, text, lang, voice):
        default = {"uz": "uzb_saida", "ru": "ru_zhadyra"}.get(lang)
        spk = voice or default
        if not spk:
            raise SystemExit("Silero: no default speaker for lang %r" % lang)
        if lang == "uz":  # Silero's own examples feed Uzbek as Cyrillic; Latin letters set has no o' g' mark
            text = uz_latin_to_cyrillic(text)
        audio = self.model.apply_tts(text=text, speaker=spk, sample_rate=self.sr)
        arr = audio.detach().cpu().numpy() if hasattr(audio, "detach") else audio
        import numpy as np  # type: ignore
        return (np.clip(arr, -1, 1) * 32767).astype("<i2").tobytes(), self.sr

    def cache_key_extra(self):
        return self.model_id


AZURE_DEFAULT_VOICES = {"uz": "uz-UZ-MadinaNeural", "ru": "ru-RU-SvetlanaNeural", "en": "en-US-JennyNeural"}
AZURE_LOCALE = {"uz": "uz-UZ", "ru": "ru-RU", "en": "en-US"}
AZURE_FORMAT = "riff-24khz-16bit-mono-pcm"
USAGE_FILE = Path(os.environ.get("LABGUIDE_TTS_USAGE_FILE", Path.home() / ".labguide_tts_azure_usage.json"))


class QuotaGuard:
    """Local monthly character counter. Refuses to call the API above `limit` characters.

    This is a safety net only; the authoritative counter is the Azure portal. It never changes the
    pricing tier of anything.
    """

    def __init__(self, path: Path = USAGE_FILE, limit: int = 450_000, now=time.gmtime):
        self.path, self.limit, self.now = Path(path), limit, now

    def _month(self) -> str:
        t = self.now()
        return "%04d-%02d" % (t.tm_year, t.tm_mon)

    def used(self) -> int:
        try:
            return int(json.loads(self.path.read_text()).get(self._month(), 0))
        except (OSError, ValueError):
            return 0

    def check(self, chars: int) -> None:
        if self.used() + chars > self.limit:
            raise SystemExit(
                "Azure local quota guard: %d + %d chars would exceed the safety limit %d for %s. "
                "Not calling the API. (Azure F0 allows 500 000 chars/month; raise --azure-char-limit only "
                "if you checked the portal. This tool never upgrades your plan.)"
                % (self.used(), chars, self.limit, self._month()))

    def add(self, chars: int) -> None:
        try:
            data = json.loads(self.path.read_text())
        except (OSError, ValueError):
            data = {}
        data[self._month()] = int(data.get(self._month(), 0)) + chars
        try:
            self.path.parent.mkdir(parents=True, exist_ok=True)
            self.path.write_text(json.dumps(data))
        except OSError:
            pass


def default_http_post(url: str, headers: dict, body: bytes, timeout: float = 60.0) -> tuple[int, bytes, dict]:
    req = urllib.request.Request(url, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, r.read(), dict(r.headers)
    except urllib.error.HTTPError as e:
        return e.code, e.read(), dict(e.headers or {})


class AzureBackend(Backend):
    """Azure Speech REST API (works on the Free F0 tier with the owner's own key).

    Env: AZURE_SPEECH_KEY, AZURE_SPEECH_REGION (e.g. westeurope). Uzbek voices
    uz-UZ-MadinaNeural (F) / uz-UZ-SardorNeural (M). SSML <phoneme> and custom lexicon are NOT
    supported for uz-UZ (Microsoft language-support table), so respellings must be plain text.
    """
    name = "azure"

    def __init__(self, key: str | None = None, region: str | None = None, http_post=default_http_post,
                 guard: QuotaGuard | None = None, min_interval_s: float = 3.2, max_retries: int = 4,
                 sleep=time.sleep, rate: str | None = None):
        self.key = key or os.environ.get("AZURE_SPEECH_KEY", "")
        self.region = region or os.environ.get("AZURE_SPEECH_REGION", "")
        if not self.key or not self.region:
            raise SystemExit("Azure backend needs AZURE_SPEECH_KEY and AZURE_SPEECH_REGION in the environment "
                             "(create a free F0 Speech resource in your own Azure account; see "
                             "docs/video/tts/VOICE_DECISION.md). Nothing was sent.")
        if not re.fullmatch(r"[a-z0-9-]{3,40}", self.region):
            raise SystemExit("AZURE_SPEECH_REGION looks wrong: %r" % self.region)
        self.http_post, self.guard = http_post, guard or QuotaGuard()
        self.min_interval, self.max_retries, self.sleep = min_interval_s, max_retries, sleep
        self.rate = rate  # e.g. "-5%" for slightly slower narration
        self._last = 0.0
        self.chars_sent = 0

    @staticmethod
    def build_ssml(text: str, lang: str, voice: str, rate: str | None = None) -> str:
        inner = _xml.escape(text)
        if rate:
            inner = '<prosody rate="%s">%s</prosody>' % (_xml.escape(rate, {'"': "&quot;"}), inner)
        return ("<speak version='1.0' xml:lang='%s'><voice name='%s'>%s</voice></speak>"
                % (AZURE_LOCALE.get(lang, lang), _xml.escape(voice, {"'": "&apos;"}), inner))

    def synthesize(self, text, lang, voice):
        voice = voice or AZURE_DEFAULT_VOICES[lang]
        ssml = self.build_ssml(text, lang, voice, self.rate)
        url = "https://%s.tts.speech.microsoft.com/cognitiveservices/v1" % self.region
        headers = {"Ocp-Apim-Subscription-Key": self.key, "Content-Type": "application/ssml+xml",
                   "X-Microsoft-OutputFormat": AZURE_FORMAT, "User-Agent": "labguide-tts/1"}
        self.guard.check(len(text))
        for attempt in range(self.max_retries + 1):
            wait = self.min_interval - (time.monotonic() - self._last)
            if wait > 0:
                self.sleep(wait)
            self._last = time.monotonic()
            status, data, hdrs = self.http_post(url, headers, ssml.encode("utf-8"))
            if status == 200:
                self.guard.add(len(text))
                self.chars_sent += len(text)
                return wav_bytes_to_pcm(data)
            if status in (429, 503) and attempt < self.max_retries:
                ra = hdrs.get("Retry-After") or hdrs.get("retry-after")
                self.sleep(float(ra) if ra and ra.replace(".", "").isdigit() else 5.0 * (2 ** attempt))
                continue
            if status in (401, 403):
                raise SystemExit("Azure rejected the key/region (HTTP %d). If the free quota is used up "
                                 "Azure answers 403/429: wait for next month or ask the owner; this tool "
                                 "does not upgrade anything. Body: %s" % (status, data[:200]))
            raise SystemExit("Azure TTS HTTP %d: %s" % (status, data[:300]))
        raise SystemExit("Azure TTS: retries exhausted (HTTP 429/503). Try again later.")

    def cache_key_extra(self):
        return "azure"


def make_backend(name: str, args) -> Backend:
    if name == "none":
        return NoneBackend()
    if name == "stub":
        return StubBackend()
    if name == "piper":
        if not args.voice_file:
            raise SystemExit("--voice-file PATH.onnx is required for the piper backend")
        return PiperBackend(args.voice_file, args.speaker_id, args.length_scale)
    if name == "kokoro":
        if not (args.voice_file and args.voices_file):
            raise SystemExit("--voice-file MODEL.onnx and --voices-file VOICES.npz are required for kokoro")
        return KokoroBackend(args.voice_file, args.voices_file)
    if name == "azure":
        return AzureBackend(rate=args.azure_rate, guard=QuotaGuard(limit=args.azure_char_limit),
                            min_interval_s=args.azure_min_interval)
    if name == "silero":
        return SileroBackend()
    raise SystemExit("unknown backend %r" % name)


# --------------------------------------------------------------------------- core

def validate_script(script: dict) -> None:
    if script.get("lang") not in ("uz", "en", "ru"):
        raise ValueError("script.lang must be one of uz, en, ru")
    lines = script.get("lines")
    if not isinstance(lines, list) or not lines:
        raise ValueError("script.lines must be a non-empty list")
    seen = set()
    for ln in lines:
        lid, txt = ln.get("id"), ln.get("text")
        if not isinstance(lid, str) or not re.fullmatch(r"[A-Za-z0-9_.-]{1,64}", lid):
            raise ValueError("bad line id %r (use A-Z a-z 0-9 _ . -)" % (lid,))
        if lid in seen:
            raise ValueError("duplicate line id %r" % lid)
        seen.add(lid)
        if not isinstance(txt, str) or not txt.strip():
            raise ValueError("line %r has empty text" % lid)


def _cache_key(spoken: str, lang: str, voice: str | None, backend: Backend) -> str:
    h = hashlib.sha256("\x1f".join([backend.name, backend.cache_key_extra(), lang, voice or "", spoken])
                       .encode("utf-8")).hexdigest()
    return h[:24]


def build_manifest(script: dict, backend: Backend, items: list[dict], sample_rate: int) -> dict:
    """Manifest consumed by the video compositor.

    lines[i]: id, text (original), spoken_text (after normalise+lexicon), file, start, end, duration,
              gap_after, estimated (True for the 'none' backend - durations are guesses).
    Times are seconds on one continuous timeline: start[0]=0, start[i+1]=end[i]+gap_after[i].
    """
    return {
        "schema": SCHEMA,
        "lang": script["lang"],
        "backend": backend.name,
        "voice": script.get("voice"),
        "sample_rate": sample_rate,
        "estimated": backend.estimated,
        "total_duration": round(items[-1]["end"], 3) if items else 0.0,
        "lines": items,
    }


def synth_script(script: dict, out_dir: str | Path, backend: Backend, *, voice: str | None = None,
                 lexicon: dict | None = None, uz_apostrophe: str = "'", default_gap: float | None = None,
                 concat: bool = False, mp3: bool = False, srt: bool = False, use_cache: bool = True,
                 target_sr: int | None = None) -> dict:
    validate_script(script)
    lang = script["lang"]
    voice = voice or script.get("voice")
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    cache = out / ".cache"
    gap_default = default_gap if default_gap is not None else float(script.get("gap_s", 0.35))
    lex = lexicon if lexicon is not None else load_lexicon(lang, script.get("lexicon_files"))
    items, t, sr_seen, parts = [], 0.0, None, []
    for ln in script["lines"]:
        spoken = prepare_text(ln["text"], lang, backend.name, lex, uz_apostrophe)
        key = _cache_key(spoken, lang, voice, backend)
        cfile = cache / (key + ".wav")
        if use_cache and backend.name not in ("none", "stub") and cfile.exists():
            pcm, sr = wav_bytes_to_pcm(cfile.read_bytes())
        else:
            pcm, sr = backend.synthesize(spoken, lang, voice)
            if use_cache and backend.name not in ("none", "stub"):
                cache.mkdir(exist_ok=True)
                cfile.write_bytes(pcm_to_wav_bytes(pcm, sr))
        if sr_seen is None:
            sr_seen = sr
        elif sr != sr_seen:
            raise RuntimeError("sample rate changed between lines (%d vs %d)" % (sr_seen, sr))
        dur = len(pcm) / 2 / sr
        gap = float(ln.get("gap_s", gap_default))
        fname = ln["id"] + ".wav"
        (out / fname).write_bytes(pcm_to_wav_bytes(pcm, sr))
        if mp3:
            _to_mp3(out / fname, out / (ln["id"] + ".mp3"))
        items.append({"id": ln["id"], "text": ln["text"], "spoken_text": spoken, "file": fname,
                      "start": round(t, 3), "end": round(t + dur, 3), "duration": round(dur, 3),
                      "gap_after": gap, "estimated": backend.estimated})
        parts.append((pcm, gap))
        t += dur + gap
    # last line has no trailing gap on the timeline
    manifest = build_manifest(script, backend, items, sr_seen or 0)
    manifest["voice"] = voice
    (out / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    if concat:
        sr = sr_seen
        buf = bytearray()
        for i, (pcm, gap) in enumerate(parts):
            buf += pcm
            if i < len(parts) - 1:
                buf += silence_pcm(gap, sr)
        (out / "narration.wav").write_bytes(pcm_to_wav_bytes(bytes(buf), sr))
    if srt:
        (out / "narration.srt").write_text(manifest_to_srt(manifest), encoding="utf-8")
    return manifest


def _to_mp3(src: Path, dst: Path) -> None:
    if not shutil.which("ffmpeg"):
        raise SystemExit("--mp3 needs ffmpeg on PATH")
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(src), "-codec:a", "libmp3lame",
                    "-q:a", "2", str(dst)], check=True)


def _srt_time(s: float) -> str:
    ms = int(round(s * 1000))
    h, ms = divmod(ms, 3600000)
    m, ms = divmod(ms, 60000)
    sec, ms = divmod(ms, 1000)
    return "%02d:%02d:%02d,%03d" % (h, m, sec, ms)


def manifest_to_srt(manifest: dict) -> str:
    out = []
    for i, ln in enumerate(manifest["lines"], 1):
        out.append("%d\n%s --> %s\n%s\n" % (i, _srt_time(ln["start"]), _srt_time(ln["end"]), ln["text"]))
    return "\n".join(out)


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("script", help="script JSON")
    ap.add_argument("--out", required=True, help="output directory")
    ap.add_argument("--backend", choices=["none", "stub", "piper", "kokoro", "azure", "silero"], default="none")
    ap.add_argument("--voice", help="voice name (overrides script.voice)")
    ap.add_argument("--voice-file", help="piper .onnx / kokoro model .onnx")
    ap.add_argument("--voices-file", help="kokoro voices .npz")
    ap.add_argument("--speaker-id", type=int)
    ap.add_argument("--length-scale", type=float, help="piper: >1 slower")
    ap.add_argument("--lexicon", action="append", default=[], help="extra lexicon JSON (repeatable)")
    ap.add_argument("--uz-apostrophe", default="'", help="apostrophe used for o' g' in Uzbek text (default ASCII ')")
    ap.add_argument("--gap", type=float, help="default pause after each line (s)")
    ap.add_argument("--concat", action="store_true")
    ap.add_argument("--mp3", action="store_true")
    ap.add_argument("--srt", action="store_true")
    ap.add_argument("--no-cache", action="store_true")
    ap.add_argument("--azure-rate", help='SSML prosody rate, e.g. "-5%%"')
    ap.add_argument("--azure-char-limit", type=int, default=450_000)
    ap.add_argument("--azure-min-interval", type=float, default=3.2,
                    help="seconds between Azure calls (F0 allows 20 requests/60 s)")
    ap.add_argument("--dry-run", action="store_true", help="print the spoken text of each line and exit")
    a = ap.parse_args(argv)
    script = json.loads(Path(a.script).read_text(encoding="utf-8"))
    validate_script(script)
    lex = load_lexicon(script["lang"], list(script.get("lexicon_files", [])) + a.lexicon)
    if a.dry_run:
        for ln in script["lines"]:
            print(ln["id"], "|", prepare_text(ln["text"], script["lang"], a.backend, lex, a.uz_apostrophe))
        return 0
    backend = make_backend(a.backend, a)
    m = synth_script(script, a.out, backend, voice=a.voice, lexicon=lex, uz_apostrophe=a.uz_apostrophe,
                     default_gap=a.gap, concat=a.concat, mp3=a.mp3, srt=a.srt, use_cache=not a.no_cache)
    print("wrote %d lines, %.2f s total%s -> %s" % (len(m["lines"]), m["total_duration"],
          " (ESTIMATED durations)" if m["estimated"] else "", Path(a.out) / "manifest.json"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
