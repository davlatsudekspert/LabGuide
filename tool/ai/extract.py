"""LabGuide kontent elementlarini AI sharhi uchun ajratib olish (tarmoqsiz).

Manbalar:
  * assets/content/core/pack.json  — analitlar, holatlar (conditions), testlar (quiz);
  * lib/features/{cytology,spermogram,bloodgroup}/*.dart — `LocalizedText` /
    `CalcRef` / `CalcSource` tuzilmalari (yengil Dart tokenizeri bilan).

Hamma narsa bitta "element" (item) shaklida qaytariladi:

    {"id", "domain", "title", "texts": [{"field", "uz", "ru", "en", ...}],
     "refs": [{"source_id", "locator", "citation"/"title", "url", ...}],
     "facts": {...}, "origin": "fayl[:qator]"}

MUHIM: bu faqat o'qish uchun. Hech narsa yozilmaydi, ilova kodi (lib/) o'zgarmaydi.
Dart ajratgichi evristik: u to'liq Dart parseri emas; faqat shu repodagi
`_T({...})` / `LocalizedText({...})` literallari va `CalcRef(...)` havolalari uchun.
`_c('16')` kabi yordamchi chaqiruvlar (til bo'yicha birlik yig'adigan) hisobga olinmaydi.
"""
from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any

LANGS = ("uz", "ru", "en")
PACK_REL = "assets/content/core/pack.json"
DART_DOMAINS: dict[str, list[str]] = {
    "cytology": [
        "lib/features/cytology/cytology_content.dart",
        "lib/features/cytology/cytology_more.dart",
    ],
    "spermogram": ["lib/features/spermogram/spermogram_content.dart"],
    "bloodgroup": ["lib/features/bloodgroup/bloodgroup_content.dart"],
}
PACK_DOMAINS = ("analytes", "conditions", "quiz")
ALL_DOMAINS = (*PACK_DOMAINS, *DART_DOMAINS)
# Matni shundan qisqa elementlar (tugma/sarlavha kabi interfeys yozuvlari) o'tkazib yuboriladi.
MIN_ITEM_CHARS = 60

_LITERAL_NAMES = {"_T", "LocalizedText"}
_IGNORED_CALLS = {"_T", "LocalizedText", "CalcRef", "CalcSource", "Map", "List", "Set"}


# --------------------------------------------------------------------------
# Dart tokenizeri
# --------------------------------------------------------------------------
@dataclass
class Tok:
    kind: str  # 'str' | 'id' | 'num' | 'p'
    val: str
    line: int
    interp: bool = False


_ESC = {"n": "\n", "t": "\t", "r": "\r", "b": "\b", "f": "\f", "v": "\v", "0": "\0"}
_ID_START = re.compile(r"[A-Za-z_$]")
_ID_PART = re.compile(r"[A-Za-z0-9_$]")


def tokenize(src: str) -> list[Tok]:
    toks: list[Tok] = []
    i, n, line = 0, len(src), 1
    while i < n:
        c = src[i]
        if c == "\n":
            line += 1
            i += 1
            continue
        if c.isspace():
            i += 1
            continue
        if src.startswith("//", i):
            j = src.find("\n", i)
            i = n if j < 0 else j
            continue
        if src.startswith("/*", i):
            j = src.find("*/", i + 2)
            j = n if j < 0 else j + 2
            line += src.count("\n", i, j)
            i = j
            continue
        raw = False
        if c == "r" and i + 1 < n and src[i + 1] in "'\"":
            raw = True
            i += 1
            c = src[i]
        if c in "'\"":
            q = c * 3 if src.startswith(c * 3, i) else c
            i += len(q)
            buf: list[str] = []
            interp = False
            start_line = line
            while i < n:
                if src.startswith(q, i):
                    i += len(q)
                    break
                ch = src[i]
                if ch == "\n":
                    line += 1
                if ch == "\\" and not raw and i + 1 < n:
                    nx = src[i + 1]
                    if nx == "u":
                        if i + 2 < n and src[i + 2] == "{":
                            j = src.find("}", i)
                            buf.append(chr(int(src[i + 3 : j], 16)))
                            i = j + 1
                        else:
                            buf.append(chr(int(src[i + 2 : i + 6], 16)))
                            i += 6
                    elif nx == "x":
                        buf.append(chr(int(src[i + 2 : i + 4], 16)))
                        i += 4
                    else:
                        buf.append(_ESC.get(nx, nx))
                        i += 2
                    continue
                if ch == "$" and not raw and i + 1 < n and (src[i + 1] == "{" or _ID_START.match(src[i + 1])):
                    interp = True
                buf.append(ch)
                i += 1
            toks.append(Tok("str", "".join(buf), start_line, interp))
            continue
        if _ID_START.match(c):
            j = i + 1
            while j < n and _ID_PART.match(src[j]):
                j += 1
            toks.append(Tok("id", src[i:j], line))
            i = j
            continue
        if c.isdigit():
            j = i + 1
            while j < n and (src[j].isalnum() or src[j] in "._"):
                j += 1
            toks.append(Tok("num", src[i:j], line))
            i = j
            continue
        toks.append(Tok("p", c, line))
        i += 1
    # yonma-yon turgan satrlarni birlashtirish (Dart: 'a' 'b' == 'ab')
    merged: list[Tok] = []
    for t in toks:
        if t.kind == "str" and merged and merged[-1].kind == "str":
            merged[-1] = Tok("str", merged[-1].val + t.val, merged[-1].line, merged[-1].interp or t.interp)
        else:
            merged.append(t)
    return merged


class Parsed:
    """Tokenlar + qavs juftliklari."""

    def __init__(self, src: str, path: str = "") -> None:
        self.path = path
        self.t = tokenize(src)
        n = len(self.t)
        self.match = [-1] * n
        self.parent = [-1] * n
        stack: list[int] = []
        pairs = {")": "(", "]": "[", "}": "{"}
        for i, tk in enumerate(self.t):
            if tk.kind != "p":
                self.parent[i] = stack[-1] if stack else -1
                continue
            if tk.val in "([{":
                self.parent[i] = stack[-1] if stack else -1
                stack.append(i)
            elif tk.val in pairs:
                # nomuvofiq qavslar: mos kelgunicha yopamiz
                while stack and self.t[stack[-1]].val != pairs[tk.val]:
                    stack.pop()
                if stack:
                    o = stack.pop()
                    self.match[o] = i
                    self.parent[i] = stack[-1] if stack else -1
            else:
                self.parent[i] = stack[-1] if stack else -1

    def is_p(self, i: int, ch: str) -> bool:
        return 0 <= i < len(self.t) and self.t[i].kind == "p" and self.t[i].val == ch

    def is_id(self, i: int, name: str | None = None) -> bool:
        return 0 <= i < len(self.t) and self.t[i].kind == "id" and (name is None or self.t[i].val == name)

    def is_str(self, i: int) -> bool:
        return 0 <= i < len(self.t) and self.t[i].kind == "str"

    def is_class_brace(self, i: int) -> bool:
        if not self.is_p(i, "{"):
            return False
        j = i - 1
        while j >= 0 and i - j <= 40:
            tk = self.t[j]
            if tk.kind == "p" and tk.val in ";{}":
                return False
            if tk.kind == "id" and tk.val in ("class", "enum", "extension", "mixin"):
                return True
            j -= 1
        return False

    def class_name(self, brace: int) -> str | None:
        j = brace - 1
        while j >= 0 and brace - j <= 40:
            if self.is_id(j, "class") and self.is_id(j + 1):
                return self.t[j + 1].val
            j -= 1
        return None

    def chain(self, i: int) -> list[int]:
        out = []
        p = self.parent[i]
        while p >= 0:
            out.append(p)
            p = self.parent[p]
        out.reverse()
        return out  # eng tashqaridan ichkariga


# --------------------------------------------------------------------------
# Manbalar va havolalar jadvallari
# --------------------------------------------------------------------------
def _named_str_args(ps: Parsed, open_i: int) -> dict[str, str]:
    out: dict[str, str] = {}
    close = ps.match[open_i]
    j = open_i + 1
    while 0 < j < close:
        tk = ps.t[j]
        if tk.kind == "p" and tk.val in "([{" and ps.match[j] > 0:
            j = ps.match[j] + 1
            continue
        if tk.kind == "id" and ps.is_p(j + 1, ":") and ps.is_str(j + 2):
            out[tk.val] = ps.t[j + 2].val
            j += 3
            continue
        j += 1
    return out


def _decl_name_before(ps: Parsed, k: int) -> str | None:
    """`... name = <k>` yoki `... name = const <k>` ko'rinishidagi e'lon nomi."""
    j = k - 1
    if ps.is_id(j, "const"):
        j -= 1
    if ps.is_p(j, "=") and ps.is_id(j - 1):
        return ps.t[j - 1].val
    return None


def _enclosing_class(ps: Parsed, i: int) -> str | None:
    for p in reversed(ps.chain(i)):
        if ps.is_class_brace(p):
            return ps.class_name(p)
    return None


class Tables:
    """CalcSource va CalcRef e'lonlari (barcha fayllar bo'yicha)."""

    def __init__(self) -> None:
        self.sources: dict[str, dict[str, str]] = {}  # "Class.name" va "name" -> {id, citation, url}
        self.refs: dict[str, dict[str, str]] = {}  # const nomi -> havola
        self.group_refs: dict[tuple[str, str], list[dict[str, str]]] = {}  # (fayl, nom) -> [havola]

    def add_file(self, ps: Parsed) -> None:
        t = ps.t
        for k, tk in enumerate(t):
            if tk.kind != "id" or not ps.is_p(k + 1, "("):
                continue
            if tk.val == "CalcSource":
                name = _decl_name_before(ps, k)
                if not name:
                    continue
                args = _named_str_args(ps, k + 1)
                src = {"id": args.get("id", name), "citation": args.get("citation", ""), "url": args.get("url", "")}
                cls = _enclosing_class(ps, k)
                self.sources[f"{cls}.{name}" if cls else name] = src
                self.sources.setdefault(name, src)

    def resolve_source(self, expr: list[Tok]) -> dict[str, str] | None:
        names = [x.val for x in expr if x.kind == "id"]
        if not names:
            return None
        if len(names) >= 2 and f"{names[-2]}.{names[-1]}" in self.sources:
            return self.sources[f"{names[-2]}.{names[-1]}"]
        return self.sources.get(names[-1])

    def parse_ref(self, ps: Parsed, k: int) -> dict[str, str] | None:
        """t[k] == 'CalcRef' va t[k+1] == '('."""
        open_i, close = k + 1, ps.match[k + 1]
        if close < 0:
            return None
        # birinchi argument: vergulgacha (1-chuqurlikda)
        j = open_i + 1
        expr: list[Tok] = []
        while j < close and not ps.is_p(j, ","):
            expr.append(ps.t[j])
            j += 1
        locator = ps.t[j + 1].val if ps.is_p(j, ",") and ps.is_str(j + 1) else ""
        src = self.resolve_source(expr)
        if not src:
            return None
        return {"source_id": src["id"], "locator": locator, "citation": src["citation"], "url": src["url"]}

    def add_named_refs(self, ps: Parsed) -> None:
        """`const refX = CalcRef(Src.y, 'joy')` e'lonlari."""
        for k, tk in enumerate(ps.t):
            if tk.kind == "id" and tk.val == "CalcRef" and ps.is_p(k + 1, "("):
                name = _decl_name_before(ps, k)
                if name:
                    ref = self.parse_ref(ps, k)
                    if ref:
                        self.refs.setdefault(name, ref)

    def add_group_refs(self, ps: Parsed) -> None:
        """`const fooRefs = [CalcRef(...), refX]` — elementlar guruhi uchun umumiy havolalar."""
        t = ps.t
        for k, tk in enumerate(t):
            if tk.kind != "id" or not tk.val.endswith("Refs"):
                continue
            j = k + 1
            if ps.is_id(j, "const"):
                j += 1
            if not ps.is_p(j, "="):
                continue
            j += 1
            if ps.is_id(j, "const"):
                j += 1
            if ps.is_p(j, "[") and ps.match[j] > 0:
                self.group_refs[(ps.path, tk.val)] = self.refs_in(ps, j, ps.match[j])

    def add_refs(self, ps: Parsed) -> None:
        self.add_named_refs(ps)
        self.add_group_refs(ps)

    def refs_in(self, ps: Parsed, lo: int, hi: int) -> list[dict[str, str]]:
        out: list[dict[str, str]] = []
        seen: set[tuple[str, str]] = set()
        j = lo
        while j < hi:
            tk = ps.t[j]
            ref = None
            if tk.kind == "id" and tk.val == "CalcRef" and ps.is_p(j + 1, "("):
                ref = self.parse_ref(ps, j)
                j = max(j + 1, ps.match[j + 1])
            elif tk.kind == "id" and tk.val in self.refs and not ps.is_p(j + 1, "(") and not ps.is_p(j - 1, "."):
                ref = self.refs[tk.val]
            if ref and (ref["source_id"], ref["locator"]) not in seen:
                seen.add((ref["source_id"], ref["locator"]))
                out.append(ref)
            j += 1
        return out


def build_tables(root: Path, parsed: dict[str, Parsed] | None = None) -> Tables:
    tables = Tables()
    files = sorted((root / "lib/features").rglob("*.dart"))
    cache: dict[str, Parsed] = parsed if parsed is not None else {}
    for f in files:
        try:
            text = f.read_text(encoding="utf-8")
        except OSError:
            continue
        if "CalcSource(" not in text and "CalcRef(" not in text:
            continue
        rel = f.relative_to(root).as_posix()
        ps = cache.get(rel) or Parsed(text, rel)
        cache[rel] = ps
        tables.add_file(ps)
    for ps in cache.values():
        tables.add_named_refs(ps)
    for ps in cache.values():
        tables.add_group_refs(ps)
    return tables


# --------------------------------------------------------------------------
# Dart elementlari
# --------------------------------------------------------------------------
def parse_literal(ps: Parsed, k: int) -> tuple[dict[str, Any], int] | None:
    """t[k] — `_T` yoki `LocalizedText`; {'uz','ru','en'} lug'ati va oxirgi token."""
    if not (ps.is_p(k + 1, "(") and ps.is_p(k + 2, "{")):
        return None
    close = ps.match[k + 2]
    if close < 0:
        return None
    vals: dict[str, str] = {}
    interp = False
    j = k + 3
    while j < close:
        if ps.is_str(j) and ps.is_p(j + 1, ":") and ps.is_str(j + 2):
            vals[ps.t[j].val] = ps.t[j + 2].val
            interp = interp or ps.t[j + 2].interp
            j += 3
            if ps.is_p(j, ","):
                j += 1
            continue
        return None
    if not all(lang in vals for lang in LANGS):
        return None
    out: dict[str, Any] = {lang: vals[lang] for lang in LANGS}
    if interp:
        out["templated"] = True
    return out, ps.match[k + 1]


def _slug(s: str, n: int = 40) -> str:
    s = re.sub(r"[^A-Za-z0-9]+", "-", s).strip("-").lower()
    return s[:n].strip("-") or "x"


def _decl_name(ps: Parsed, open_i: int) -> str:
    j = open_i - 1
    while j >= 0:
        tk = ps.t[j]
        if tk.kind == "p" and tk.val in ";{}":
            break
        if tk.kind == "p" and tk.val == "=" and ps.is_id(j - 1):
            return ps.t[j - 1].val
        j -= 1
    return "decl"


def extract_dart_file(ps: Parsed, domain: str, tables: Tables) -> list[dict[str, Any]]:
    groups: dict[Any, dict[str, Any]] = {}
    order: list[Any] = []
    for k, tk in enumerate(ps.t):
        if tk.kind != "id" or tk.val not in _LITERAL_NAMES:
            continue
        lit = parse_literal(ps, k)
        if lit is None:
            continue
        data, _end = lit
        chain = [p for p in ps.chain(k) if not ps.is_class_brace(p)]
        root = None
        for p in chain:
            if ps.is_p(p, "(") and ps.is_id(p - 1) and ps.t[p - 1].val[:1].isupper() and ps.t[p - 1].val not in _IGNORED_CALLS:
                root = p
                break
        decl_open = chain[0] if chain else k
        decl = _decl_name(ps, decl_open)
        key: Any = ("root", root) if root is not None else ("lit", k)
        if key not in groups:
            groups[key] = {"decl": decl, "root": root, "k": k, "texts": [], "key_name": None}
            order.append(key)
        g = groups[key]
        # maydon nomi: `name: _T(` yoki map kaliti
        j = k - 1
        if ps.is_id(j, "const"):
            j -= 1
        field = None
        if ps.is_p(j, ":") and ps.is_id(j - 1):
            field = ps.t[j - 1].val
            if root is None:
                g["key_name"] = field
        data = {"field": field or f"text{len(g['texts'])}", **data, "line": tk.line}
        g["texts"].append(data)

    items: list[dict[str, Any]] = []
    per_decl: dict[str, int] = {}
    for key in order:
        g = groups[key]
        texts = g["texts"]
        if not any(len(t["uz"]) >= MIN_ITEM_CHARS for t in texts):
            continue
        decl = g["decl"]
        idx = per_decl.get(decl, 0)
        per_decl[decl] = idx + 1
        label = None
        refs: list[dict[str, str]] = []
        lo = hi = None
        if g["root"] is not None:
            r = g["root"]
            lo, hi = r, ps.match[r]
            # label: map kaliti (`X.y: Ctor(`) yoki birinchi oddiy satr argumenti
            if ps.is_p(r - 2, ":") and (ps.is_id(r - 3) or ps.is_str(r - 3)):
                label = _slug(ps.t[r - 3].val) if ps.is_str(r - 3) else ps.t[r - 3].val
            elif ps.is_str(r + 1) and not ps.t[r + 1].interp:
                label = _slug(ps.t[r + 1].val)
            if hi is not None and hi > 0:
                refs = tables.refs_in(ps, lo, hi)
        elif g["key_name"]:
            label = g["key_name"]
        if not refs:
            refs = list(tables.group_refs.get((ps.path, decl + "Refs"), []))
        if label:
            item_id = f"{domain}:{decl}:{label}"
        else:
            item_id = f"{domain}:{decl}" + (f":#{idx}" if g["root"] is not None or idx else "")
        first = texts[0]
        items.append(
            {
                "id": item_id,
                "domain": domain,
                "title": {lang: first[lang][:90] for lang in LANGS},
                "texts": texts,
                "refs": refs,
                "facts": {},
                "origin": f"{ps.path}:{texts[0]['line']}",
            }
        )
    # id yagonaligi
    seen: dict[str, int] = {}
    for it in items:
        n = seen.get(it["id"], 0)
        seen[it["id"]] = n + 1
        if n:
            it["id"] = f"{it['id']}~{n + 1}"
    return items


# --------------------------------------------------------------------------
# pack.json elementlari
# --------------------------------------------------------------------------
_SRC_KEEP = ("kind", "title", "publisher", "url", "source_date", "jurisdiction", "note", "authors", "year", "edition")


def _source_meta(src: dict[str, Any]) -> dict[str, Any]:
    return {k: src[k] for k in _SRC_KEEP if k in src}


def _loc(d: Any) -> bool:
    return isinstance(d, dict) and all(isinstance(d.get(lang), str) for lang in LANGS)


def _walk_localized(obj: Any, path: str, out: list[dict[str, Any]]) -> None:
    """Ichma-ich JSON ichidagi uz/ru/en lug'atlarini matn sifatida yig'adi."""
    if _loc(obj):
        out.append({"field": path, **{lang: obj[lang] for lang in LANGS}})
    elif isinstance(obj, dict):
        for k, v in obj.items():
            if k in ("refs", "source_ids", "synonyms", "review", "translation_review"):
                continue
            _walk_localized(v, f"{path}.{k}" if path else k, out)
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            _walk_localized(v, f"{path}[{i}]", out)


def _refs_for(refs: list[dict[str, Any]] | None, sources: dict[str, dict[str, Any]]) -> list[dict[str, Any]]:
    out = []
    for r in refs or []:
        sid = r.get("source_id")
        meta = _source_meta(sources.get(sid, {})) if sid else {}
        out.append({"source_id": sid, "locator": r.get("locator", ""), **({"source": meta} if meta else {})})
    return out


def _collect_refs(obj: Any) -> list[dict[str, Any]]:
    """Ichma-ich tuzilmadagi barcha `refs` ro'yxatlari (takrorlarsiz)."""
    out: list[dict[str, Any]] = []
    seen: set[tuple[Any, Any]] = set()

    def walk(o: Any) -> None:
        if isinstance(o, dict):
            for k, v in o.items():
                if k == "refs" and isinstance(v, list):
                    for r in v:
                        key = (r.get("source_id"), r.get("locator"))
                        if isinstance(r, dict) and key not in seen:
                            seen.add(key)
                            out.append(r)
                else:
                    walk(v)
        elif isinstance(o, list):
            for v in o:
                walk(v)

    walk(obj)
    return out


def pack_items(pack: dict[str, Any]) -> dict[str, list[dict[str, Any]]]:
    sources = {s["id"]: s for s in pack.get("sources", []) if "id" in s}
    out: dict[str, list[dict[str, Any]]] = {"analytes": [], "conditions": [], "quiz": []}

    for a in pack.get("analytes", []):
        texts = []
        for n, c in enumerate(a.get("claims", [])):
            if not _loc(c.get("text")):
                continue
            texts.append(
                {
                    "field": f"claim[{n}]:{c.get('section', '?')}",
                    "section": c.get("section"),
                    **{lang: c["text"][lang] for lang in LANGS},
                    "refs": _refs_for(c.get("refs"), sources),
                    **({"origin": c["origin"]} if c.get("origin") else {}),
                }
            )
        facts = {
            k: a[k]
            for k in (
                "specimen",
                "units",
                "reference_intervals",
                "decision_limits",
                "conversion",
                "treatment_goals",
                "method",
                "population",
                "notes",
                "group",
            )
            if a.get(k) not in (None, [], {})
        }
        out["analytes"].append(
            {
                "id": f"analyte:{a['id']}",
                "domain": "analytes",
                "group": a.get("group"),
                "title": a.get("names", {}),
                "texts": texts,
                "refs": [],
                "facts": facts,
                "origin": f"{PACK_REL}#analytes/{a['id']}",
            }
        )

    for c in pack.get("conditions", []):
        texts: list[dict[str, Any]] = []
        _walk_localized({k: v for k, v in c.items() if k not in ("names", "id")}, "", texts)
        out["conditions"].append(
            {
                "id": f"condition:{c['id']}",
                "domain": "conditions",
                "title": c.get("names", {}),
                "texts": texts,
                "refs": _refs_for(_collect_refs(c), sources),
                "facts": {},
                "origin": f"{PACK_REL}#conditions/{c['id']}",
            }
        )

    for q in pack.get("quiz", []):
        texts = []
        _walk_localized({k: v for k, v in q.items() if k != "id"}, "", texts)
        refs = _refs_for(q.get("refs"), sources)
        out["quiz"].append(
            {
                "id": f"quiz:{q['id']}",
                "domain": "quiz",
                "title": q.get("prompt", {}),
                "texts": texts,
                "refs": refs,
                "facts": {"correct_index": q.get("correct_index")},
                "origin": f"{PACK_REL}#quiz/{q['id']}",
            }
        )
    return out


# --------------------------------------------------------------------------
# Umumiy kirish nuqtasi
# --------------------------------------------------------------------------
def load_all(root: Path, domains: tuple[str, ...] = ALL_DOMAINS) -> dict[str, list[dict[str, Any]]]:
    out: dict[str, list[dict[str, Any]]] = {}
    if any(d in PACK_DOMAINS for d in domains):
        pack = json.loads((root / PACK_REL).read_text(encoding="utf-8"))
        for d, items in pack_items(pack).items():
            if d in domains:
                out[d] = items
    dart = [d for d in domains if d in DART_DOMAINS]
    if dart:
        cache: dict[str, Parsed] = {}
        tables = build_tables(root, cache)
        for d in dart:
            items: list[dict[str, Any]] = []
            for rel in DART_DOMAINS[d]:
                ps = cache.get(rel)
                if ps is None:
                    ps = Parsed((root / rel).read_text(encoding="utf-8"), rel)
                    cache[rel] = ps
                items.extend(extract_dart_file(ps, d, tables))
            out[d] = items
    return out


def extract_dart_text(src: str, domain: str = "test", path: str = "test.dart") -> list[dict[str, Any]]:
    """Sinov uchun: bitta Dart matnidan (jadvallar shu matndan)."""
    ps = Parsed(src, path)
    tables = Tables()
    tables.add_file(ps)
    tables.add_refs(ps)
    return extract_dart_file(ps, domain, tables)


if __name__ == "__main__":  # pragma: no cover - qo'lda ko'rish uchun
    import sys

    repo = Path(__file__).resolve().parents[2]
    loaded = load_all(repo)
    for dom, its in loaded.items():
        print(f"{dom}: {len(its)} ta element")
        if "--list" in sys.argv:
            for it in its:
                print("  ", it["id"], "|", it["title"].get("en", "")[:60])
