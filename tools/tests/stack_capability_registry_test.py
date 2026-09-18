#!/usr/bin/env python3
"""Focused contract tests for the strict stack-capability registry loader."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from lib.stack_capability_registry import RegistryValidationError, load_registry


VALID = '''\
schema_version: 1
ecosystem: belluga
activation_contract:
  authority_order:
    - active_todo
  project_contract_surfaces:
    - foundation_documentation/
  non_activation_signals:
    - registry presence
capabilities:
  docker:
    lifecycle: available
    purpose: Runtime orchestration.
    activation_markers:
      - compose files
    detection_markers:
      root_files:
        - compose.yml
      nested_files: []
    execution_policy: Use project-owned topology.
  flutter:
    lifecycle: available
    purpose: Client.
    activation_markers:
      - project contract
    detection_markers:
      root_files: []
      nested_files: []
    execution_policy: Use project-owned topology.
  laravel:
    lifecycle: available
    purpose: Backend.
    activation_markers:
      - project contract
    detection_markers:
      root_files: []
      nested_files: []
    execution_policy: Use project-owned topology.
  go:
    lifecycle: future
    purpose: Future backend.
    activation_markers:
      - project contract
    detection_markers:
      root_files: []
      nested_files: []
    execution_policy: Use project-owned topology.
  custom:
    lifecycle: experimental
    purpose: Generic fixture capability.
    default_surfaces: []
    activation_markers:
      - project contract
    detection_markers:
      root_files: []
      nested_files: []
      package_json_requires_any:
        - "@scope/pkg"
    execution_policy: Remains non-activating.
'''


class StackCapabilityRegistryTest(unittest.TestCase):
    def load(self, content: str):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "registry.yaml"
            path.write_text(content, encoding="utf-8")
            return load_registry(path)

    def test_loads_every_declared_capability_and_lifecycle(self) -> None:
        registry = self.load(VALID)
        self.assertEqual(registry.capabilities["custom"].lifecycle, "experimental")
        self.assertEqual(registry.capabilities["custom"].detection_markers.package_json_requires_any, ("@scope/pkg",))

    def test_canonical_registry_contains_exact_experimental_candidates(self) -> None:
        registry = load_registry(Path(__file__).resolve().parents[2] / "config" / "stack_capabilities.yaml")
        expected = {"nestjs", "react", "vite", "postgresql", "prisma", "railway"}
        experimental = {
            name for name, capability in registry.capabilities.items()
            if capability.lifecycle == "experimental"
        }
        self.assertEqual(experimental, expected)

    def test_canonical_nestjs_capability_has_an_independent_package_pending_admission(self) -> None:
        registry = load_registry(Path(__file__).resolve().parents[2] / "config" / "stack_capabilities.yaml")
        nestjs = registry.capabilities["nestjs"]
        self.assertEqual(nestjs.lifecycle, "experimental")
        self.assertEqual(
            nestjs.detection_markers.package_json_requires_any,
            ("@nestjs/core",),
        )
        joined_surfaces = "\n".join(nestjs.default_surfaces)
        self.assertIn(
            "skills/rule-nestjs-nestjs-architecture-always-on/",
            nestjs.default_surfaces,
        )
        for unrelated in ("react", "vite", "postgresql", "prisma", "docker", "railway"):
            self.assertNotIn(f"/{unrelated}/", joined_surfaces)

    def test_canonical_react_capability_has_an_independent_package_pending_admission(self) -> None:
        registry = load_registry(Path(__file__).resolve().parents[2] / "config" / "stack_capabilities.yaml")
        react = registry.capabilities["react"]
        self.assertEqual(react.lifecycle, "experimental")
        self.assertEqual(
            react.detection_markers.package_json_requires_any,
            ("react-dom",),
        )
        self.assertIn(
            "skills/rule-react-react-architecture-always-on/",
            react.default_surfaces,
        )
        joined_surfaces = "\n".join(react.default_surfaces)
        for unrelated in ("nestjs", "vite", "postgresql", "prisma", "docker", "railway"):
            self.assertNotIn(f"/{unrelated}/", joined_surfaces)

    def test_remaining_candidate_capabilities_have_independent_packages(self) -> None:
        registry = load_registry(Path(__file__).resolve().parents[2] / "config" / "stack_capabilities.yaml")
        cases = {
            "vite": (("vite",), "skills/rule-vite-vite-build-runtime-always-on/"),
            "postgresql": ((), "skills/rule-postgresql-postgresql-data-integrity-always-on/"),
            "prisma": (("@prisma/client", "prisma"), "skills/rule-prisma-prisma-schema-migration-always-on/"),
            "railway": ((), "skills/rule-railway-railway-deployment-contract-always-on/"),
        }
        for name, (dependencies, rule_surface) in cases.items():
            with self.subTest(name=name):
                capability = registry.capabilities[name]
                self.assertEqual(capability.lifecycle, "experimental")
                self.assertEqual(
                    capability.detection_markers.package_json_requires_any,
                    dependencies,
                )
                self.assertIn(rule_surface, capability.default_surfaces)
                joined = "\n".join(capability.default_surfaces)
                for unrelated in (set(cases) | {"nestjs", "react", "docker"}) - {name}:
                    self.assertNotIn(f"/{unrelated}/", joined)

    def test_rejects_unknown_capability_field(self) -> None:
        with self.assertRaisesRegex(RegistryValidationError, "unknown .* key"):
            self.load(VALID.replace("    purpose: Generic fixture capability.\n", "    purpose: Generic fixture capability.\n    active: true\n"))

    def test_rejects_unknown_structural_keys(self) -> None:
        cases = (
            ("schema_version: 1", "unexpected: value\nschema_version: 1"),
            ("  authority_order:", "  unexpected:\n    - value\n  authority_order:"),
            ("      root_files: []", "      unknown_marker: []\n      root_files: []"),
        )
        for original, replacement in cases:
            with self.subTest(replacement=replacement):
                with self.assertRaisesRegex(RegistryValidationError, "unknown"):
                    self.load(VALID.replace(original, replacement))

    def test_rejects_unsupported_yaml_and_wrong_marker_shape(self) -> None:
        with self.assertRaisesRegex(RegistryValidationError, "flow mappings"):
            self.load(VALID.replace("      root_files: []", "      root_files: { unsafe: true }") )
        with self.assertRaisesRegex(RegistryValidationError, "must be a list"):
            self.load(VALID.replace("      nested_files: []", "      nested_files: schema.prisma"))

    def test_rejects_duplicate_keys_and_blank_required_values(self) -> None:
        with self.assertRaisesRegex(RegistryValidationError, "duplicate key"):
            self.load(VALID.replace("ecosystem: belluga", "ecosystem: belluga\necosystem: duplicate"))
        with self.assertRaisesRegex(RegistryValidationError, "must be nonblank"):
            self.load(VALID.replace("    purpose: Generic fixture capability.", "    purpose:"))

    def test_rejects_absolute_and_parent_file_markers(self) -> None:
        with self.assertRaisesRegex(RegistryValidationError, "unsafe repository-relative marker"):
            self.load(VALID.replace("      root_files: []", "      root_files:\n        - /etc/passwd"))
        with self.assertRaisesRegex(RegistryValidationError, "unsafe repository-relative marker"):
            self.load(VALID.replace("      nested_files: []", "      nested_files:\n        - ../outside"))

    def test_rejects_invalid_lifecycle_for_arbitrary_capability(self) -> None:
        with self.assertRaisesRegex(RegistryValidationError, "invalid lifecycle"):
            self.load(VALID.replace("    lifecycle: experimental", "    lifecycle: unsupported"))

    def test_rejects_malformed_optional_and_unsupported_yaml(self) -> None:
        with self.assertRaisesRegex(RegistryValidationError, "default_surfaces must be a list"):
            self.load(VALID.replace("    default_surfaces: []", "    default_surfaces: web"))
        for token in ("&marker", "*marker", "!tagged"):
            with self.subTest(token=token):
                with self.assertRaisesRegex(RegistryValidationError, "anchors, aliases, and tags"):
                    self.load(VALID.replace("    purpose: Generic fixture capability.", f"    purpose: {token}"))

    def test_rejects_missing_baseline_capability(self) -> None:
        with self.assertRaisesRegex(RegistryValidationError, "missing capability block.*go"):
            self.load(VALID.replace("  go:\n    lifecycle: future\n    purpose: Future backend.\n    activation_markers:\n      - project contract\n    detection_markers:\n      root_files: []\n      nested_files: []\n    execution_policy: Use project-owned topology.\n", ""))


if __name__ == "__main__":
    unittest.main()
