#!/usr/bin/env python3
"""Leykoformula va sitologiya kontentini Dart manbadan JSON ga ko'chirish.

Taqdimot generatori (make_topic_decks.py) Flutter'siz ishlashi kerak, shuning
uchun `lib/features/differential/differential_content.dart` va
`lib/features/cytology/cytology_content.dart` dagi `const` ma'lumotlar shu
skript bilan `tool/slides/data/app_content.json` ga chiqariladi. Matnlarni qo'lda
ko'chirish yo'q: JSON har doim Dart bilan mos (test_topic_decks.py solishtiradi).

  python3 tool/slides/extract_dart_content.py            # JSON ni yangilaydi
  python3 tool/slides/extract_dart_content.py --check    # mos emas bo'lsa 1

Faqat `const NOM = ifoda;` ko'rinishidagi e'lonlar o'qiladi (Dart ifodalarining
kichik qismi: satr, son, ro'yxat, xarita, yozuv (a, b), chaqiriqlar).
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
OUT = os.path.join(HERE, 'data', 'app_content.json')

FILES = {
    'differential': 'lib/features/differential/differential_content.dart',
    'differential_sources': 'lib/features/differential/differential_sources.dart',
    'cytology': 'lib/features/cytology/cytology_content.dart',
    'reference': 'lib/features/reference/reference_content.dart',
    'reference_sources': 'lib/features/reference/reference_sources.dart',
}

# Pozitsion argumentli klasslar -> maydon nomlari.
POSITIONAL = {
    'CalcRef': ['source', 'locator'],
    'CytoDegree': ['n', 'ph', 'picture', 'meaning'],
    'BethesdaItem': ['code', 'name', 'meaning'],
    'CytoStep': ['title', 'body'],
    'ExampleRange': ['cell', 'who', 'medline', 'classic'],
    'RefFact': ['label', 'value'],
}
TEXT_CTORS = {'_T', 'LocalizedText'}


class Tok:
    def __init__(self, kind, val):
        self.kind, self.val = kind, val

    def __repr__(self):
        return f'{self.kind}:{self.val!r}'


ESC = {'n': '\n', 't': '\t', '\\': '\\', "'": "'", '"': '"', '$': '$', 'r': '\r'}


def tokenize(src):
    i, n, out = 0, len(src), []
    while i < n:
        c = src[i]
        if c.isspace():
            i += 1
        elif src.startswith('//', i):
            j = src.find('\n', i)
            i = n if j < 0 else j
        elif src.startswith('/*', i):
            i = src.index('*/', i) + 2
        elif c in '\'"':
            raw = False
            q = c
            if src.startswith(q * 3, i):
                raise ValueError('uch tirnoqli satr qo\'llab-quvvatlanmaydi')
            i += 1
            buf = []
            while src[i] != q:
                if src[i] == '\\' and not raw:
                    e = src[i + 1]
                    if e == 'u':
                        if src[i + 2] == '{':
                            j = src.index('}', i)
                            buf.append(chr(int(src[i + 3:j], 16)))
                            i = j + 1
                        else:
                            buf.append(chr(int(src[i + 2:i + 6], 16)))
                            i += 6
                        continue
                    buf.append(ESC.get(e, e))
                    i += 2
                else:
                    buf.append(src[i])
                    i += 1
            i += 1
            out.append(Tok('str', ''.join(buf)))
        elif c.isdigit() or (c == '-' and src[i + 1].isdigit()):
            m = re.compile(r'-?\d+(?:\.\d+)?').match(src, i)
            s = m.group(0)
            out.append(Tok('num', float(s) if '.' in s else int(s)))
            i = m.end()
        elif c.isalpha() or c == '_':
            m = re.compile(r'[A-Za-z_][A-Za-z_0-9]*(?:\.[A-Za-z_][A-Za-z_0-9]*)*').match(src, i)
            out.append(Tok('id', m.group(0)))
            i = m.end()
        else:
            out.append(Tok('p', c))
            i += 1
    return out


class Parser:
    def __init__(self, toks, env):
        self.t, self.i, self.env = toks, 0, env

    def peek(self):
        return self.t[self.i] if self.i < len(self.t) else Tok('eof', None)

    def eat(self, kind=None, val=None):
        tk = self.peek()
        if (kind and tk.kind != kind) or (val is not None and tk.val != val):
            raise ValueError(f'kutilmagan token {tk} (kutilgan {kind} {val}) @ {self.i}')
        self.i += 1
        return tk

    def skip_generics(self):
        if self.peek().kind == 'p' and self.peek().val == '<':
            depth = 0
            while True:
                tk = self.eat()
                if tk.val == '<':
                    depth += 1
                elif tk.val == '>':
                    depth -= 1
                    if depth == 0:
                        break

    def expr(self):
        tk = self.peek()
        if tk.kind == 'id' and tk.val == 'const':
            self.i += 1
            return self.expr()
        self.skip_generics()
        tk = self.peek()
        if tk.kind == 'str':
            s = ''
            while self.peek().kind == 'str':
                s += self.eat().val
            return s
        if tk.kind == 'num':
            self.i += 1
            return tk.val
        if tk.kind == 'id':
            self.i += 1
            if tk.val in ('true', 'false', 'null'):
                return {'true': True, 'false': False, 'null': None}[tk.val]
            nxt = self.peek()
            if nxt.kind == 'p' and nxt.val == '(':
                return self.call(tk.val)
            return self.resolve(tk.val)
        if tk.kind == 'p' and tk.val == '[':
            self.i += 1
            items = []
            while not (self.peek().kind == 'p' and self.peek().val == ']'):
                items.append(self.expr())
                if self.peek().val == ',':
                    self.i += 1
            self.eat('p', ']')
            return items
        if tk.kind == 'p' and tk.val == '{':
            self.i += 1
            d = {}
            while not (self.peek().kind == 'p' and self.peek().val == '}'):
                k = self.expr()
                self.eat('p', ':')
                d[k] = self.expr()
                if self.peek().val == ',':
                    self.i += 1
            self.eat('p', '}')
            return d
        if tk.kind == 'p' and tk.val == '(':
            self.i += 1
            items = []
            comma = False
            while not (self.peek().kind == 'p' and self.peek().val == ')'):
                items.append(self.expr())
                if self.peek().val == ',':
                    self.i += 1
                    comma = True
            self.eat('p', ')')
            return {'__record__': items} if comma or len(items) != 1 else items[0]
        raise ValueError(f'ifoda boshlanishi noto\'g\'ri: {tk} @ {self.i}')

    def call(self, name):
        self.eat('p', '(')
        pos, named = [], {}
        while not (self.peek().kind == 'p' and self.peek().val == ')'):
            tk = self.peek()
            nxt = self.t[self.i + 1] if self.i + 1 < len(self.t) else Tok('eof', None)
            if tk.kind == 'id' and nxt.kind == 'p' and nxt.val == ':':
                self.i += 2
                named[tk.val] = self.expr()
            else:
                pos.append(self.expr())
            if self.peek().val == ',':
                self.i += 1
        self.eat('p', ')')
        if name in TEXT_CTORS:
            return pos[0]
        fields = POSITIONAL.get(name, [])
        out = {}
        for k, v in zip(fields, pos):
            out[k] = v
        if len(pos) > len(fields) and name not in POSITIONAL:
            out['__pos__'] = pos
        out.update(named)
        if name == 'CalcRef':
            src = out['source']
            return {
                'source_id': src['id'], 'citation': src['citation'],
                'url': src.get('url'), 'locator': out['locator'],
            }
        return out

    def resolve(self, name):
        if name in self.env.cache:
            return self.env.cache[name]
        short = name.split('.')[-1]
        if short in self.env.decl:
            v = self.env.value(short)
            return v
        return name  # enum ref va h.k. — satr sifatida


class Env:
    DECL = re.compile(
        r'^[ \t]*(?:static[ \t]+)?(?:const|final)[ \t]+'
        r'(?:[A-Za-z_][\w<>?, ]*?[ \t]+)?([A-Za-z_]\w*)[ \t]*=[ \t]*', re.M)

    def __init__(self, src):
        self.src = src
        self.decl = {}
        for m in self.DECL.finditer(src):
            self.decl.setdefault(m.group(1), m.end())
        self.cache = {}
        self.toks = None

    def value(self, name):
        if name in self.cache:
            return self.cache[name]
        pos = self.decl[name]
        # shu joydan boshlab, `;` gacha bo'lgan qismni tokenlash
        end = self._stmt_end(pos)
        p = Parser(tokenize(self.src[pos:end]), self)
        v = p.expr()
        self.cache[name] = v
        return v

    def _stmt_end(self, pos):
        i, depth, q = pos, 0, None
        while i < len(self.src):
            c = self.src[i]
            if q:
                if c == '\\':
                    i += 2
                    continue
                if c == q:
                    q = None
            elif c in '\'"':
                q = c
            elif self.src.startswith('//', i):
                i = self.src.index('\n', i)
                continue
            elif c in '([{':
                depth += 1
            elif c in ')]}':
                depth -= 1
            elif c == ';' and depth == 0:
                return i
            i += 1
        raise ValueError('; topilmadi')


def _read(path):
    with open(path, encoding='utf-8') as f:
        return f.read()


class MultiEnv:
    def __init__(self, paths):
        self.envs = [Env(_read(os.path.join(REPO, p))) for p in paths]
        self.cache = {}
        self.decl = {}
        for e in self.envs:
            e.cache = self.cache
            for k in e.decl:
                self.decl.setdefault(k, e)

    def value(self, name):
        if name in self.cache:
            return self.cache[name]
        e = self.envs[self.envs.index(self.decl[name])]
        pos = e.decl[name]
        end = e._stmt_end(pos)
        p = Parser(tokenize(e.src[pos:end]), self)
        v = p.expr()
        self.cache[name] = v
        return v


def fix_records(o):
    if isinstance(o, dict):
        if '__record__' in o and len(o) == 1:
            return [fix_records(x) for x in o['__record__']]
        return {k: fix_records(v) for k, v in o.items()}
    if isinstance(o, list):
        return [fix_records(x) for x in o]
    return o


def build():
    env = MultiEnv([
        FILES['differential_sources'],
        FILES['differential'],
        FILES['cytology'],
        FILES['reference'],
        FILES['reference_sources'],
    ])
    names = [
        'cellGuides', 'confusions', 'diffFindings', 'exampleRanges',
        'techniqueSections', 'cytoCells', 'cytoDegrees', 'bethesdaItems',
        'cytoTechnique', 'cytoTechniqueRefs', 'cytoMarks', 'refTopics',
    ]
    out = {
        '_generated_from': [FILES['differential'], FILES['differential_sources'], FILES['cytology'],
                           FILES['reference'], FILES['reference_sources']],
        '_note': 'Avtomatik: python3 tool/slides/extract_dart_content.py. Qo\'lda tahrirlamang.',
    }
    for n in names:
        out[n] = fix_records(env.value(n))
    out['diffImageMap'] = fix_records(env.value('diffCellImage'))
    out['diffSources'] = {
        n: fix_records(env.value(n))
        for n in ('who2003', 'medlineDiff', 'medlineEncyDiff', 'nciDictionary',
                  'gulati2013', 'lyubina1984')
    }
    return out


def dump(obj):
    return json.dumps(obj, ensure_ascii=False, indent=1, sort_keys=False) + '\n'


def main(argv):
    data = dump(build())
    if '--check' in argv:
        cur = _read(OUT) if os.path.exists(OUT) else ''
        if cur != data:
            print('app_content.json Dart bilan mos emas — yangilang.')
            return 1
        print('app_content.json mos.')
        return 0
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, 'w', encoding='utf-8') as f:
        f.write(data)
    print('yozildi:', OUT)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
