#!/usr/bin/env python3
"""Focused tests for the Node capability surface audit."""

from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOL = ROOT / "tools" / "node_capability_surface_audit.py"


class NodeCapabilitySurfaceAuditTest(unittest.TestCase):
    def run_audit(self, repo: Path, *arguments: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["python3", str(TOOL), "--repo", str(repo), *arguments, "--format", "json"],
            check=False,
            capture_output=True,
            text=True,
        )

    def write_manifest(self, path: Path, payload: object) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(payload), encoding="utf-8")

    def test_exact_nestjs_dependency_and_required_scripts_pass(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            self.write_manifest(
                repo / "apps" / "api" / "package.json",
                {
                    "packageManager": "pnpm@10.0.0",
                    "dependencies": {"@nestjs/core": "^11.0.0"},
                    "scripts": {"build": "nest build", "test": "vitest run", "lint": "eslint ."},
                },
            )
            (repo / "apps" / "api" / "pnpm-lock.yaml").touch()

            completed = self.run_audit(
                repo,
                "--expect",
                "nestjs",
                "--require-script",
                "build",
                "--require-script",
                "test",
            )

            self.assertEqual(completed.returncode, 0, completed.stderr)
            result = json.loads(completed.stdout)
            self.assertEqual(result["overall_outcome"], "ready")
            self.assertEqual(
                result["expected"]["nestjs"]["manifests"],
                ["apps/api/package.json"],
            )
            self.assertEqual(result["manifests"][0]["package_manager"], "pnpm@10.0.0")
            self.assertEqual(result["manifests"][0]["lockfiles"], ["pnpm-lock.yaml"])

    def test_near_match_does_not_activate_nestjs(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            self.write_manifest(
                repo / "package.json",
                {"devDependencies": {"@nestjs/cli": "^11.0.0"}},
            )

            completed = self.run_audit(repo, "--expect", "nestjs")

            self.assertEqual(completed.returncode, 2)
            result = json.loads(completed.stdout)
            self.assertIn(
                "missing exact dependency evidence for nestjs: @nestjs/core",
                result["diagnostics"],
            )

    def test_react_vite_prisma_and_all_dependency_sections_are_inventoried(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            self.write_manifest(
                repo / "package.json",
                {
                    "dependencies": {"@nestjs/core": "^11"},
                    "devDependencies": {"vite": "^7", "@prisma/client": "^6"},
                    "peerDependencies": {"react-dom": ">=19"},
                    "optionalDependencies": {"react-dom": "^19"},
                },
            )

            completed = self.run_audit(
                repo,
                "--expect",
                "nestjs",
                "--expect",
                "react",
                "--expect",
                "prisma",
                "--expect",
                "vite",
            )

            self.assertEqual(completed.returncode, 0, completed.stderr)
            result = json.loads(completed.stdout)
            evidence = result["manifests"][0]["dependency_evidence"]
            self.assertEqual(evidence["@nestjs/core"], ["dependencies"])
            self.assertEqual(evidence["vite"], ["devDependencies"])
            self.assertEqual(evidence["@prisma/client"], ["devDependencies"])
            self.assertEqual(
                evidence["react-dom"],
                ["peerDependencies", "optionalDependencies"],
            )

    def test_prisma_cli_is_valid_independent_prisma_evidence(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            self.write_manifest(
                repo / "package.json",
                {"devDependencies": {"prisma": "^6"}},
            )

            completed = self.run_audit(repo, "--expect", "prisma")

            self.assertEqual(completed.returncode, 0)
            result = json.loads(completed.stdout)
            self.assertEqual(result["expected"]["prisma"]["manifests"], ["package.json"])

    def test_missing_required_script_blocks(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            self.write_manifest(
                repo / "package.json",
                {"dependencies": {"@nestjs/core": "^11.0.0"}, "scripts": {"build": "nest build"}},
            )

            completed = self.run_audit(
                repo,
                "--expect",
                "nestjs",
                "--require-script",
                "test:e2e",
            )

            self.assertEqual(completed.returncode, 2)
            result = json.loads(completed.stdout)
            self.assertIn(
                "missing required script for nestjs in package.json: test:e2e",
                result["diagnostics"],
            )

    def test_required_scripts_cannot_be_aggregated_across_manifests(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            self.write_manifest(
                repo / "apps" / "api" / "package.json",
                {"dependencies": {"@nestjs/core": "^11"}, "scripts": {"build": "nest build"}},
            )
            self.write_manifest(
                repo / "apps" / "worker" / "package.json",
                {"dependencies": {"@nestjs/core": "^11"}, "scripts": {"test:e2e": "vitest run"}},
            )

            ambiguous = self.run_audit(
                repo,
                "--expect",
                "nestjs",
                "--require-script",
                "build",
                "--require-script",
                "test:e2e",
            )
            self.assertEqual(ambiguous.returncode, 2)
            self.assertIn(
                "multiple manifests match nestjs; pass --manifest",
                "\n".join(json.loads(ambiguous.stdout)["diagnostics"]),
            )

            scoped = self.run_audit(
                repo,
                "--expect",
                "nestjs",
                "--manifest",
                "apps/api/package.json",
                "--require-script",
                "build",
            )
            self.assertEqual(scoped.returncode, 0, scoped.stdout)
            self.assertEqual(
                json.loads(scoped.stdout)["selected_manifests"],
                ["apps/api/package.json"],
            )

    def test_manifest_selector_rejects_parent_traversal(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            completed = self.run_audit(
                Path(directory),
                "--expect",
                "nestjs",
                "--manifest",
                "../package.json",
            )
            self.assertEqual(completed.returncode, 2)
            self.assertIn("invalid --manifest path", completed.stderr)

    def test_ignored_dependency_tree_cannot_satisfy_expectation(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            self.write_manifest(
                repo / "node_modules" / "nest" / "package.json",
                {"dependencies": {"@nestjs/core": "^11.0.0"}},
            )
            self.write_manifest(repo / "package.json", {"dependencies": {"typescript": "^5.0.0"}})

            completed = self.run_audit(repo, "--expect", "nestjs")

            self.assertEqual(completed.returncode, 2)
            result = json.loads(completed.stdout)
            self.assertEqual(result["expected"]["nestjs"]["manifests"], [])
            self.assertEqual([row["path"] for row in result["manifests"]], ["package.json"])

    def test_symlinked_manifest_tree_is_ignored(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            repo = base / "repo"
            external = base / "external"
            repo.mkdir()
            self.write_manifest(repo / "package.json", {"dependencies": {"typescript": "^5"}})
            self.write_manifest(
                external / "package.json",
                {"dependencies": {"@nestjs/core": "^11"}},
            )
            (repo / "linked-app").symlink_to(external, target_is_directory=True)

            completed = self.run_audit(repo, "--expect", "nestjs")

            self.assertEqual(completed.returncode, 2)
            result = json.loads(completed.stdout)
            self.assertEqual([row["path"] for row in result["manifests"]], ["package.json"])
            self.assertEqual(result["expected"]["nestjs"]["manifests"], [])

    def test_oversized_manifest_blocks_without_reading_content(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            secret = "do-not-echo-this-value"
            (repo / "package.json").write_text(
                '{"dependencies":{"@nestjs/core":"^11"},"padding":"'
                + ("x" * (1024 * 1024))
                + secret
                + '"}',
                encoding="utf-8",
            )

            completed = self.run_audit(repo, "--expect", "nestjs")

            self.assertEqual(completed.returncode, 2)
            self.assertNotIn(secret, completed.stdout)
            self.assertIn("exceeds 1048576 bytes", completed.stdout)

    def test_invalid_manifest_blocks_without_leaking_content(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            repo = Path(directory)
            (repo / "package.json").write_text('{"token":"secret",', encoding="utf-8")

            completed = self.run_audit(repo, "--expect", "nestjs")

            self.assertEqual(completed.returncode, 2)
            self.assertNotIn("secret", completed.stdout)
            result = json.loads(completed.stdout)
            self.assertTrue(result["diagnostics"][0].startswith("invalid manifest package.json:"))


if __name__ == "__main__":
    unittest.main()
