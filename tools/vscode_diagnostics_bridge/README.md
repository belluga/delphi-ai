# Delphi VS Code Diagnostics Bridge

Read-only local VS Code extension used to expose the current Dart-file diagnostics
collection without starting a second analyzer process.

## Contract

- The extension reads `vscode.languages.getDiagnostics()` from the active VS Code
  extension host.
- It binds only to `127.0.0.1` and accepts only `GET` requests.
- `GET /diagnostics?scope=<absolute-path>` returns a current snapshot of Dart-file
  diagnostics below the optional absolute path.
- `GET /health` exposes liveness and diagnostic-revision metadata.
- The response explicitly declares that it is a snapshot: the public VS Code API
  does not expose whether Dart Analysis Server has completed its full workspace
  analysis. It is the agent-readable local static-analysis evidence when the
  diagnostics snapshot is stable for the full declared workspace, but it must
  be labeled `live Problems snapshot`, never a completed CLI analyzer or a
  public-API proof of Analysis Server completion.
- A clean local gate contains no `Error` or `Warning` diagnostic. `Information`
  diagnostics remain visible and need explicit owner/classification rather than
  being discarded. Query `/health` before and after the scoped snapshot and
  recapture after the project-declared quiet interval when its revision changes.
- The agent must not start a competing CLI analyzer to recreate this evidence.
  Pipeline-owned analyzer jobs remain separate CI evidence.

## Package and install

From the environment root:

```bash
bash delphi-ai/tools/vscode_diagnostics_bridge/package_vsix.sh
code --install-extension delphi-ai/artifacts/vsix/belluga.delphi-vscode-diagnostics-bridge-0.1.0.vsix --force
```

Reload the current VS Code window once after installation. The bridge then starts
in the remote extension host and uses port `40361` unless the workspace setting
`delphiDiagnosticsBridge.port` overrides it.

## Query

```bash
curl --fail --silent --show-error \
  'http://127.0.0.1:40361/diagnostics?scope=/absolute/path/to/flutter-app'
```
