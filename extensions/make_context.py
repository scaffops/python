from __future__ import annotations

from copier_templates_extensions import ContextHook


class MakeContextDict(dict):
    __slots__ = ()  # Prevent from creating __weakref__ and __dict__ slots.

    def __missing__(self, key: str) -> str:
        self[key] = key
        return key


class MakeContextContextHook(ContextHook):
    update = False

    def hook(self, context: dict[str, object]) -> None:  # type: ignore[override]
        context["make_context"] = MakeContextDict()
