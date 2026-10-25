"""tool/video/make_manifest.py testlari (oflayn, haqiqiy video shart emas).

  python3 -m unittest discover -s tool/video -p 'test_*.py'
"""
import json
import os
import struct
import sys
import tempfile
import unittest
from unittest import mock

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import make_manifest as mm  # noqa: E402


def box(kind, payload):
    return struct.pack('>I4s', 8 + len(payload), kind.encode()) + payload


def fake_mp4(seconds, timescale=1000, version=0):
    if version == 1:
        mvhd = bytes([1, 0, 0, 0]) + struct.pack('>QQIQ', 0, 0, timescale,
                                                  int(seconds * timescale))
    else:
        mvhd = bytes([0, 0, 0, 0]) + struct.pack('>IIII', 0, 0, timescale,
                                                  int(seconds * timescale))
    return (box('ftyp', b'isom\x00\x00\x02\x00') + box('moov', box('mvhd', mvhd))
            + box('mdat', b'\x00' * 64))


class Mp4Duration(unittest.TestCase):
    def test_mvhd_v0_and_v1(self):
        self.assertAlmostEqual(mm.mp4_duration(fake_mp4(45.5)), 45.5)
        self.assertAlmostEqual(mm.mp4_duration(fake_mp4(64, 90000, 1)), 64.0)

    def test_no_moov(self):
        self.assertIsNone(mm.mp4_duration(box('ftyp', b'isom')))
        self.assertIsNone(mm.mp4_duration(b'\x00\x00'))


class Build(unittest.TestCase):
    def setUp(self):
        with open(mm.STORY, encoding='utf-8') as f:
            self.story = json.load(f)
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = self.tmp.name
        # ffprobe’siz: davomiylik soxta MP4 ning mvhd qutisidan.
        patcher = mock.patch.object(mm, 'ffprobe_duration', return_value=None)
        patcher.start()
        self.addCleanup(patcher.stop)
        self.addCleanup(self.tmp.cleanup)

    def write_all(self, skip=()):
        for t in self.story['topics']:
            for lang in mm.LANGS:
                name = f'{t["id"]}_{lang}.mp4'
                if name in skip:
                    continue
                with open(os.path.join(self.dir, name), 'wb') as f:
                    f.write(fake_mp4(30 + len(lang)))

    def test_all_sections_and_languages(self):
        self.write_all()
        videos, files = mm.build(self.dir, 'https://h.uz/v1', self.story)
        self.assertEqual(len(videos), 16 * 3)
        self.assertEqual({v['section'] for v in videos}, set(mm.SECTIONS))
        for v in videos:
            self.assertTrue(v['url'].startswith('https://h.uz/v1/'))
            self.assertRegex(v['url'], r'_(uz|ru|en)\.[0-9a-f]{8}\.mp4$')
            self.assertIn(f'_{v["lang"]}.', v['url'])
            self.assertRegex(v['sha256'], r'^[0-9a-f]{64}$')
            self.assertEqual(v['seconds'], 32.0)
            shared = mm.SHARED_TOPIC in v['url']
            self.assertEqual('start_seconds' in v, shared)
        starts = {v['section']: v['start_seconds'] for v in videos
                  if v['lang'] == 'uz' and 'start_seconds' in v}
        self.assertEqual(starts['differential'], 6.0)
        self.assertEqual(starts['cytology'], 18.0)
        self.assertEqual(starts['coagulogram'], 45.5)
        # 9-mavzu bo‘limsiz: o‘lchanadi, lekin ro‘yxatga kirmaydi.
        self.assertTrue(any(f['topic'] == '09_testlar_natijalar' for f in files))
        self.assertFalse(any('09_testlar' in v['url'] for v in videos))

    def test_sections_match_dart_enum(self):
        root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
        with open(os.path.join(root, 'lib/features/howto/howto_registry.dart'),
                  encoding='utf-8') as f:
            src = f.read()
        body = src[src.index('enum HowToSection {'):src.index('String get id')]
        names = [w.strip(' ,;\n') for w in body.split('{', 1)[1].split(',')]
        self.assertEqual(tuple(n for n in names if n), mm.SECTIONS)

    def test_missing_language_fails(self):
        self.write_all(skip={'02_sifat_nazorati_ru.mp4'})
        with self.assertRaises(SystemExit) as e:
            mm.build(self.dir, 'https://h.uz/v1', self.story)
        self.assertIn('02_sifat_nazorati_ru.mp4', str(e.exception))

    def test_cli_placeholder_and_sums(self):
        self.write_all()
        out = os.path.join(self.dir, 'v.json')
        sums = os.path.join(self.dir, 'SUMS')
        stage = os.path.join(self.dir, 'stage')
        with mock.patch('sys.stderr'):
            mm.main([self.dir, '--out', out, '--sha256sums', sums,
                     '--stage', stage])
        with open(out, encoding='utf-8') as f:
            doc = json.load(f)
        self.assertEqual(doc['schema_version'], 1)
        self.assertIsNone(doc['owner_approval'])
        self.assertTrue(all('.invalid/' in v['url'] for v in doc['videos']))
        with open(sums, encoding='utf-8') as f:
            lines = f.read().splitlines()
        self.assertEqual(len(lines), 30)
        for line in lines:
            sha, name = line.split('  ')
            self.assertTrue(os.path.exists(os.path.join(stage, name)))
            self.assertEqual(mm.sha256_of(os.path.join(stage, name)), sha)

    def test_cli_rejects_http_and_bad_approval(self):
        self.write_all()
        for args in (['--base-url', 'http://h.uz'], ['--approval', 'yes']):
            with self.assertRaises(SystemExit):
                mm.main([self.dir] + args)


if __name__ == '__main__':
    unittest.main()
