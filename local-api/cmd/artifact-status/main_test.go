package main

import (
	"bytes"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

func artifactFixture(t *testing.T) (string, string, string) {
	t.Helper()
	workspace := t.TempDir()
	project := filepath.Join(workspace, "project")
	foundation := filepath.Join(workspace, "foundation")
	for _, root := range []string{project, foundation} {
		if err := os.MkdirAll(root, 0o755); err != nil {
			t.Fatal(err)
		}
	}
	write := func(path, value string) {
		t.Helper()
		if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(path, []byte(value), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	write(filepath.Join(foundation, "prototypes/catalog.json"), `{"schema_version":"1","project_id":"fixture-project","prototypes":[]}`)
	gitFixture(t, foundation, "init", "-q")
	gitFixture(t, foundation, "config", "user.email", "fixture@example.invalid")
	gitFixture(t, foundation, "config", "user.name", "Fixture")
	gitFixture(t, foundation, "add", "--all")
	gitFixture(t, foundation, "commit", "-qm", "fixture")
	return workspace, project, foundation
}

func gitFixture(t *testing.T, root string, args ...string) {
	t.Helper()
	cmd := exec.Command("git", append([]string{"-C", root}, args...)...)
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("git %v: %v: %s", args, err, out)
	}
}

func TestPrototypesUsesExplicitContextAndStdoutOnly(t *testing.T) {
	workspace, _, _ := artifactFixture(t)
	var stdout, stderr bytes.Buffer
	code := run([]string{"prototypes", "--workspace-root", workspace, "--project-root", "project", "--foundation-root", "foundation", "--project-id", "fixture-project", "--mode", "working-tree"}, &stdout, &stderr)
	if code != 0 || stderr.Len() != 0 {
		t.Fatalf("code=%d stderr=%q stdout=%q", code, stderr.String(), stdout.String())
	}
	if !strings.Contains(stdout.String(), `"outcome": "go"`) {
		t.Fatalf("unexpected response: %s", stdout.String())
	}
	if _, err := os.Stat(filepath.Join(workspace, "local-api")); !os.IsNotExist(err) {
		t.Fatalf("status created workspace output: %v", err)
	}
}

func TestPrototypesOperationMatrixAndNoFallback(t *testing.T) {
	workspace, _, _ := artifactFixture(t)
	var stdout, stderr bytes.Buffer
	code := run([]string{"prototypes", "--workspace-root", workspace, "--project-root", "project", "--foundation-root", "missing", "--project-id", "fixture-project", "--mode", "working-tree"}, &stdout, &stderr)
	if code != 2 || stderr.Len() != 0 || !strings.Contains(stdout.String(), `"outcome": "no_go"`) {
		t.Fatalf("code=%d stdout=%q stderr=%q", code, stdout.String(), stderr.String())
	}
	stdout.Reset()
	stderr.Reset()
	code = run([]string{"prototypes", "--workspace-root", workspace, "--project-root", "../escape", "--foundation-root", "foundation", "--project-id", "fixture-project", "--mode", "working-tree"}, &stdout, &stderr)
	if code != 64 || stdout.Len() != 0 || stderr.Len() == 0 {
		t.Fatalf("unsafe context code=%d stdout=%q stderr=%q", code, stdout.String(), stderr.String())
	}
	stdout.Reset()
	stderr.Reset()
	code = run([]string{"prototypes", "--workspace-root", workspace, "--project-root", "project", "-project-root=project", "--foundation-root", "foundation", "--project-id", "fixture-project", "--mode", "working-tree"}, &stdout, &stderr)
	if code != 64 || stdout.Len() != 0 {
		t.Fatalf("mixed-hyphen duplicate option code=%d stdout=%q stderr=%q", code, stdout.String(), stderr.String())
	}
}
