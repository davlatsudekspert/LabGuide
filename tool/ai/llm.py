"""Claude API chaqiruvi: qayta urinish (backoff), qat'iy JSON-sxema, faqat token sonlari logga.

`anthropic` SDK faqat `make_client()` ichida import qilinadi — qolgan kod (va testlar)
SDK'siz ham ishlaydi. Maxfiy kalit hech qachon logga/xabarga tushmaydi (`redact`).
"""
from __future__ import annotations

import json
import os
import random
import re
import time
from dataclasses import dataclass
from typing import Any, Callable

SECRET_RE = re.compile(r"sk-ant-[A-Za-z0-9_\-]{8,}")
RETRY_STATUS = {408, 409, 429}
FATAL_STATUS = {401, 403, 404}
RETRY_NAMES = {"APIConnectionError", "APITimeoutError", "InternalServerError", "RateLimitError", "OverloadedError"}
RETRY_ERROR_TYPES = {"overloaded_error", "rate_limit_error", "api_error"}
# Status 400 bo'lsa ham bu xato butun ishni to'xtatadi: hisobda kredit yo'q. 2026-10-17 jonli ishga
# tushirishda shu sabab bilan elementlar "in=0 out=0" bo'lib, sababi logda ko'rinmay yiqilgan edi.
BILLING_RE = re.compile(r"credit balance is too low|plans\s*&\s*billing", re.IGNORECASE)


def redact(text: str, key: str | None = None) -> str:
    if key:
        text = text.replace(key, "[REDACTED]")
    return SECRET_RE.sub("[REDACTED]", text)


def make_client(api_key: str, timeout: float = 300.0):
    """Rasmiy SDK mijozi. SDK'ning o'z qayta urinishi o'chirilgan — backoff `LLM.call`da."""
    import anthropic  # kech import

    return anthropic.Anthropic(api_key=api_key, max_retries=0, timeout=timeout)


def _api_error(exc: BaseException) -> tuple[str | None, str | None]:
    """SDK xatosidagi `body = {"type": "error", "error": {"type": ..., "message": ...}}` dan (type, message)."""
    body = getattr(exc, "body", None)
    if not isinstance(body, dict):
        return None, None
    err = body.get("error") if isinstance(body.get("error"), dict) else body
    t, m = err.get("type"), err.get("message")
    return (t if isinstance(t, str) else None), (m if isinstance(m, str) else None)


def describe_error(exc: BaseException, key: str | None = None, limit: int = 200) -> str:
    """Qisqa bir qatorli tavsif: klass, status, API xato turi, request_id, xabar boshi (kalit yashiriladi)."""
    status = getattr(exc, "status_code", None)
    req = getattr(exc, "request_id", None)
    etype, emsg = _api_error(exc)
    msg = emsg or str(getattr(exc, "message", "") or exc)
    msg = redact(" ".join(msg.split()), key)[:limit]
    t = f" type={etype}" if etype else ""
    return f"{type(exc).__name__} status={status}{t} request_id={req} msg={msg!r}"


def fatal_reason(exc: BaseException) -> str | None:
    """Butun ishni to'xtatadigan xato: 'auth' (401/403/404) yoki 'billing' (kredit tugagan)."""
    status = getattr(exc, "status_code", None)
    if status in FATAL_STATUS:
        return "auth"
    etype, emsg = _api_error(exc)
    if status in (400, 402):
        if etype == "billing_error":
            return "billing"
        text = f"{emsg or ''} {getattr(exc, 'message', '') or ''} {exc}"
        if BILLING_RE.search(text):
            return "billing"
    return None


def is_retryable(exc: BaseException) -> bool:
    """Faqat vaqtinchalik xatolar: 408/409/429, 5xx (529 overloaded ham), tarmoq/timeout."""
    if fatal_reason(exc):
        return False
    status = getattr(exc, "status_code", None)
    if isinstance(status, int):
        return status in RETRY_STATUS or status >= 500
    if _api_error(exc)[0] in RETRY_ERROR_TYPES:
        return True
    return type(exc).__name__ in RETRY_NAMES


def is_fatal(exc: BaseException) -> bool:
    return fatal_reason(exc) is not None


def _retry_after(exc: BaseException) -> float | None:
    try:
        v = exc.response.headers.get("retry-after")  # type: ignore[attr-defined]
        return float(v) if v is not None else None
    except Exception:  # noqa: BLE001 - sarlavha bo'lmasligi mumkin
        return None


@dataclass
class Reply:
    ok: bool
    parsed: dict[str, Any] | None = None
    error: str | None = None
    fatal: bool = False
    fatal_reason: str | None = None
    in_tokens: int = 0
    out_tokens: int = 0
    attempts: int = 0
    stop_reason: str | None = None


class LLM:
    def __init__(
        self,
        client: Any,
        model: str,
        *,
        effort: str = "medium",
        max_attempts: int = 4,
        base_delay: float = 2.0,
        max_delay: float = 60.0,
        sleep: Callable[[float], None] = time.sleep,
        rand: Callable[[], float] = random.random,
        api_key: str | None = None,
        log: Callable[[str], None] = print,
    ) -> None:
        self.client, self.model, self.effort = client, model, effort
        self.max_attempts, self.base_delay, self.max_delay = max_attempts, base_delay, max_delay
        self.sleep, self.rand, self.api_key, self.log = sleep, rand, api_key, log

    def _request(self, system: str, user: str, schema: dict[str, Any], max_tokens: int) -> dict[str, Any]:
        return {
            "model": self.model,
            "max_tokens": max_tokens,
            "system": system,
            "messages": [{"role": "user", "content": user}],
            # qat'iy JSON: sxemaga mos matn. `thinking` berilmaydi (modelda har doim yoqiq).
            "output_config": {"effort": self.effort, "format": {"type": "json_schema", "schema": schema}},
        }

    def call(self, system: str, user: str, schema: dict[str, Any], max_tokens: int) -> Reply:
        req = self._request(system, user, schema, max_tokens)
        last_err = ""
        for attempt in range(1, self.max_attempts + 1):
            try:
                resp = self.client.messages.create(**req)
            except Exception as exc:  # noqa: BLE001 - SDK xatolari turlicha
                last_err = describe_error(exc, self.api_key)
                reason = fatal_reason(exc)
                if reason:
                    return Reply(False, error=last_err, fatal=True, fatal_reason=reason, attempts=attempt)
                if not is_retryable(exc) or attempt == self.max_attempts:
                    return Reply(False, error=last_err, attempts=attempt)
                delay = _retry_after(exc)
                if delay is None:
                    delay = min(self.max_delay, self.base_delay * (2 ** (attempt - 1)))
                    delay *= 0.5 + self.rand()  # jitter
                delay = min(delay, self.max_delay)
                self.log(f"  qayta urinish {attempt}/{self.max_attempts - 1}: {type(exc).__name__} "
                         f"status={getattr(exc, 'status_code', None)}; {delay:.1f}s kutiladi")
                self.sleep(delay)
                continue
            return self._parse(resp, attempt)
        return Reply(False, error=last_err or "noma'lum xato", attempts=self.max_attempts)

    def _parse(self, resp: Any, attempts: int) -> Reply:
        usage = getattr(resp, "usage", None)
        tin = int(getattr(usage, "input_tokens", 0) or 0)
        tin += int(getattr(usage, "cache_creation_input_tokens", 0) or 0)
        tin += int(getattr(usage, "cache_read_input_tokens", 0) or 0)
        tout = int(getattr(usage, "output_tokens", 0) or 0)
        stop = getattr(resp, "stop_reason", None)
        base = dict(in_tokens=tin, out_tokens=tout, attempts=attempts, stop_reason=stop)
        if stop == "refusal":
            return Reply(False, error="model rad etdi (stop_reason=refusal)", **base)
        if stop == "max_tokens":
            return Reply(False, error="javob max_tokens chegarasida uzildi (JSON to'liq emas)", **base)
        text = next((b.text for b in getattr(resp, "content", []) if getattr(b, "type", None) == "text"), None)
        if text is None:
            return Reply(False, error="javobda matn bloki yo'q", **base)
        try:
            data = json.loads(text)
        except json.JSONDecodeError:
            return Reply(False, error="javob JSON emas", **base)
        if not isinstance(data, dict):
            return Reply(False, error="javob JSON obyekt emas", **base)
        return Reply(True, parsed=data, **base)


def api_key_from_env(env: dict[str, str] | None = None) -> str | None:
    key = (env if env is not None else os.environ).get("ANTHROPIC_API_KEY", "").strip()
    return key or None
