"""Testlar uchun umumiy yordamchilar: vaqtinchalik repo, soxta mijoz."""
from __future__ import annotations

import json
import shutil
import sys
import tempfile
from pathlib import Path
from types import SimpleNamespace
from typing import Any, Callable

HERE = Path(__file__).resolve().parent
AI_DIR = HERE.parent
REPO = AI_DIR.parent.parent
FIXTURES = HERE / "fixtures"
if str(AI_DIR) not in sys.path:
    sys.path.insert(0, str(AI_DIR))

DART_PATHS = [
    "lib/features/cytology/cytology_content.dart",
    "lib/features/cytology/cytology_more.dart",
    "lib/features/spermogram/spermogram_content.dart",
    "lib/features/bloodgroup/bloodgroup_content.dart",
]


def make_root() -> tuple[tempfile.TemporaryDirectory, Path]:
    """pack.json va Dart fayllar fixture'dan nusxalangan sun'iy repo."""
    tmp = tempfile.TemporaryDirectory()
    root = Path(tmp.name)
    pack = root / "assets/content/core/pack.json"
    pack.parent.mkdir(parents=True)
    shutil.copy(FIXTURES / "sample_pack.json", pack)
    for rel in DART_PATHS:
        p = root / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(FIXTURES / "sample_content.dart.txt", p)
    return tmp, root


def resp(obj: Any = None, *, text: str | None = None, stop: str = "end_turn", tin: int = 1000, tout: int = 300):
    body = text if text is not None else json.dumps(obj, ensure_ascii=False)
    return SimpleNamespace(
        content=[SimpleNamespace(type="text", text=body)],
        stop_reason=stop,
        usage=SimpleNamespace(input_tokens=tin, output_tokens=tout),
    )


class FakeAPIError(Exception):
    def __init__(self, status: int, message: str = "boom", retry_after: str | None = None):
        super().__init__(message)
        self.status_code = status
        self.message = message
        self.request_id = "req_test"
        self.response = SimpleNamespace(headers={"retry-after": retry_after} if retry_after else {})


class FakeClient:
    """`client.messages.create(**kw)`; `script` — javoblar/xatolar ketma-ketligi yoki chaqiriladigan funksiya."""

    def __init__(self, script: list[Any] | Callable[[dict[str, Any]], Any]):
        self.script = script
        self.calls: list[dict[str, Any]] = []
        self.messages = SimpleNamespace(create=self._create)

    def _create(self, **kw: Any):
        self.calls.append(kw)
        if callable(self.script):
            out = self.script(kw)
        else:
            out = self.script[min(len(self.calls) - 1, len(self.script) - 1)]
        if isinstance(out, BaseException):
            raise out
        return out
