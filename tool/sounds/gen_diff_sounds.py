"""Leykoformula hisoblagichi uchun qisqa signal tovushlari.

Tovushlar shu skript bilan sintez qilinadi (sinus to'lqin + yumshoq
qobiq) — tashqi manba yo'q, litsenziya masalasi yo'q.
Ishga tushirish (repo ildizida): python3 tool/sounds/gen_diff_sounds.py
"""
import math
import os
import struct
import wave

RATE = 22050
OUT = 'assets/differential/sounds'


def tone(freq, ms, vol=0.55):
    n = int(RATE * ms / 1000)
    attack = max(1, int(RATE * 0.004))
    out = []
    for i in range(n):
        # Tez ko'tarilish, eksponensial so'nish — "chiq" kabi.
        env = min(1.0, i / attack) * math.exp(-4.0 * i / n)
        out.append(vol * env * math.sin(2 * math.pi * freq * i / RATE))
    return out


def silence(ms):
    return [0.0] * int(RATE * ms / 1000)


def write(name, samples):
    with wave.open(f'{OUT}/{name}.wav', 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b''.join(
            struct.pack('<h', int(max(-1, min(1, s)) * 32767))
            for s in samples))


os.makedirs(OUT, exist_ok=True)
# Har bosish — qisqa baland "chiq".
write('tap', tone(1760, 45))
# Har 10-hujayra — ikki pog'onali ko'tariluvchi signal.
write('ten', tone(1320, 70) + silence(40) + tone(1760, 90))
# Maqsadga yetildi (100/200) — uch notali akkord.
write('done', tone(1047, 120) + silence(30) + tone(1319, 120)
      + silence(30) + tone(1568, 260))
# Bekor qilish — pasayuvchi ikki ton.
write('undo', tone(880, 70) + silence(30) + tone(587, 110))
# Qabul qilinmadi (sanash tugagan) — past, uzunroq ton.
write('blocked', tone(330, 220, vol=0.5))
