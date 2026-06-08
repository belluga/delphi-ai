---
name: claude-cli-calling
description: "Use when calling Claude CLI non-interactively from the terminal. Covers the canonical invocation contract for `claude -p`, safe prompt transport via stdin, correct handling of `--add-dir`, constrained tool access, long-running print sessions, and compact-packet fallback for large reviews."
---

# Claude CLI Calling

Use this skill whenever the task requires invoking `claude` from shell scripts or terminal commands.

Deterministic depth: already-backed for invocation mechanics through the bundled runner. Prompt design, review focus, and output interpretation remain judgment-led.

## Canonical contract

1. Prefer `claude -p` for non-interactive runs.
2. Prefer sending the prompt through `stdin` instead of as a positional argument.
   - This avoids `--add-dir` parsing mistakes.
   - This avoids shell-quoting drift on large prompts.
3. Use `--allowedTools` whenever tool access should be bounded.
4. Use `--permission-mode bypassPermissions` only in trusted local workspaces.
5. For large diffs or large packets, shrink the packet before retrying.
6. If a `claude -p` run is slow or stalls, first reduce scope before widening permissions or tools.

## Failure modes this skill prevents

- Prompt treated as an extra path after `--add-dir`
- Broken quoting in inline prompts
- Huge review packets timing out while tools roam across the repo
- Inconsistent permission/tool flags across scripts

## Default runner

Use the bundled runner instead of hand-writing `claude` invocations:

```bash
bash /home/elton/.codex/skills/claude-cli-calling/scripts/run_claude_print.sh \
  --workdir <dir> \
  [--add-dir <dir> ...] \
  [--allowed-tools "Bash(cat:*) Bash(rg:*)"] \
  [--output-format text|json|stream-json] \
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
- For review simulations, prefer one-line structured findings:
  - `severity | locus | finding | fix`

## Related skills

- `copilot-pr-review`: use this skill’s runner for its Claude review passes.
