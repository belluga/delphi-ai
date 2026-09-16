const crypto = require('node:crypto');
const http = require('node:http');
const vscode = require('vscode');

const bridgeVersion = '0.1.0';
const defaultPort = 40361;

/** @type {number} */
let diagnosticsRevision = 0;
/** @type {string} */
let lastDiagnosticsChangeAt = new Date().toISOString();

function asDiagnosticCode(code) {
  if (code === undefined || code === null) {
    return null;
  }

  if (typeof code === 'object') {
    return String(code.value);
  }

  return String(code);
}

function serializeDiagnostic(uri, diagnostic) {
  return {
    path: uri.fsPath,
    uri: uri.toString(),
    severity: vscode.DiagnosticSeverity[diagnostic.severity] ?? 'Unknown',
    source: diagnostic.source ?? null,
    code: asDiagnosticCode(diagnostic.code),
    message: diagnostic.message,
    range: {
      start: {
        line: diagnostic.range.start.line + 1,
        character: diagnostic.range.start.character + 1,
      },
      end: {
        line: diagnostic.range.end.line + 1,
        character: diagnostic.range.end.character + 1,
      },
    },
  };
}

function isDartFile(uri) {
  return uri.scheme === 'file' && uri.fsPath.endsWith('.dart');
}

function isWithinScope(uri, scope) {
  if (!scope) {
    return true;
  }

  const normalizedScope = scope.endsWith('/') ? scope : `${scope}/`;
  return uri.fsPath === scope || uri.fsPath.startsWith(normalizedScope);
}

function currentSnapshot(scope) {
  const diagnostics = vscode.languages
    .getDiagnostics()
    .filter(([uri]) => isDartFile(uri) && isWithinScope(uri, scope))
    .flatMap(([uri, entries]) =>
      entries.map((diagnostic) => serializeDiagnostic(uri, diagnostic)),
    )
    .sort((left, right) => {
      const pathOrder = left.path.localeCompare(right.path);
      if (pathOrder !== 0) {
        return pathOrder;
      }
      return left.range.start.line - right.range.start.line;
    });

  const payload = {
    schemaVersion: 1,
    bridgeVersion,
    capturedAt: new Date().toISOString(),
    diagnosticsRevision,
    lastDiagnosticsChangeAt,
    scope: scope ?? null,
    workspaceFolders: (vscode.workspace.workspaceFolders ?? []).map(
      (folder) => folder.uri.fsPath,
    ),
    diagnosticCount: diagnostics.length,
    diagnostics,
    completeness:
      'current VS Code diagnostic snapshot only; the public VS Code API does not expose Dart Analysis Server completion state.',
  };

  return {
    payload,
    etag: crypto
      .createHash('sha256')
      .update(JSON.stringify(payload.diagnostics))
      .digest('hex'),
  };
}

function writeJson(response, statusCode, value, headers = {}) {
  response.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Cache-Control': 'no-store',
    ...headers,
  });
  response.end(JSON.stringify(value, null, 2));
}

function startBridge(port) {
  return http.createServer((request, response) => {
    const requestUrl = new URL(request.url ?? '/', 'http://127.0.0.1');

    if (request.method !== 'GET') {
      writeJson(response, 405, { error: 'read-only bridge; use GET' });
      return;
    }

    if (requestUrl.pathname === '/health') {
      writeJson(response, 200, {
        bridgeVersion,
        port,
        diagnosticsRevision,
        lastDiagnosticsChangeAt,
      });
      return;
    }

    if (requestUrl.pathname === '/diagnostics') {
      const scope = requestUrl.searchParams.get('scope') ?? undefined;
      const snapshot = currentSnapshot(scope);
      writeJson(response, 200, snapshot.payload, { ETag: snapshot.etag });
      return;
    }

    writeJson(response, 404, {
      error: 'not found',
      endpoints: ['/health', '/diagnostics?scope=<absolute-path>'],
    });
  });
}

function activate(context) {
  const configuredPort = vscode.workspace
    .getConfiguration('delphiDiagnosticsBridge')
    .get('port', defaultPort);
  const port = Number.isInteger(configuredPort) ? configuredPort : defaultPort;

  const diagnosticsListener = vscode.languages.onDidChangeDiagnostics(() => {
    diagnosticsRevision += 1;
    lastDiagnosticsChangeAt = new Date().toISOString();
  });
  context.subscriptions.push(diagnosticsListener);

  const server = startBridge(port);
  server.listen(port, '127.0.0.1');
  server.on('error', (error) => {
    void vscode.window.showErrorMessage(
      `Delphi diagnostics bridge could not listen on 127.0.0.1:${port}: ${error.message}`,
    );
  });
  context.subscriptions.push({ dispose: () => server.close() });

  context.subscriptions.push(
    vscode.commands.registerCommand(
      'delphiDiagnosticsBridge.showStatus',
      () => {
        const snapshot = currentSnapshot(undefined);
        return vscode.window.showInformationMessage(
          `Delphi diagnostics bridge: ${snapshot.payload.diagnosticCount} Dart diagnostics at http://127.0.0.1:${port}/diagnostics`,
        );
      },
    ),
  );
}

function deactivate() {}

module.exports = { activate, deactivate };
