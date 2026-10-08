package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"delphi-local-api/internal/builder_project"
)

func TestRequiredDesignSystemStatusFilesAreCheckedOnlyByTargetedStatus(t *testing.T) {
	if got := missingRequiredDesignSystemFile([]string{"design/system/design-system.json", "design/system/guide.md"}); got != "design/system/examples.html" {
		t.Fatalf("missing path = %q", got)
	}
	if got := missingRequiredDesignSystemFile([]string{"design/system/design-system.json", "design/system/guide.md", "design/system/examples.html"}); got != "" {
		t.Fatalf("complete inventory reported missing %q", got)
	}
}

func TestCanonicalSourceBindingsAreOptionalOnlyWhenAbsent(t *testing.T) {
	workspace := t.TempDir()
	binding := builder_project.Binding{WorkspaceRoot: workspace, ProjectRoot: ".", FoundationRoot: "foundation"}
	if err := attachCanonicalSourceBindings(&binding, workspace, "project-a", "company-a", ""); err != nil || binding.SourceBindingsPath != "" {
		t.Fatalf("absent optional bindings: binding=%+v err=%v", binding, err)
	}
	path := filepath.Join(workspace, "local-api", "source-bindings.json")
	if err := os.MkdirAll(filepath.Dir(path), 0o700); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, []byte("not-json"), 0o600); err != nil {
		t.Fatal(err)
	}
	if err := attachCanonicalSourceBindings(&binding, workspace, "project-a", "company-a", ""); err == nil || binding.SourceBindingsPath != "" {
		t.Fatalf("invalid configured bindings silently fell back: binding=%+v err=%v", binding, err)
	}
}

func TestCLIRegistrationFailureRetryAndStatusAfterSourceChange(t *testing.T) {
	workspace := t.TempDir()
	project := filepath.Join(workspace, "project")
	foundation := filepath.Join(workspace, "foundation")
	state := t.TempDir()
	if err := os.Chmod(state, 0o700); err != nil {
		t.Fatal(err)
	}
	for _, path := range []string{project, foundation} {
		if err := os.MkdirAll(path, 0o700); err != nil {
			t.Fatal(err)
		}
	}
	if out, err := exec.Command("git", "init", "--quiet", foundation).CombinedOutput(); err != nil {
		t.Fatalf("git init: %v %s", err, out)
	}
	bindings := filepath.Join(workspace, "bindings.json")
	if err := os.WriteFile(bindings, []byte("{}"), 0o600); err != nil {
		t.Fatal(err)
	}
	bin := t.TempDir()
	writeEvaluator(t, bin, "knowledge-status", "#!/bin/sh\n[ -z \"$TEST_REGISTRY_BLOCKER\" ] || mkdir -p \"$TEST_REGISTRY_BLOCKER\"\nif [ -n \"$TEST_KNOWLEDGE_STATUS\" ]; then printf '%s\\n' \"$TEST_KNOWLEDGE_STATUS\"; else printf '%s\\n' '{\"schema_version\":\"1\",\"landing\":{\"status\":\"unverifiable\",\"reason_code\":\"review_missing\"},\"roadmap\":{\"status\":\"unverifiable\",\"reason_code\":\"review_missing\"}}'; fi\n")
	writeEvaluator(t, bin, "artifact-status", "#!/bin/sh\nif [ \"$1\" = design-system ] && [ -n \"$TEST_BINDING_FILE\" ]; then printf '%s' '{\"changed\":true}' > \"$TEST_BINDING_FILE\"; fi\nexit 2\n")
	t.Setenv("DELPHI_LOCAL_API_BIN_DIR", bin)
	common := []string{"--state-root", state, "--workspace-root", workspace, "--project-root", "project", "--foundation-root", "foundation", "--project-id", "project-a"}
	register := func(extra ...string) (int, string, string) {
		out, stderr := &strings.Builder{}, &strings.Builder{}
		args := append(append([]string{}, common...), "--project-name", "Project A", "--company-id", "company-a", "--company-name", "Company A", "--source-bindings", "bindings.json", "--default-owner-id", "owner-a")
		code := run(append([]string{"register"}, append(args, extra...)...), out, stderr)
		return code, out.String(), stderr.String()
	}
	// A snapshot-directory failure is reported as not_ready; removing the obstruction and retrying succeeds.
	if err := os.WriteFile(filepath.Join(state, "snapshots"), []byte("block"), 0o600); err != nil {
		t.Fatal(err)
	}
	code, output, _ := register()
	var failed response
	if code != 2 || json.Unmarshal([]byte(output), &failed) != nil || failed.ConsumerReadiness != "not_ready" || failed.SnapshotFingerprint != "" {
		t.Fatalf("snapshot write failure: code=%d output=%s", code, output)
	}
	if err := os.Remove(filepath.Join(state, "snapshots")); err != nil {
		t.Fatal(err)
	}
	if code, output, stderr := register(); code != 0 {
		t.Fatalf("snapshot retry code=%d json=%s stderr=%s", code, output, stderr)
	}

	// A registry pointer write failure leaves no false-ready record; cleanup permits a real retry.
	if err := os.Remove(filepath.Join(state, "registry.json")); err != nil {
		t.Fatal(err)
	}
	blocker := filepath.Join(state, "registry.json")
	t.Setenv("TEST_REGISTRY_BLOCKER", blocker)
	code, output, stderr := register()
	if code != 2 || output != "" || !strings.Contains(stderr, "safe write failed") {
		t.Fatalf("registry write failure: code=%d json=%s stderr=%s", code, output, stderr)
	}
	if err := os.Setenv("TEST_REGISTRY_BLOCKER", ""); err != nil {
		t.Fatal(err)
	}
	if err := os.RemoveAll(blocker); err != nil {
		t.Fatal(err)
	}
	if code, output, stderr = register(); code != 0 {
		t.Fatalf("registry retry code=%d json=%s stderr=%s", code, output, stderr)
	}
	var priorReady response
	if json.Unmarshal([]byte(output), &priorReady) != nil || priorReady.SnapshotFingerprint == "" {
		t.Fatalf("retry omitted ready snapshot: %s", output)
	}
	// Fresh source observations remain distinct from the saved registration snapshot.
	t.Setenv("TEST_KNOWLEDGE_STATUS", `{"schema_version":"1","landing":{"status":"current","reason_code":"review_matches"},"roadmap":{"status":"review_required","reason_code":"source_changed"}}`)
	statusOut, statusErr := &strings.Builder{}, &strings.Builder{}
	code = run(append([]string{"status"}, common...), statusOut, statusErr)
	var refreshed response
	if code != 0 || json.Unmarshal([]byte(statusOut.String()), &refreshed) != nil || refreshed.CurrentObservations["knowledge_status"] == nil || refreshed.SnapshotObservations["knowledge_status"] == nil {
		t.Fatalf("successful registered status omitted current/saved observations: code=%d json=%s stderr=%s", code, statusOut.String(), statusErr.String())
	}
	var freshKnowledge, savedKnowledge struct {
		Landing struct {
			Status string `json:"status"`
		} `json:"landing"`
	}
	if json.Unmarshal(refreshed.CurrentObservations["knowledge_status"], &freshKnowledge) != nil || json.Unmarshal(refreshed.SnapshotObservations["knowledge_status"], &savedKnowledge) != nil || freshKnowledge.Landing.Status != "current" || savedKnowledge.Landing.Status != "unverifiable" {
		t.Fatalf("fresh/saved Knowledge observations conflated: current=%s saved=%s", refreshed.CurrentObservations["knowledge_status"], refreshed.SnapshotObservations["knowledge_status"])
	}
	if err := os.Setenv("TEST_KNOWLEDGE_STATUS", ""); err != nil {
		t.Fatal(err)
	}
	// Mutating the exact source map during evaluator execution cannot publish a ready snapshot.
	if err := os.Setenv("TEST_BINDING_FILE", bindings); err != nil {
		t.Fatal(err)
	}
	code, output, _ = register()
	var changedDuringPrepare response
	if code != 2 || json.Unmarshal([]byte(output), &changedDuringPrepare) != nil || changedDuringPrepare.ConsumerReadiness != "not_ready" || changedDuringPrepare.SnapshotFingerprint != priorReady.SnapshotFingerprint {
		t.Fatalf("source map changed during prepare was published: code=%d json=%s", code, output)
	}
	if err := os.Setenv("TEST_BINDING_FILE", ""); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(bindings, []byte("{}"), 0o600); err != nil {
		t.Fatal(err)
	}
	declineArgs := []string{"decline", "--state-root", state, "--workspace-root", workspace, "--project-root", "project", "--foundation-root", "foundation", "--project-id", "project-b"}
	if code := run(declineArgs, &strings.Builder{}, &strings.Builder{}); code != 0 {
		t.Fatalf("explicit decline failed with %d", code)
	}
	declinedArgs := []string{"status", "--state-root", state, "--workspace-root", workspace, "--project-root", "project", "--foundation-root", "foundation", "--project-id", "project-b"}
	declinedOut := &strings.Builder{}
	if code := run(declinedArgs, declinedOut, &strings.Builder{}); code != 0 || !strings.Contains(declinedOut.String(), `"registration_state": "declined"`) {
		t.Fatalf("declined status code=%d json=%s", code, declinedOut.String())
	}
	missingState := filepath.Join(t.TempDir(), "not-created")
	missingOut, missingErr := &strings.Builder{}, &strings.Builder{}
	if code := run([]string{"list", "--state-root", missingState}, missingOut, missingErr); code != 2 || missingOut.Len() != 0 {
		t.Fatalf("unavailable state result code=%d out=%s err=%s", code, missingOut.String(), missingErr.String())
	}
	if _, err := os.Lstat(missingState); !os.IsNotExist(err) {
		t.Fatalf("unavailable state was created: %v", err)
	}

	// A moved source returns complete sanitized status JSON and preserves last verified snapshot identity.
	if err := os.Rename(foundation, filepath.Join(workspace, "moved-foundation")); err != nil {
		t.Fatal(err)
	}
	statusArgs := append([]string{"status"}, common...)
	statusOut, statusErr = &strings.Builder{}, &strings.Builder{}
	code = run(statusArgs, statusOut, statusErr)
	var moved response
	if code != 2 || json.Unmarshal([]byte(statusOut.String()), &moved) != nil || moved.SnapshotFingerprint == "" || moved.SnapshotObservedAt == "" || moved.SnapshotObservations == nil || moved.CurrentObservations != nil || moved.Diagnostic == "" || strings.Contains(statusOut.String(), workspace) {
		t.Fatalf("moved-source status: code=%d json=%s stderr=%s", code, statusOut.String(), statusErr.String())
	}
}

func TestCLIStatusWithChangedSourceBindingsKeepsVerifiedSnapshotDiagnostic(t *testing.T) {
	workspace := t.TempDir()
	project := filepath.Join(workspace, "project")
	foundation := filepath.Join(workspace, "foundation")
	state := t.TempDir()
	if err := os.Chmod(state, 0o700); err != nil {
		t.Fatal(err)
	}
	for _, path := range []string{project, foundation} {
		if err := os.MkdirAll(path, 0o700); err != nil {
			t.Fatal(err)
		}
	}
	if out, err := exec.Command("git", "init", "--quiet", foundation).CombinedOutput(); err != nil {
		t.Fatalf("git init: %v %s", err, out)
	}
	bindings := filepath.Join(workspace, "bindings.json")
	if err := os.WriteFile(bindings, []byte("{}"), 0o600); err != nil {
		t.Fatal(err)
	}
	bin := t.TempDir()
	writeEvaluator(t, bin, "knowledge-status", "#!/bin/sh\nprintf '%s\\n' '{\"schema_version\":\"1\",\"landing\":{},\"roadmap\":{}}'\n")
	writeEvaluator(t, bin, "artifact-status", "#!/bin/sh\nexit 2\n")
	t.Setenv("DELPHI_LOCAL_API_BIN_DIR", bin)
	base := []string{"--state-root", state, "--workspace-root", workspace, "--project-root", "project", "--foundation-root", "foundation", "--project-id", "project-a"}
	reg := append([]string{"register"}, append(append([]string{}, base...), "--project-name", "Project A", "--company-id", "company-a", "--company-name", "Company A", "--source-bindings", "bindings.json", "--default-owner-id", "owner-a")...)
	out, stderr := &strings.Builder{}, &strings.Builder{}
	if code := run(reg, out, stderr); code != 0 {
		t.Fatalf("register: code=%d json=%s stderr=%s", code, out.String(), stderr.String())
	}
	if err := os.WriteFile(bindings, []byte("{\"changed\":true}"), 0o600); err != nil {
		t.Fatal(err)
	}
	out, stderr = &strings.Builder{}, &strings.Builder{}
	code := run(append([]string{"status"}, base...), out, stderr)
	var status response
	if code != 2 || json.Unmarshal([]byte(out.String()), &status) != nil || status.SnapshotFingerprint == "" || status.Diagnostic == "" || strings.Contains(out.String(), workspace) {
		t.Fatalf("changed-map status: code=%d json=%s stderr=%s", code, out.String(), stderr.String())
	}
}

func writeEvaluator(t *testing.T, dir, name, body string) {
	t.Helper()
	path := filepath.Join(dir, name)
	if err := os.WriteFile(path, []byte(body), 0o700); err != nil {
		t.Fatal(fmt.Errorf("write evaluator: %w", err))
	}
}
