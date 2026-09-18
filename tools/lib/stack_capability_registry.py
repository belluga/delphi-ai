"""Strict, dependency-free loader for Delphi's stack capability registry."""
from __future__ import annotations
from pathlib import Path
from dataclasses import dataclass
import re
from typing import Any


class RegistryValidationError(ValueError):
    """Registry input falls outside the documented, fail-closed YAML subset."""


TOP_LEVEL_KEYS = {"schema_version", "ecosystem", "activation_contract", "capabilities"}
ACTIVATION_CONTRACT_KEYS = {
    "authority_order",
    "project_contract_surfaces",
    "non_activation_signals",
}
CAPABILITY_KEYS = {
    "lifecycle",
    "purpose",
    "default_surfaces",
    "activation_markers",
    "detection_markers",
    "execution_policy",
}
DETECTION_MARKER_KEYS = {
    "root_files",
    "nested_files",
    "composer_requires",
    "companion_files",
    "package_json_requires_any",
}
LIFECYCLES = {"available", "future", "deprecated", "experimental"}
REQUIRED_BASELINE_CAPABILITIES = {"docker", "flutter", "laravel", "go"}

@dataclass(frozen=True)
class DetectionMarkers:
    root_files: tuple[str, ...] = ()
    nested_files: tuple[str, ...] = ()
    composer_requires: tuple[str, ...] = ()
    companion_files: tuple[str, ...] = ()
    package_json_requires_any: tuple[str, ...] = ()


@dataclass(frozen=True)
class Capability:
    name: str
    lifecycle: str
    purpose: str
    default_surfaces: tuple[str, ...]
    activation_markers: tuple[str, ...]
    detection_markers: DetectionMarkers
    execution_policy: str


@dataclass(frozen=True)
class StackCapabilityRegistry:
    schema_version: str
    ecosystem: str
    activation_contract: dict[str, tuple[str, ...]]
    capabilities: dict[str, Capability]


def _strip_comment(line: str) -> str:
    quote: str | None = None
    for i, char in enumerate(line):
        if char in {"'", '"'}:
            quote = None if quote == char else char
        elif char == "#" and quote is None:
            return line[:i]
    if quote:
        raise RegistryValidationError("unterminated quoted scalar")
    return line


def _scalar(value: str, line: int) -> str:
    value = value.strip()
    if value == "[]":
        return value
    if not value:
        raise RegistryValidationError(f"line {line}: expected scalar")
    if value[0:1] in {"[", "{"} or "{" in value or "}" in value:
        raise RegistryValidationError(
            f"line {line}: flow mappings and flow sequences are not supported"
        )
    if re.search(r"(^|\s)[&*!]|\s<<\s*:", value):
        raise RegistryValidationError(
            f"line {line}: YAML anchors, aliases, and tags are not supported"
        )
    if value[:1] in {"'", '"'}:
        if len(value) < 2 or value[-1] != value[0]:
            raise RegistryValidationError(f"line {line}: malformed quoted scalar")
        return value[1:-1]
    return value


def _parse_subset(path: Path) -> dict[str, Any]:
    try:
        raw_lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as error:
        raise RegistryValidationError(f"cannot read registry: {error}") from error
    tokens: list[tuple[int, int, str]] = []
    for number, raw in enumerate(raw_lines, 1):
        if "\t" in raw:
            raise RegistryValidationError(f"line {number}: tabs are not allowed")
        line = _strip_comment(raw).rstrip()
        if not line.strip():
            continue
        indent = len(line) - len(line.lstrip(" "))
        if indent % 2:
            raise RegistryValidationError(
                f"line {number}: indentation must use two-space levels"
            )
        tokens.append((indent, number, line[indent:]))
    def sequence(index: int, indent: int) -> tuple[list[str], int]:
        out: list[str] = []
        while index < len(tokens) and tokens[index][0] == indent:
            _, number, text = tokens[index]
            match = re.fullmatch(r"- +(.*)", text)
            if not match:
                raise RegistryValidationError(f"line {number}: expected scalar list item")
            out.append(_scalar(match.group(1), number))
            index += 1
            if index < len(tokens) and tokens[index][0] > indent:
                raise RegistryValidationError(
                    f"line {tokens[index][1]}: nested list values are not supported"
                )
        return out, index
    def mapping(index: int, indent: int) -> tuple[dict[str, Any], int]:
        out: dict[str, Any] = {}
        while index < len(tokens) and tokens[index][0] == indent:
            _, number, text = tokens[index]
            if text.startswith("-"):
                break
            match = re.fullmatch(r"([A-Za-z_][A-Za-z0-9_-]*):(?: +(.*))?", text)
            if not match:
                raise RegistryValidationError(f"line {number}: expected block mapping entry")
            key, inline = match.groups()
            if key in out:
                raise RegistryValidationError(f"line {number}: duplicate key `{key}`")
            index += 1
            if inline is not None:
                out[key] = _scalar(inline, number)
            elif index < len(tokens) and tokens[index][0] > indent:
                child = tokens[index][0]
                if child != indent + 2:
                    raise RegistryValidationError(
                        f"line {tokens[index][1]}: invalid indentation jump"
                    )
                parser = sequence if tokens[index][2].startswith("-") else mapping
                out[key], index = parser(index, child)
            else:
                out[key] = None
        return out, index
    if not tokens:
        raise RegistryValidationError("registry is empty")
    result, end = mapping(0, 0)
    if end != len(tokens):
        raise RegistryValidationError(
            f"line {tokens[end][1]}: invalid document structure"
        )
    return result
def _mapping(value: Any, allowed: set[str], label: str) -> dict[str, Any]:
    if not isinstance(value, dict): raise RegistryValidationError(f"{label} must be a block mapping")
    unknown = sorted(set(value) - allowed)
    if unknown: raise RegistryValidationError(f"{label}: unknown {label.rstrip('s')} key(s): {', '.join(unknown)}")
    return value
def _scalar_required(value: Any, label: str) -> str:
    if not isinstance(value, str) or not value.strip() or value == "[]": raise RegistryValidationError(f"{label} must be nonblank")
    return value.strip()
def _strings(value: Any, label: str, required: bool = False) -> tuple[str, ...]:
    if value == "[]": value = []
    if not isinstance(value, list): raise RegistryValidationError(f"{label} must be a list")
    if required and not value: raise RegistryValidationError(f"{label} must contain at least one value")
    if any(not isinstance(item, str) or not item.strip() for item in value): raise RegistryValidationError(f"{label} must contain only nonblank strings")
    return tuple(item.strip() for item in value)
def _relative_markers(values: tuple[str, ...], label: str) -> tuple[str, ...]:
    for value in values:
        marker = Path(value)
        if marker.is_absolute() or ".." in marker.parts:
            raise RegistryValidationError(f"{label} contains an unsafe repository-relative marker")
    return values


def load_registry(path: Path) -> StackCapabilityRegistry:
    data = _parse_subset(path)
    _mapping(data, TOP_LEVEL_KEYS, "top-level")
    missing = TOP_LEVEL_KEYS - set(data)
    if missing:
        raise RegistryValidationError(f"missing top-level key(s): {', '.join(sorted(missing))}")
    activation = _mapping(data["activation_contract"], ACTIVATION_CONTRACT_KEYS, "activation_contract")
    missing_activation = ACTIVATION_CONTRACT_KEYS - set(activation)
    if missing_activation:
        raise RegistryValidationError(
            f"activation_contract missing key(s): {', '.join(sorted(missing_activation))}"
        )
    raw_caps = _mapping(data["capabilities"], set(data["capabilities"]) if isinstance(data["capabilities"], dict) else set(), "capabilities")
    capabilities: dict[str, Capability] = {}
    for name, raw in raw_caps.items():
        fields = _mapping(raw, CAPABILITY_KEYS, name)
        absent = (CAPABILITY_KEYS - {"default_surfaces"}) - set(fields)
        if absent:
            raise RegistryValidationError(f"{name}: missing required field(s): {', '.join(sorted(absent))}")
        lifecycle = _scalar_required(fields["lifecycle"], f"{name}.lifecycle")
        if lifecycle not in LIFECYCLES:
            raise RegistryValidationError(
                f"{name}: invalid lifecycle `{lifecycle}`; expected one of {', '.join(sorted(LIFECYCLES))}"
            )
        markers = _mapping(fields["detection_markers"], DETECTION_MARKER_KEYS, f"{name}.detection_markers")
        marker_values = {key: _strings(markers.get(key, []), f"{name}.detection_markers.{key}") for key in DETECTION_MARKER_KEYS}
        for key in ("root_files", "nested_files", "companion_files"):
            marker_values[key] = _relative_markers(marker_values[key], f"{name}.detection_markers.{key}")
        capabilities[name] = Capability(
            name=name,
            lifecycle=lifecycle,
            purpose=_scalar_required(fields["purpose"], f"{name}.purpose"),
            default_surfaces=_strings(fields.get("default_surfaces", []), f"{name}.default_surfaces"),
            activation_markers=_strings(fields["activation_markers"], f"{name}.activation_markers", True),
            detection_markers=DetectionMarkers(**marker_values),
            execution_policy=_scalar_required(fields["execution_policy"], f"{name}.execution_policy"),
        )
    missing_baseline = REQUIRED_BASELINE_CAPABILITIES - set(raw_caps)
    if missing_baseline:
        raise RegistryValidationError(
            f"missing capability block(s): {', '.join(sorted(missing_baseline))}"
        )
    return StackCapabilityRegistry(
        schema_version=_scalar_required(data["schema_version"], "schema_version"),
        ecosystem=_scalar_required(data["ecosystem"], "ecosystem"),
        activation_contract={
            key: _strings(activation[key], f"activation_contract.{key}", True)
            for key in ACTIVATION_CONTRACT_KEYS
        },
        capabilities=capabilities,
    )
