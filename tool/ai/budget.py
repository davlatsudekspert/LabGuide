"""Xarajat qo'riqchisi: har bir chaqiruvdan oldin va keyin USD hisobi.

Narxlar — USD / 1 mln token (Anthropic narx jadvali, 2026-10-06 holati; o'zgarsa shu
yerni yangilang). Hisob API qaytargan `usage` sonlariga asoslanadi; chaqiruvdan
oldingi taxmin esa taxminiy (belgi/token nisbati) va ataylab konservativ.
"""
from __future__ import annotations

import math
from dataclasses import dataclass, field

# model -> (kirish USD/MTok, chiqish USD/MTok)
PRICES: dict[str, tuple[float, float]] = {
    "claude-sonnet-5-5": (2.00, 10.00),
    "claude-opus-5-5": (4.00, 20.00),
}
# Kirill/lotin aralash JSON uchun konservativ: 1 token ~ 2.6 belgi.
CHARS_PER_TOKEN = 2.6
MAX_BUDGET_USD = 10.0


def estimate_tokens(text: str) -> int:
    return math.ceil(len(text) / CHARS_PER_TOKEN)


def cost_usd(model: str, in_tokens: int, out_tokens: int) -> float:
    pin, pout = PRICES[model]
    return (in_tokens * pin + out_tokens * pout) / 1_000_000


@dataclass
class Budget:
    cap_usd: float
    model: str
    spent_usd: float = 0.0
    in_tokens: int = 0
    out_tokens: int = 0
    calls: int = 0
    _observed_out: list[int] = field(default_factory=list)

    def __post_init__(self) -> None:
        if self.model not in PRICES:
            raise ValueError(f"narxi noma'lum model: {self.model}")
        if not (0 < self.cap_usd <= MAX_BUDGET_USD):
            raise ValueError(f"budget 0 dan katta va {MAX_BUDGET_USD} USD dan oshmasligi kerak")

    def record(self, in_tokens: int, out_tokens: int) -> float:
        """API `usage` sonlarini hisobga olish (xato bilan tugagan javoblar ham)."""
        c = cost_usd(self.model, in_tokens, out_tokens)
        self.spent_usd += c
        self.in_tokens += in_tokens
        self.out_tokens += out_tokens
        self.calls += 1
        self._observed_out.append(out_tokens)
        return c

    def assumed_out(self, max_tokens: int) -> int:
        """Keyingi javob uchun chiqish tokenlari taxmini: kuzatilgan eng kattasining 1.5 baravari
        (lekin max_tokens dan oshmaydi); hali kuzatuv bo'lmasa — eng yomon holat (max_tokens)."""
        if not self._observed_out:
            return max_tokens
        return min(max_tokens, math.ceil(max(self._observed_out) * 1.5))

    def projected_cost(self, est_in_tokens: int, max_tokens: int) -> float:
        return cost_usd(self.model, est_in_tokens, self.assumed_out(max_tokens))

    def can_afford(self, est_in_tokens: int, max_tokens: int) -> bool:
        return self.spent_usd + self.projected_cost(est_in_tokens, max_tokens) <= self.cap_usd

    @property
    def remaining_usd(self) -> float:
        return max(0.0, self.cap_usd - self.spent_usd)
