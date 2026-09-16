---
name: claude-cli-calling
description: "Use only for explicitly user-directed non-review Claude CLI terminal work. Covers the invocation contract for `claude -p`, safe prompt transport via stdin, constrained tool access, and liveness diagnostics."
---

# Claude CLI Calling

Use this skill only when the user explicitly requires a non-review `claude` terminal task.

## Delphi Review Boundary

Delphi reviews use fresh internal no-context reviewers only. Do not use this skill for critique, test-quality audit, architecture review, final review, promotion review, or supporting review evidence. An external-provider result is not a substitute for an internal reviewer and must not unblock a required review gate.

Deterministic depth: already-backed for invocation mechanics through the bundled runner. Prompt design, review focus, and output interpretation remain judgment-led.

## Canonical contract

1. Prefer `claude -p` for non-interactive runs.
2. Prefer sending the prompt through `stdin` instead of as a positional argument.
   - This avoids `--add-dir` parsing mistakes.
   - This avoids shell-quoting drift on large prompts.
3. Use `--allowedTools` whenever tool access should be bounded.
4. Use `--permission-mode bypassPermissions` only in trusted local workspaces.
5. For large diffs or large packets, shrink the packet before retrying.
6. Tool-using reviews that require a parseable final answer must use `--structured-result-output <path>`. It forces `stream-json`, captures the complete tool lifecycle, and fails unless a terminal successful result is extracted.
7. When diagnosing whether a run is alive versus truly stuck, prefer an explicit `--output-format stream-json` run plus `--include-partial-messages` and `--verbose`. Structured-result runs capture their verbose stream privately to avoid truncating the caller's output channel.
8. If a `claude -p` run is slow or stalls, first determine whether the chosen output mode is simply silent-until-finish before changing scope, permissions, or tools.

## `--bare` authentication caveat

- Treat `--bare` as an authentication-mode change, not only as a lightweight runtime flag.
- In current Claude Code CLI releases, `--bare` disables hooks/LSP/plugin sync **and also disables OAuth/keychain auth reads**.
- In `--bare`, Anthropic auth must come from `ANTHROPIC_API_KEY` or an `apiKeyHelper` supplied via `--settings`.
- If the local environment is authenticated through Claude Code OAuth/login state in `~/.claude/**`, do **not** assume `--bare` will work.
- When the task explicitly needs the existing OAuth-authenticated CLI session, prefer normal `claude -p` with bounded `--allowedTools` instead of `--bare`.
- When a caller explicitly requires both `--bare` and a Claude-hosted model, first verify that API-key auth is actually available; otherwise report the constraint instead of silently downgrading the review.

## Failure modes this skill prevents

- Prompt treated as an extra path after `--add-dir`
- Broken quoting in inline prompts
- Huge review packets timing out while tools roam across the repo
- Inconsistent permission/tool flags across scripts
- Misdiagnosing a silent `json`/`text` run as a hang
- Disabling all tools for a review that actually depends on local file inspection
- Letting a tool-starved review drift into pseudo-command text instead of findings

## Default runner

Use the bundled runner instead of hand-writing `claude` invocations:

```bash
bash /home/elton/.codex/skills/claude-cli-calling/scripts/run_claude_print.sh \
  --workdir <dir> \
  [--add-dir <dir> ...] \
  [--tools "Bash,Read"] \
  [--allowed-tools "Bash(cat:*) Bash(rg:*)"] \
  [--model sonnet --effort max --no-session-persistence] \
  [--json-schema-file <schema.json>] \
  [--structured-result-output <result.json>] \
  [--output-format text|json|stream-json] \
  [--include-partial-messages] \
  [--verbose] \
  [--permission-mode bypassPermissions|default|acceptEdits|plan] \
  [--prompt-file <file> | --prompt "<text>" | --stdin]
```

## Prompt transport policy

- Use `--prompt-file` for long prompts or review packets.
- Use `--stdin` when another command already produces the prompt.
- Use inline `--prompt` only for short prompts.

The runner always feeds Claude through stdin, even when `--prompt` is provided, so the prompt never competes with option parsing.

## Tool policy

- Narrow tools to the minimum needed.
- For read-only review work, prefer:
  - `Bash(cat:*)`
  - `Bash(sed:*)`
  - `Bash(rg:*)`
  - `Bash(git:*)`
- Add write/edit tools only when the Claude run is expected to patch files.
- Do not set tools to empty for a review that must inspect local files. That invocation shape often produces planning text about commands Claude wishes it could run instead of an actionable audit.

## Liveness and diagnostic mode

- `--output-format text` and `--output-format json` may remain silent until the run completes. Silence alone is not evidence of a hang.
- Current Claude CLI print sessions can end after a read-only tool call without emitting a usable `text`/`json` terminal answer. Do not count an empty redirected output as a completed review.
- For any tool-using review whose result feeds `subagent_review_merge.py` or another parser, invoke the runner with `--structured-result-output <result-path>` and `--json-schema-file <schema-path>`. The runner forces the stream-json path, captures it privately, accepts exactly one direct or fenced terminal JSON object, validates it against the schema, and fails on absent, ambiguous, unsuccessful, or schema-invalid output.
- A structured run emits only concise lifecycle messages to its caller. If it fails, it preserves the raw stream at `<result-path>.stream.jsonl`; inspect that artifact before retrying. Use a separate explicit stream-json diagnostic run when live event output is the goal.
- In current Claude CLI builds, `--print` + `--output-format stream-json` requires `--verbose`. Treat that as part of the canonical diagnostic shape, not an optional extra.
- When verifying that Claude is progressing, use:

```bash
bash /home/elton/.codex/skills/claude-cli-calling/scripts/run_claude_print.sh \
  --workdir <dir> \
  --output-format stream-json \
  --include-partial-messages \
  --verbose \
  --allowed-tools "Bash(cat:*) Bash(sed:*) Bash(rg:*) Bash(git:*)" \
  --prompt-file <file>
```

- Use this diagnostic shape when:
  - the run appears stuck;
  - you need to distinguish "thinking" from a dead process;
  - you need to see whether Claude is producing intermediate findings or only status updates.
- If the task is a packet-only reasoning pass that genuinely does not need filesystem inspection, toolless runs are acceptable. Otherwise, prefer the minimum read-only tool set above.
- If a streamed run starts emitting pseudo-command or pseudo-shell plans instead of findings/results, treat that as a bad invocation shape:
  1. abort the run;
    2. relaunch with the minimum read-only tool set if files must be inspected;
    3. or shrink the packet if the model is over-scoping.
- If a structured run fails after a tool call, retain the emitted stream transcript for diagnosis, fix the invocation/tool boundary, and rerun once. Never synthesize a reviewer JSON result or merge an empty response.

## Large-review fallback

When a review packet is too large or slow:

1. Keep the root packet summary.
2. Build a compact packet with only:
   - changed-file list
   - diffstat
   - the 2-6 most relevant file excerpts
3. Retry with stdin-only packet review.
4. Only then widen scope or split into multiple passes.

## Polling and long runs

- When invoked through shell tools that return a session id, poll until exit instead of assuming failure.
- Do not abandon running sessions when the request still depends on them.

## Output expectations

- Ask for a rigid output shape when downstream parsing or comparison matters.
- Use the CLI `--json-schema-file` plus `--structured-result-output` for schema-bound review results. Prompt wording remains responsible for the review's substantive scope; the schema/result extractor normalizes and validates only the delivered result shape.
- For review simulations, prefer one-line structured findings:
  - `severity | locus | finding | fix`
- For streamed diagnostics, expect status/assistant chunks before the final answer. Judge liveness from continued chunk emission, not only from final findings.

## Invocation selection notes

- Use the bundled runner for the default authenticated path when its option surface is sufficient.
- If the task needs CLI flags the runner does not expose yet, hand-write the `claude -p` invocation while preserving the same stdin-first transport and bounded-tool contract.
- If a review request mentions `--bare`, explicitly check whether the workspace depends on OAuth credentials before using it.
- If the goal is to debug liveness/progress, prefer `stream-json` over `text`/`json` before declaring the run hung.

## Related skills

- This skill is not a review-gate dependency under Delphi's internal-review policy.
