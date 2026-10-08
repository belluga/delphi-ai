package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"

	ks "delphi-local-api/internal/knowledge_status"
)

type fixture struct{ workspace, project, foundation string }

func newFixture(t *testing.T) fixture {
	t.Helper()
	w := t.TempDir()
	p := filepath.Join(w, "project")
	f := filepath.Join(w, "foundation")
	for _, root := range []string{p, f} {
		if err := os.MkdirAll(root, 0o755); err != nil {
			t.Fatal(err)
		}
	}
	for name, body := range map[string]string{
		"project_mandate.md": "# Mandate\n", "domain_entities.md": "# Entities\n", "project_constitution.md": "# Constitution\n", "system_roadmap.md": "# Roadmap\n", "project_landing.md": "# Landing\n", "policies/policy.md": "# Policy\n", "modules/module.md": "# Module\n", "todos/active/todo.md": "# Todo\n",
	} {
		writeFile(t, f, name, body)
	}
	git(t, f, "init", "-q")
	git(t, f, "config", "user.email", "fixture@example.invalid")
	git(t, f, "config", "user.name", "Fixture")
	git(t, f, "add", "--all")
	git(t, f, "commit", "-qm", "fixture")
	return fixture{w, p, f}
}

func writeFile(t *testing.T, root, name, body string) {
	t.Helper()
	path := filepath.Join(root, filepath.FromSlash(name))
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, []byte(body), 0o644); err != nil {
		t.Fatal(err)
	}
}
func git(t *testing.T, root string, args ...string) string {
	t.Helper()
	cmd := exec.Command("git", append([]string{"-C", root}, args...)...)
	out, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("git %v: %v: %s", args, err, out)
	}
	return strings.TrimSpace(string(out))
}
func contextArgs(f fixture) []string {
	return []string{"--workspace-root", f.workspace, "--project-root", "project", "--foundation-root", "foundation", "--project-id", "fixture-project"}
}
func invoke(t *testing.T, f fixture, action string, extra ...string) (int, string, string) {
	t.Helper()
	args := append([]string{action}, contextArgs(f)...)
	args = append(args, extra...)
	var out, errout bytes.Buffer
	code := run(args, &out, &errout)
	return code, out.String(), errout.String()
}
func packet(t *testing.T, f fixture, target string) ksPacket {
	t.Helper()
	code, out, errout := invoke(t, f, "review-packet", "--target", target)
	if code != 0 {
		t.Fatalf("packet code=%d stdout=%q stderr=%q", code, out, errout)
	}
	var p ksPacket
	if err := json.Unmarshal([]byte(out), &p); err != nil {
		t.Fatal(err)
	}
	return p
}

// Keep the packet fields used by the CLI boundary tests independent from the internal package's full schema.
type ksPacket struct {
	Target         string `json:"target"`
	SourceRevision string `json:"source_revision"`
	SourceDigest   string `json:"source_digest"`
	DocumentDigest string `json:"document_digest"`
	PacketDigest   string `json:"packet_digest"`
	Inputs         []struct {
		Path string `json:"path"`
	} `json:"inputs"`
}

func gitReplacementFixture(t *testing.T) (fixture, string, string) {
	t.Helper()
	f := newFixture(t)
	nominal := git(t, f.foundation, "rev-parse", "HEAD")
	writeFile(t, f.foundation, "project_landing.md", "# Replacement Landing\n")
	git(t, f.foundation, "add", "project_landing.md")
	git(t, f.foundation, "commit", "-qm", "replacement document")
	replacement := git(t, f.foundation, "rev-parse", "HEAD")
	git(t, f.foundation, "checkout", "--detach", nominal)
	writeFile(t, f.foundation, "project_landing.md", "# Replacement Landing\n")
	git(t, f.foundation, "replace", nominal, replacement)
	return f, nominal, replacement
}

func TestKnowledgePacketReadsNominalCommitIgnoringGitReplacementRefs(t *testing.T) {
	f, nominal, replacement := gitReplacementFixture(t)
	code, out, errout := invoke(t, f, "review-packet", "--target", "landing", "--revision", nominal)
	if code != 0 || errout != "" {
		t.Fatalf("packet code=%d stderr=%q", code, errout)
	}
	var p ksPacket
	if err := json.Unmarshal([]byte(out), &p); err != nil {
		t.Fatal(err)
	}
	want := ks.DigestBytes([]byte("# Landing\n"))
	if p.SourceRevision != nominal || p.DocumentDigest != want {
		t.Fatalf("packet used replacement content: nominal=%s replacement=%s packet_revision=%s document=%s want=%s", nominal, replacement, p.SourceRevision, p.DocumentDigest, want)
	}
}

func TestRecordReviewRejectsGitReplacementFalseExactSHA(t *testing.T) {
	f, nominal, _ := gitReplacementFixture(t)
	p := packetAtRevision(t, f, "landing", nominal)
	code, out, errout := invoke(t, f, "record-review", "--target", "landing", "--revision", nominal, "--expected-packet-digest", p.PacketDigest, "--reviewed-by", "reviewer", "--review-reference", "replacement-test")
	markerPath := filepath.Join(f.foundation, markerName)
	if _, err := os.Stat(markerPath); !os.IsNotExist(err) {
		t.Fatalf("false exact-SHA approval wrote marker: %v", err)
	}
	if code != 2 || out != "" || errout != "" {
		t.Fatalf("replacement-backed approval code=%d stdout=%q stderr=%q", code, out, errout)
	}
}

func packetAtRevision(t *testing.T, f fixture, target, revision string) ksPacket {
	t.Helper()
	code, out, errout := invoke(t, f, "review-packet", "--target", target, "--revision", revision)
	if code != 0 || errout != "" {
		t.Fatalf("packet at exact revision code=%d stderr=%q", code, errout)
	}
	var p ksPacket
	if err := json.Unmarshal([]byte(out), &p); err != nil {
		t.Fatal(err)
	}
	return p
}

func TestRecordReviewRejectsWhitespaceAndOversizedSerializedMarker(t *testing.T) {
	f := newFixture(t)
	landing := packet(t, f, "landing")
	roadmap := packet(t, f, "roadmap")
	if code, out, errout := invoke(t, f, "record-review", "--target", "landing", "--revision", landing.SourceRevision, "--expected-packet-digest", landing.PacketDigest, "--reviewed-by", "reviewer", "--review-reference", "existing"); code != 0 || out != "" || errout != "" {
		t.Fatalf("seed marker code=%d stdout=%q stderr=%q", code, out, errout)
	}
	markerPath := filepath.Join(f.foundation, markerName)
	baseline, err := os.ReadFile(markerPath)
	if err != nil {
		t.Fatal(err)
	}
	cases := map[string]struct{ reviewedBy, reference string }{
		"whitespace-reviewer":     {reviewedBy: " \t "},
		"whitespace-reference":    {reference: " \t "},
		"serialized-marker-limit": {reviewedBy: strings.Repeat("x", ks.MaxMarkerBytes)},
	}
	for name, values := range cases {
		t.Run(name, func(t *testing.T) {
			if err := os.WriteFile(markerPath, baseline, 0o600); err != nil {
				t.Fatal(err)
			}
			reviewer, reference := values.reviewedBy, values.reference
			if reviewer == "" {
				reviewer = "reviewer"
			}
			if reference == "" {
				reference = "attempt"
			}
			code, out, errout := invoke(t, f, "record-review", "--target", "roadmap", "--revision", roadmap.SourceRevision, "--expected-packet-digest", roadmap.PacketDigest, "--reviewed-by", reviewer, "--review-reference", reference)
			after, readErr := os.ReadFile(markerPath)
			if code != 2 || out != "" || errout != "" || readErr != nil || !bytes.Equal(baseline, after) {
				t.Fatalf("unsafe marker input code=%d stdout=%q stderr=%q readErr=%v markerChanged=%v", code, out, errout, readErr, !bytes.Equal(baseline, after))
			}
		})
	}
}

func TestStatusIsStdoutOnlyRepeatableAndIdentityExplicit(t *testing.T) {
	f := newFixture(t)
	before := git(t, f.foundation, "status", "--porcelain", "-z")
	code, a, errout := invoke(t, f, "status")
	if code != 0 || errout != "" {
		t.Fatalf("code=%d stderr=%q", code, errout)
	}
	code, b, errout := invoke(t, f, "status")
	if code != 0 || errout != "" || a != b {
		t.Fatalf("status was not byte-repeatable: code=%d stderr=%q", code, errout)
	}
	var response map[string]json.RawMessage
	if err := json.Unmarshal([]byte(a), &response); err != nil {
		t.Fatal(err)
	}
	if string(response["project_id"]) != `"fixture-project"` || string(response["authority_scope"]) != `"local_review_only"` {
		t.Fatalf("identity/scope: %s", a)
	}
	var landing map[string]json.RawMessage
	if err := json.Unmarshal(response["landing"], &landing); err != nil {
		t.Fatal(err)
	}
	if string(landing["reviewed_source_digest"]) != "null" || string(landing["reviewed_document_digest"]) != "null" {
		t.Fatalf("unreviewed digest fields must be explicit nulls: %s", response["landing"])
	}
	if after := git(t, f.foundation, "status", "--porcelain", "-z"); after != before {
		t.Fatalf("read-only status mutated Foundation: %q -> %q", before, after)
	}
	if _, err := os.Stat(filepath.Join(f.project, "local-api")); !os.IsNotExist(err) {
		t.Fatalf("status wrote Project output: %v", err)
	}
}

func TestReviewPacketAndRecordReviewPreserveOtherTarget(t *testing.T) {
	f := newFixture(t)
	landing := packet(t, f, "landing")
	roadmap := packet(t, f, "roadmap")
	code, out, errout := invoke(t, f, "record-review", "--target", "landing", "--revision", landing.SourceRevision, "--expected-packet-digest", landing.PacketDigest, "--reviewed-by", "reviewer", "--review-reference", "approval:landing")
	if code != 0 || out != "" || errout != "" {
		t.Fatalf("record code=%d stdout=%q stderr=%q", code, out, errout)
	}
	markerPath := filepath.Join(f.foundation, markerName)
	before, err := os.ReadFile(markerPath)
	if err != nil {
		t.Fatal(err)
	}
	staleDigest := "sha256:" + strings.Repeat("f", 64)
	if staleDigest == roadmap.PacketDigest {
		staleDigest = "sha256:" + strings.Repeat("e", 64)
	}
	code, staleOut, errout := invoke(t, f, "record-review", "--target", "roadmap", "--revision", roadmap.SourceRevision, "--expected-packet-digest", staleDigest, "--reviewed-by", "reviewer", "--review-reference", "approval:roadmap")
	if code != 2 || staleOut != "" || errout != "" {
		t.Fatalf("stale packet code=%d stdout=%q stderr=%q", code, staleOut, errout)
	}
	after, err := os.ReadFile(markerPath)
	if err != nil || !bytes.Equal(before, after) {
		t.Fatalf("stale packet mutated marker: err=%v", err)
	}
	code, out, errout = invoke(t, f, "record-review", "--target", "roadmap", "--revision", roadmap.SourceRevision, "--expected-packet-digest", roadmap.PacketDigest, "--reviewed-by", "reviewer", "--review-reference", "approval:roadmap")
	if code != 0 || out != "" || errout != "" {
		t.Fatalf("roadmap record code=%d stdout=%q stderr=%q", code, out, errout)
	}
	var fields map[string]json.RawMessage
	data, err := os.ReadFile(markerPath)
	if err != nil {
		t.Fatal(err)
	}
	if err := json.Unmarshal(data, &fields); err != nil {
		t.Fatal(err)
	}
	if string(fields["landing"]) == "null" || string(fields["roadmap"]) == "null" {
		t.Fatalf("one review overwrote the other: %s", data)
	}
}

func TestStatusAndRecordRejectInvalidOppositeTargetMarkerWithoutMutation(t *testing.T) {
	f := newFixture(t)
	landing := packet(t, f, "landing")
	roadmap := packet(t, f, "roadmap")
	cases := map[string]string{
		"case-alias":                 `{"schema_version":"1","project_id":"fixture-project","landing":null,"LANDING":null,"roadmap":null}`,
		"incomplete-opposite":        `{"schema_version":"1","project_id":"fixture-project","landing":{"reviewed_by":"reviewer"},"roadmap":null}`,
		"non-full-existing-revision": `{"schema_version":"1","project_id":"fixture-project","landing":{"reviewed_source_digest":"sha256:0000000000000000000000000000000000000000000000000000000000000000","reviewed_document_digest":"sha256:0000000000000000000000000000000000000000000000000000000000000000","reviewed_packet_digest":"sha256:0000000000000000000000000000000000000000000000000000000000000000","reviewed_revision":"r","reviewed_by":"reviewer","review_reference":"approval"},"roadmap":null}`,
		"semantic-invalid-opposite":  `{"schema_version":"1","project_id":"fixture-project","landing":{"reviewed_source_digest":"invalid","reviewed_document_digest":"sha256:0000000000000000000000000000000000000000000000000000000000000000","reviewed_packet_digest":"sha256:0000000000000000000000000000000000000000000000000000000000000000","reviewed_revision":"` + landing.SourceRevision + `","reviewed_by":"reviewer","review_reference":"approval"},"roadmap":null}`,
	}
	markerPath := filepath.Join(f.foundation, markerName)
	for name, marker := range cases {
		t.Run(name, func(t *testing.T) {
			if err := os.WriteFile(markerPath, []byte(marker), 0o600); err != nil {
				t.Fatal(err)
			}
			before, err := os.ReadFile(markerPath)
			if err != nil {
				t.Fatal(err)
			}
			code, statusOut, statusErr := invoke(t, f, "status")
			if code != 0 || statusErr != "" || statusOut == "" {
				t.Fatalf("status code=%d stdout=%q stderr=%q", code, statusOut, statusErr)
			}
			var status ks.Response
			if err := json.Unmarshal([]byte(statusOut), &status); err != nil {
				t.Fatal(err)
			}
			if status.Landing.ReasonCode != "invalid_marker" || status.Roadmap.ReasonCode != "invalid_marker" {
				t.Fatalf("status did not fail closed for %s marker: landing=%+v roadmap=%+v", name, status.Landing, status.Roadmap)
			}
			code, out, errout := invoke(t, f, "record-review", "--target", "roadmap", "--revision", roadmap.SourceRevision, "--expected-packet-digest", roadmap.PacketDigest, "--reviewed-by", "reviewer", "--review-reference", "approval:roadmap")
			after, readErr := os.ReadFile(markerPath)
			if readErr != nil || code != 2 || out != "" || errout != "" || !bytes.Equal(before, after) {
				t.Fatalf("record code=%d stdout=%q stderr=%q readErr=%v markerChanged=%v", code, out, errout, readErr, !bytes.Equal(before, after))
			}
		})
	}
}

func TestOperationMatrixAndFoundationAncestryGuard(t *testing.T) {
	f := newFixture(t)
	var out, errout bytes.Buffer
	code := run([]string{"status", "--workspace-root", f.workspace, "--project-root", "../escape", "--foundation-root", "foundation", "--project-id", "fixture-project"}, &out, &errout)
	if code != 64 || out.Len() != 0 || errout.Len() == 0 {
		t.Fatalf("unsafe lexical context code=%d stdout=%q stderr=%q", code, out.String(), errout.String())
	}
	out.Reset()
	errout.Reset()
	code = run([]string{"status", "--workspace-root", f.workspace, "--project-root", "project", "--foundation-root", "missing", "--project-id", "fixture-project"}, &out, &errout)
	if code != 2 || out.Len() != 0 || errout.Len() != 0 {
		t.Fatalf("missing source code=%d stdout=%q stderr=%q", code, out.String(), errout.String())
	}
	out.Reset()
	errout.Reset()
	code = run([]string{"unknown"}, &out, &errout)
	if code != 64 || out.Len() != 0 {
		t.Fatalf("unknown operation code=%d stdout=%q", code, out.String())
	}
	out.Reset()
	errout.Reset()
	code = run([]string{"status", "--workspace-root", f.workspace, "--project-root", "project", "-project-root", "project", "--foundation-root", "foundation", "--project-id", "fixture-project"}, &out, &errout)
	if code != 64 || out.Len() != 0 {
		t.Fatalf("mixed-hyphen duplicate option code=%d stdout=%q stderr=%q", code, out.String(), errout.String())
	}
	args := []string{"status", "--workspace-root", f.workspace, "--project-root", ".", "--foundation-root", "foundation", "--project-id", "fixture-project"}
	out.Reset()
	errout.Reset()
	code = run(args, &out, &errout)
	if code != 0 {
		t.Fatalf("status with Foundation child of Project should remain valid: code=%d stderr=%q", code, errout.String())
	}
	args = []string{"record-review", "--workspace-root", f.workspace, "--project-root", "foundation", "--foundation-root", "foundation", "--project-id", "fixture-project", "--target", "landing", "--revision", git(t, f.foundation, "rev-parse", "HEAD"), "--expected-packet-digest", "invalid", "--reviewed-by", "x", "--review-reference", "x"}
	out.Reset()
	errout.Reset()
	code = run(args, &out, &errout)
	if code != 2 || out.Len() != 0 || errout.Len() != 0 {
		t.Fatalf("Foundation ancestor of Project write was not safely rejected: code=%d stdout=%q stderr=%q", code, out.String(), errout.String())
	}
}

func TestConcurrentMarkerUpdatesRetainBothTargets(t *testing.T) {
	f := newFixture(t)
	packets := map[string]ksPacket{"landing": packet(t, f, "landing"), "roadmap": packet(t, f, "roadmap")}
	start := make(chan struct{})
	var wg sync.WaitGroup
	codes := make(chan int, 2)
	errs := make(chan string, 2)
	for _, target := range []string{"landing", "roadmap"} {
		p := packets[target]
		wg.Add(1)
		go func(target string, p ksPacket) {
			defer wg.Done()
			<-start
			code, _, errout := invoke(t, f, "record-review", "--target", target, "--revision", p.SourceRevision, "--expected-packet-digest", p.PacketDigest, "--reviewed-by", "parallel", "--review-reference", "parallel:"+target)
			codes <- code
			errs <- errout
		}(target, p)
	}
	close(start)
	wg.Wait()
	close(codes)
	close(errs)
	for code := range codes {
		if code != 0 {
			t.Fatalf("concurrent record exit=%d", code)
		}
	}
	for errout := range errs {
		if errout != "" {
			t.Fatalf("concurrent record stderr=%q", errout)
		}
	}
	data, err := os.ReadFile(filepath.Join(f.foundation, markerName))
	if err != nil {
		t.Fatal(err)
	}
	var marker map[string]json.RawMessage
	if err := json.Unmarshal(data, &marker); err != nil {
		t.Fatal(err)
	}
	if string(marker["landing"]) == "null" || string(marker["roadmap"]) == "null" {
		t.Fatalf("concurrent update lost a target: %s", data)
	}
}

func TestMarkerAtomicReplacementAndFailurePreservation(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, markerName)
	if err := os.WriteFile(path, []byte("old-complete"), 0o600); err != nil {
		t.Fatal(err)
	}
	if err := atomicWriteUsing(path, []byte("new-complete"), 0o600, func(_, _ string) error { return errors.New("injected rename failure") }); err == nil {
		t.Fatal("injected rename failure succeeded")
	}
	data, err := os.ReadFile(path)
	if err != nil || string(data) != "old-complete" {
		t.Fatalf("failed replacement changed old bytes: %q %v", data, err)
	}
	entries, err := os.ReadDir(dir)
	if err != nil {
		t.Fatal(err)
	}
	if len(entries) != 1 || entries[0].Name() != markerName {
		t.Fatalf("failed write leaked temp file: %#v", entries)
	}
	const writers = 10
	const batches = 3
	for batch := 0; batch < batches; batch++ {
		var wg sync.WaitGroup
		start := make(chan struct{})
		for i := 0; i < writers; i++ {
			wg.Add(1)
			go func(i int) {
				defer wg.Done()
				<-start
				payload := []byte(strings.Repeat(string(rune('a'+i)), 4096))
				if err := atomicWrite(path, payload, 0o600); err != nil {
					t.Errorf("atomic marker write: %v", err)
				}
			}(i)
		}
		close(start)
		wg.Wait()
		data, err = os.ReadFile(path)
		if err != nil || len(data) != 4096 {
			t.Fatalf("batch %d observed incomplete marker bytes len=%d err=%v", batch, len(data), err)
		}
		for _, b := range data[1:] {
			if b != data[0] {
				t.Fatalf("batch %d observed torn marker", batch)
			}
		}
	}
	allowed := map[byte]bool{}
	for i := 0; i < 5; i++ {
		allowed[byte('k'+i)] = true
	}
	if err := atomicWrite(path, bytes.Repeat([]byte{'k'}, 4096), 0o600); err != nil {
		t.Fatal(err)
	}
	var readers sync.WaitGroup
	stop := make(chan struct{})
	readerErrors := make(chan error, 1)
	for i := 0; i < 3; i++ {
		readers.Add(1)
		go func() {
			defer readers.Done()
			for {
				select {
				case <-stop:
					return
				default:
				}
				current, readErr := os.ReadFile(path)
				if readErr != nil {
					select {
					case readerErrors <- readErr:
					default:
					}
					return
				}
				if len(current) != 4096 || !allowed[current[0]] {
					select {
					case readerErrors <- errors.New("reader observed partial marker payload"):
					default:
					}
					return
				}
				for _, value := range current[1:] {
					if value != current[0] {
						select {
						case readerErrors <- errors.New("reader observed mixed marker payload"):
						default:
						}
						return
					}
				}
			}
		}()
	}
	for i := 0; i < 30; i++ {
		value := byte('k' + i%5)
		if err := atomicWrite(path, bytes.Repeat([]byte{value}, 4096), 0o600); err != nil {
			t.Fatal(err)
		}
	}
	close(stop)
	readers.Wait()
	close(readerErrors)
	for readErr := range readerErrors {
		t.Fatal(readErr)
	}
}

func TestRoadmapHashTracksPathsNotBodiesAndPacketSelectsMarkdownVariants(t *testing.T) {
	f := newFixture(t)
	code, out, errout := invoke(t, f, "status")
	if code != 0 || errout != "" {
		t.Fatalf("status code=%d stderr=%q", code, errout)
	}
	var baseline ks.Response
	if err := json.Unmarshal([]byte(out), &baseline); err != nil {
		t.Fatal(err)
	}
	writeFile(t, f.foundation, "todos/active/todo.md", "# Body-only edit\n")
	code, out, errout = invoke(t, f, "status")
	if code != 0 || errout != "" {
		t.Fatalf("status after body edit code=%d stderr=%q", code, errout)
	}
	var bodyEdit ks.Response
	if err := json.Unmarshal([]byte(out), &bodyEdit); err != nil {
		t.Fatal(err)
	}
	if baseline.Roadmap.ObservedSourceDigest == nil || bodyEdit.Roadmap.ObservedSourceDigest == nil || *baseline.Roadmap.ObservedSourceDigest != *bodyEdit.Roadmap.ObservedSourceDigest {
		t.Fatal("Roadmap body-only edit changed path inventory digest")
	}
	writeFile(t, f.foundation, "todos/.hidden/UPPER.MARKDOWN", "# hidden\n")
	writeFile(t, f.foundation, "todos/active/extra.markdown", "# extension\n")
	git(t, f.foundation, "add", "--all")
	git(t, f.foundation, "commit", "-qm", "selectors")
	p := packet(t, f, "roadmap")
	seen := map[string]bool{}
	for _, input := range p.Inputs {
		seen[input.Path] = true
	}
	for _, want := range []string{"todos/.hidden/UPPER.MARKDOWN", "todos/active/extra.markdown"} {
		if !seen[want] {
			t.Fatalf("roadmap packet omitted %q: %#v", want, p.Inputs)
		}
	}
	if !fullRevision(p.SourceRevision) {
		t.Fatalf("packet did not resolve a full SHA: %q", p.SourceRevision)
	}
}

func TestKnowledgeRealGitRoadmapTransitionsAndLandingSelectors(t *testing.T) {
	f := newFixture(t)
	statusDigest := func() (*ks.Response, int, string) {
		t.Helper()
		code, out, errout := invoke(t, f, "status")
		if code != 0 || errout != "" {
			t.Fatalf("status code=%d stderr=%q", code, errout)
		}
		var response ks.Response
		if err := json.Unmarshal([]byte(out), &response); err != nil {
			t.Fatal(err)
		}
		return &response, code, out
	}
	base, _, _ := statusDigest()
	baseRoadmap := base.Roadmap.ObservedSourceDigest
	writeFile(t, f.foundation, "todos/active/transition.md", "# transition\n")
	git(t, f.foundation, "add", "--all")
	git(t, f.foundation, "commit", "-qm", "create roadmap input")
	created, _, _ := statusDigest()
	if created.Roadmap.ObservedSourceDigest == nil || baseRoadmap == nil || *created.Roadmap.ObservedSourceDigest == *baseRoadmap {
		t.Fatal("real-Git TODO create did not change Roadmap inventory")
	}
	if err := os.MkdirAll(filepath.Join(f.foundation, "todos/done"), 0o755); err != nil {
		t.Fatal(err)
	}
	git(t, f.foundation, "mv", "todos/active/transition.md", "todos/done/transition.MARKDOWN")
	git(t, f.foundation, "commit", "-qm", "rename roadmap input")
	renamed, _, _ := statusDigest()
	if renamed.Roadmap.ObservedSourceDigest == nil || *renamed.Roadmap.ObservedSourceDigest == *created.Roadmap.ObservedSourceDigest {
		t.Fatal("real-Git TODO rename did not change Roadmap inventory")
	}
	git(t, f.foundation, "rm", "todos/done/transition.MARKDOWN")
	git(t, f.foundation, "commit", "-qm", "delete roadmap input")
	deleted, _, _ := statusDigest()
	if deleted.Roadmap.ObservedSourceDigest == nil || *deleted.Roadmap.ObservedSourceDigest == *renamed.Roadmap.ObservedSourceDigest {
		t.Fatal("real-Git TODO delete did not change Roadmap inventory")
	}
	writeFile(t, f.foundation, "policies/.hidden/UPPER.MARKDOWN", "# hidden Landing source\n")
	git(t, f.foundation, "add", "--all")
	git(t, f.foundation, "commit", "-qm", "add hidden Landing source")
	p := packet(t, f, "landing")
	found := false
	for _, input := range p.Inputs {
		if input.Path == "policies/.hidden/UPPER.MARKDOWN" {
			found = true
		}
	}
	if !found {
		t.Fatalf("Landing packet omitted hidden uppercase Markdown: %#v", p.Inputs)
	}
	working, _, _ := statusDigest()
	if working.Landing.ObservedSourceDigest == nil || *working.Landing.ObservedSourceDigest != p.SourceDigest {
		t.Fatal("working Landing selector disagrees with committed packet inventory")
	}
	roadmapPacket := packet(t, f, "roadmap")
	for _, reviewed := range []struct {
		target string
		packet ksPacket
	}{{"landing", p}, {"roadmap", roadmapPacket}} {
		code, out, errout := invoke(t, f, "record-review", "--target", reviewed.target, "--revision", reviewed.packet.SourceRevision, "--expected-packet-digest", reviewed.packet.PacketDigest, "--reviewed-by", "fixture", "--review-reference", "before-removal:"+reviewed.target)
		if code != 0 || out != "" || errout != "" {
			t.Fatalf("record %s code=%d stdout=%q stderr=%q", reviewed.target, code, out, errout)
		}
	}
	git(t, f.foundation, "rm", "policies/policy.md")
	git(t, f.foundation, "commit", "-qm", "remove Landing source")
	code, out, errout := invoke(t, f, "status")
	if code != 0 || errout != "" {
		t.Fatalf("status after Landing source removal code=%d stderr=%q", code, errout)
	}
	var afterRemoval ks.Response
	if err := json.Unmarshal([]byte(out), &afterRemoval); err != nil {
		t.Fatal(err)
	}
	if afterRemoval.Landing.Status != "review_required" || afterRemoval.Landing.ReasonCode != "source_changed" || afterRemoval.Roadmap.Status != "current" || afterRemoval.Roadmap.ReasonCode != "match" {
		t.Fatalf("Landing removal did not isolate target review: landing=%+v roadmap=%+v", afterRemoval.Landing, afterRemoval.Roadmap)
	}
}

func TestMarkerLockWaitsForCurrentWriter(t *testing.T) {
	path := filepath.Join(t.TempDir(), markerName+".lock")
	if err := os.WriteFile(path, []byte("held"), 0o600); err != nil {
		t.Fatal(err)
	}
	waits := 0
	lock, err := acquireMarkerLockWithWait(path, func(_ time.Duration) {
		waits++
		if waits == 2 {
			if err := os.Remove(path); err != nil {
				t.Fatal(err)
			}
		}
	})
	if err != nil || waits != 2 {
		t.Fatalf("lock wait result: lock=%v waits=%d err=%v", lock, waits, err)
	}
	lock.Close()
}

func TestFoundationMustBeExactGitRootForEveryKnowledgeOperation(t *testing.T) {
	f := newFixture(t)
	nested := filepath.Join(f.foundation, "nested")
	if err := os.Mkdir(nested, 0o755); err != nil {
		t.Fatal(err)
	}
	for _, op := range []string{"status", "review-packet", "record-review"} {
		args := []string{op, "--workspace-root", f.workspace, "--project-root", "project", "--foundation-root", "foundation/nested", "--project-id", "fixture-project"}
		if op != "status" {
			args = append(args, "--target", "roadmap")
		}
		var out, errout bytes.Buffer
		code := run(args, &out, &errout)
		if code != 2 || out.Len() != 0 || errout.Len() != 0 {
			t.Fatalf("%s accepted nested Git path: code=%d stdout=%q stderr=%q", op, code, out.String(), errout.String())
		}
	}
}

func TestReviewPacketRejectsCommittedSymlinkInputAndRecordPreservesWrongMarker(t *testing.T) {
	f := newFixture(t)
	if err := os.Symlink("todo.md", filepath.Join(f.foundation, "todos/active/link.markdown")); err != nil {
		t.Fatal(err)
	}
	git(t, f.foundation, "add", "--all")
	git(t, f.foundation, "commit", "-qm", "symlink input")
	var out, errout bytes.Buffer
	code := run(append([]string{"review-packet"}, append(contextArgs(f), "--target", "roadmap")...), &out, &errout)
	if code != 2 || out.Len() != 0 || errout.Len() != 0 {
		t.Fatalf("committed symlink accepted: code=%d stdout=%q stderr=%q", code, out.String(), errout.String())
	}
	wrong := []byte(`{"schema_version":"1","project_id":"other-project","landing":null,"roadmap":null}`)
	marker := filepath.Join(f.foundation, markerName)
	if err := os.WriteFile(marker, wrong, 0o600); err != nil {
		t.Fatal(err)
	}
	p := packet(t, f, "landing")
	args := append([]string{"record-review"}, contextArgs(f)...)
	args = append(args, "--target", "landing", "--revision", p.SourceRevision, "--expected-packet-digest", p.PacketDigest, "--reviewed-by", "reviewer", "--review-reference", "approval")
	out.Reset()
	errout.Reset()
	code = run(args, &out, &errout)
	after, err := os.ReadFile(marker)
	if err != nil {
		t.Fatal(err)
	}
	if code != 2 || out.Len() != 0 || errout.Len() != 0 || !bytes.Equal(after, wrong) {
		t.Fatalf("wrong marker mutation: code=%d stdout=%q stderr=%q bytes=%q", code, out.String(), errout.String(), after)
	}
}
