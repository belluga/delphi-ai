package builder_project

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	ac "delphi-local-api/internal/artifact_catalog"
	"delphi-local-api/internal/source"
)

func TestPrepareAdmitsStandardProjectDesignSystemWithoutBindingsFile(t *testing.T) {
	workspace := t.TempDir()
	foundation := filepath.Join(workspace, "foundation")
	if err := os.MkdirAll(filepath.Join(foundation, "design/system"), 0o755); err != nil {
		t.Fatal(err)
	}
	if out, err := exec.Command("git", "init", "--quiet", foundation).CombinedOutput(); err != nil {
		t.Fatalf("git init: %v %s", err, out)
	}
	definition := ac.DesignSystemDefinition{SchemaVersion: "1", ID: "standard-system", Name: "Standard System", Owner: ac.DesignSystemOwner{Level: "project", ID: "project-a"},
		Tokens:     []ac.DesignToken{{ID: "ink", Type: "color", Value: json.RawMessage(`"#111111"`)}},
		Components: []ac.DesignComponent{{ID: "button", Name: "Button", Documentation: "guide.md", TokenIDs: []string{"ink"}, States: []string{}, Variants: []ac.DesignVariant{}, Examples: []string{"examples.html"}}},
		Assets:     []string{}, ContrastPairs: []ac.ContrastPair{}}
	definitionBytes, _ := json.Marshal(definition)
	writeFixture(t, foundation, "design/system/design-system.json", definitionBytes)
	writeFixture(t, foundation, "design/system/guide.md", []byte("## Overview\nPurpose.\n## Foundations\nTokens.\n## Components\nButtons.\n"))
	writeFixture(t, foundation, "design/system/examples.html", []byte("<main>standard system</main>"))
	selected, err := source.NewWorkingTree(foundation)
	if err != nil {
		t.Fatal(err)
	}
	standard := ac.StandardProjectBindings("project-a", "company-a", "foundation")
	status, _ := json.Marshal(ac.EvaluateDesignSystem(selected, "project-a", "company-a", "", "project", *standard.Sources.Project))
	// The stub returns the same accepted evaluator response while asserting that no bindings path was passed.
	responsePath := filepath.Join(t.TempDir(), "design-system.json")
	if err := os.WriteFile(responsePath, status, 0o600); err != nil {
		t.Fatal(err)
	}
	bin := t.TempDir()
	writeExecutable(t, bin, "knowledge-status", "#!/bin/sh\nprintf '%s\\n' '{\"schema_version\":\"1\",\"project_id\":\"project-a\",\"authority_scope\":\"local_review_only\",\"landing\":{},\"roadmap\":{}}'\n")
	writeExecutable(t, bin, "artifact-status", "#!/bin/sh\n[ \"$1\" = design-system ] || exit 2\nfor arg do [ \"$arg\" != --source-bindings ] || exit 64; done\ncat \"$TEST_STANDARD_DS_RESPONSE\"\n")
	t.Setenv("DELPHI_LOCAL_API_BIN_DIR", bin)
	t.Setenv("TEST_STANDARD_DS_RESPONSE", responsePath)
	snapshot, err := Prepare(Registration{ProjectID: "project-a", CompanyID: "company-a", Binding: Binding{WorkspaceRoot: workspace, ProjectRoot: ".", FoundationRoot: "foundation"}}, "", "")
	if err != nil {
		t.Fatal(err)
	}
	for _, artifact := range snapshot.Artifacts {
		if artifact.ID == "design-system" {
			if artifact.State != "available" || artifact.Entry != "design/system/examples.html" || string(snapshot.Files["design/system/guide.md"]) != "## Overview\nPurpose.\n## Foundations\nTokens.\n## Components\nButtons.\n" {
				t.Fatalf("standard Project Design System not admitted: %+v files=%v", artifact, snapshot.Files)
			}
			return
		}
	}
	t.Fatal("Design System status missing from prepared snapshot")
}

func TestPreparePreservesPrototypeMigrationTeachWhilePreparingOtherArtifacts(t *testing.T) {
	workspace := t.TempDir()
	foundation := filepath.Join(workspace, "foundation")
	if err := os.MkdirAll(foundation, 0o755); err != nil {
		t.Fatal(err)
	}
	if out, err := exec.Command("git", "init", "--quiet", foundation).CombinedOutput(); err != nil {
		t.Fatalf("git init: %v %s", err, out)
	}
	writeFixture(t, foundation, "prototypes/catalog.json", []byte(`{"schema_version":"2","project_id":"project-a","prototypes":[]}`))
	bin := t.TempDir()
	writeExecutable(t, bin, "knowledge-status", "#!/bin/sh\nprintf '%s\\n' '{\"schema_version\":\"1\",\"project_id\":\"project-a\",\"authority_scope\":\"local_review_only\",\"landing\":{},\"roadmap\":{}}'\n")
	writeExecutable(t, bin, "artifact-status", "#!/bin/sh\nif [ \"$1\" = prototypes ]; then\n  printf '%s\\n' '{\"schema_version\":\"3\",\"project_id\":\"project-a\",\"target\":\"prototypes\",\"authority_scope\":\"local_structure_only\",\"mode\":\"working-tree\",\"revision\":null,\"outcome\":\"no_go\",\"inventory_digest\":null,\"items\":[],\"diagnostics\":[{\"code\":\"invalid_schema\",\"source_id\":null,\"artifact_id\":\"bad-prototype\",\"path\":\"prototypes/bad/prototype.json\",\"message\":\"Another manifest field is invalid\",\"resolution\":\"Correct the invalid field.\"},{\"code\":\"unsupported_schema\",\"source_id\":null,\"artifact_id\":null,\"path\":\"prototypes/catalog.json\",\"message\":\"Prototype schema v2 is not accepted\",\"resolution\":\"TEACH: run fresh Prototype status, adapt every offending catalog and manifest including archived candidates to schema_version 3, confirm the complete collection go, then explicitly refresh registration.\"}],\"design_system_validation\":\"not_evaluated\"}'\n  exit 2\nfi\nprintf '%s\\n' '{}'\n")
	t.Setenv("DELPHI_LOCAL_API_BIN_DIR", bin)
	snapshot, err := Prepare(Registration{ProjectID: "project-a", CompanyID: "company-a", Binding: Binding{WorkspaceRoot: workspace, ProjectRoot: ".", FoundationRoot: "foundation"}}, "", "")
	if err != nil {
		t.Fatalf("unrelated artifact preparation should continue: %v", err)
	}
	var prototypeArtifact *Artifact
	for i := range snapshot.Artifacts {
		if snapshot.Artifacts[i].Kind == "prototype_collection" {
			prototypeArtifact = &snapshot.Artifacts[i]
			break
		}
	}
	if prototypeArtifact == nil || prototypeArtifact.State != "invalid" || !strings.Contains(prototypeArtifact.Diagnostic, "fresh Prototype status") || !strings.Contains(prototypeArtifact.Diagnostic, "including archived candidates") || !strings.Contains(prototypeArtifact.Diagnostic, "refresh registration") {
		t.Fatalf("Prototype migration TEACH was not preserved: %+v", prototypeArtifact)
	}
	var observation ac.Response
	if err := json.Unmarshal(snapshot.Observations["prototype_status"], &observation); err != nil || observation.Outcome != "no_go" || len(observation.Diagnostics) != 2 {
		t.Fatalf("Prototype no-go observation was not retained: %+v err=%v", observation, err)
	}
}

func writeExecutable(t *testing.T, root, name, contents string) {
	t.Helper()
	path := filepath.Join(root, name)
	if err := os.WriteFile(path, []byte(contents), 0o700); err != nil {
		t.Fatal(err)
	}
}

func TestPrototypeAdapterAdmitsTwoEvaluatorItemsAndExactInventory(t *testing.T) {
	root := t.TempDir()
	catalog := ac.Catalog{SchemaVersion: ac.PrototypeSchemaVersion, ProjectID: "project-a", Prototypes: []ac.Prototype{{ID: "alpha", Name: "Alpha", Root: "prototypes/alpha", Status: "active"}, {ID: "beta", Name: "Beta", Root: "prototypes/beta", Status: "archived"}}}
	catalogBytes, _ := json.Marshal(catalog)
	writeFixture(t, root, "prototypes/catalog.json", catalogBytes)
	records := []ac.DigestRecord{{SourceID: "project-a", Path: "prototypes/catalog.json", Content: catalogBytes}}
	items := make([]ac.Item, 0, len(catalog.Prototypes))
	for _, id := range []string{"alpha", "beta"} {
		manifest := apiFixtureManifest(id, "style.css")
		if id == "alpha" {
			manifest.Scenarios = []ac.Scenario{{ID: "onboarding", Name: "Onboarding review", Steps: []ac.ScenarioStep{{ScreenID: "main", StateID: "default"}, {ScreenID: "main", StateID: "default"}}}}
		}
		status := "active"
		if id == "beta" {
			status = "archived"
		}
		items = append(items, ac.Item{ID: id, Name: strings.ToUpper(id[:1]) + id[1:], Root: "prototypes/" + id, Status: status, AuthoringMode: manifest.AuthoringMode, EntryPoint: manifest.EntryPoint, Screens: manifest.Screens, Transitions: manifest.Transitions, Scenarios: manifest.Scenarios})
		if id == "alpha" {
			manifest.Related = []ac.Related{{Kind: "documentation", Path: "modules/declared.md"}, {Kind: "documentation", Path: "system_roadmap.md"}}
			writeFixture(t, root, "modules/declared.md", []byte("# declared evidence"))
			writeFixture(t, root, "system_roadmap.md", []byte("# canonical evidence"))
		}
		mb, _ := json.Marshal(manifest)
		mp := "prototypes/" + id + "/prototype.json"
		html := []byte("<main>" + id + "</main>")
		css := []byte("main{color:teal}")
		writeFixture(t, root, mp, mb)
		writeFixture(t, root, "prototypes/"+id+"/index.html", html)
		writeFixture(t, root, "prototypes/"+id+"/style.css", css)
		image := []byte("fixture-image")
		writeFixture(t, root, "prototypes/"+id+"/images/main.webp", image)
		records = append(records, ac.DigestRecord{SourceID: "project-a", Path: mp, Content: mb}, ac.DigestRecord{SourceID: "project-a", Path: "prototypes/" + id + "/index.html", Content: html}, ac.DigestRecord{SourceID: "project-a", Path: "prototypes/" + id + "/style.css", Content: css}, ac.DigestRecord{SourceID: "project-a", Path: "prototypes/" + id + "/images/main.webp", Content: image})
	}
	digest, err := ac.InventoryDigest("project-a", records)
	if err != nil {
		t.Fatal(err)
	}
	responseBytes, _ := json.Marshal(prototypeAdapterResponse("project-a", digest, items))
	files := map[string][]byte{}
	artifacts, err := addPrototypeFiles(files, root, "project-a", responseBytes)
	if err != nil {
		t.Fatal(err)
	}
	if len(artifacts) != 2 || artifacts[0].ID != "alpha" || artifacts[1].ID != "beta" || len(files) != 11 || string(files["modules/declared.md"]) != "# declared evidence" || string(files["system_roadmap.md"]) != "# canonical evidence" {
		t.Fatalf("items=%d files=%d", len(artifacts), len(files))
	}

	badEnvelopeCases := []struct {
		name   string
		mutate func(*ac.Response)
	}{
		{name: "schema version", mutate: func(r *ac.Response) { r.SchemaVersion = "1" }},
		{name: "project identity", mutate: func(r *ac.Response) { r.ProjectID = "other-project" }},
		{name: "target", mutate: func(r *ac.Response) { r.Target = "design-system" }},
		{name: "authority scope", mutate: func(r *ac.Response) { r.AuthorityScope = "remote" }},
		{name: "mode", mutate: func(r *ac.Response) { r.Mode = "committed" }},
		{name: "revision", mutate: func(r *ac.Response) { revision := strings.Repeat("a", 40); r.Revision = &revision }},
		{name: "missing diagnostics", mutate: func(r *ac.Response) { r.Diagnostics = nil }},
		{name: "nonempty diagnostics", mutate: func(r *ac.Response) {
			r.Diagnostics = []ac.Diagnostic{{Code: "warning", Message: "partial", Resolution: "retry"}}
		}},
		{name: "design-system validation", mutate: func(r *ac.Response) { r.DesignSystemValidation = "valid" }},
		{name: "missing digest", mutate: func(r *ac.Response) { r.InventoryDigest = nil }},
		{name: "mismatched item description", mutate: func(r *ac.Response) { value := "not in catalog"; r.Items[0].Description = &value }},
		{name: "mismatched scenario projection", mutate: func(r *ac.Response) { r.Items[0].Scenarios = []ac.Scenario{} }},
	}
	for _, test := range badEnvelopeCases {
		t.Run("rejects "+test.name, func(t *testing.T) {
			response := prototypeAdapterResponse("project-a", digest, clonePrototypeItems(t, items))
			test.mutate(&response)
			responseBytes, marshalErr := json.Marshal(response)
			if marshalErr != nil {
				t.Fatal(marshalErr)
			}
			admittedFiles := map[string][]byte{}
			if _, err := addPrototypeFiles(admittedFiles, root, "project-a", responseBytes); err == nil || len(admittedFiles) != 0 {
				t.Fatalf("invalid evaluator response was admitted: err=%v files=%v", err, admittedFiles)
			}
		})
	}
	for _, field := range []string{"schema_version", "project_id", "target", "authority_scope", "mode", "revision", "outcome", "inventory_digest", "items", "diagnostics", "design_system_validation"} {
		t.Run("rejects missing envelope field "+field, func(t *testing.T) {
			complete, marshalErr := json.Marshal(prototypeAdapterResponse("project-a", digest, clonePrototypeItems(t, items)))
			if marshalErr != nil {
				t.Fatal(marshalErr)
			}
			var fields map[string]json.RawMessage
			if err := json.Unmarshal(complete, &fields); err != nil {
				t.Fatal(err)
			}
			delete(fields, field)
			incomplete, marshalErr := json.Marshal(fields)
			if marshalErr != nil {
				t.Fatal(marshalErr)
			}
			if _, err := addPrototypeFiles(map[string][]byte{}, root, "project-a", incomplete); err == nil {
				t.Fatal("incomplete evaluator response was admitted")
			}
		})
	}
}

func clonePrototypeItems(t *testing.T, items []ac.Item) []ac.Item {
	t.Helper()
	encoded, err := json.Marshal(items)
	if err != nil {
		t.Fatal(err)
	}
	var copy []ac.Item
	if err := json.Unmarshal(encoded, &copy); err != nil {
		t.Fatal(err)
	}
	return copy
}

func TestPrototypeAdapterRejectsPrivateRelatedBeforeAdmittingBytes(t *testing.T) {
	root := t.TempDir()
	catalog := ac.Catalog{SchemaVersion: ac.PrototypeSchemaVersion, ProjectID: "project-a", Prototypes: []ac.Prototype{{ID: "alpha", Name: "Alpha", Root: "prototypes/alpha", Status: "active"}}}
	catalogBytes, _ := json.Marshal(catalog)
	manifest := apiFixtureManifest("alpha")
	manifest.Related = []ac.Related{{Kind: "documentation", Path: ".env"}}
	manifestBytes, _ := json.Marshal(manifest)
	entry := []byte("<main>safe content</main>")
	writeFixture(t, root, "prototypes/catalog.json", catalogBytes)
	writeFixture(t, root, "prototypes/alpha/prototype.json", manifestBytes)
	writeFixture(t, root, "prototypes/alpha/index.html", entry)
	writeFixture(t, root, ".env", []byte("PRIVATE_SHOULD_NOT_BE_SNAPSHOTTED"))
	image := []byte("fixture-image")
	writeFixture(t, root, "prototypes/alpha/images/main.webp", image)
	digest, err := ac.InventoryDigest("project-a", []ac.DigestRecord{{SourceID: "project-a", Path: "prototypes/catalog.json", Content: catalogBytes}, {SourceID: "project-a", Path: "prototypes/alpha/prototype.json", Content: manifestBytes}, {SourceID: "project-a", Path: "prototypes/alpha/index.html", Content: entry}, {SourceID: "project-a", Path: "prototypes/alpha/images/main.webp", Content: image}})
	if err != nil {
		t.Fatal(err)
	}
	responseBytes, _ := json.Marshal(prototypeAdapterResponse("project-a", digest, []ac.Item{{ID: "alpha", Name: "Alpha", Root: "prototypes/alpha", Status: "active", AuthoringMode: manifest.AuthoringMode, EntryPoint: manifest.EntryPoint, Screens: manifest.Screens, Transitions: manifest.Transitions}}))
	files := map[string][]byte{}
	artifacts, err := addPrototypeFiles(files, root, "project-a", responseBytes)
	if err == nil || len(files) != 0 || len(artifacts) != 0 {
		t.Fatalf("private evidence admitted: artifacts=%+v files=%v err=%v", artifacts, files, err)
	}
}

func TestDesignSystemAdapterUsesSelectedCompanySourceAndDeclaredFiles(t *testing.T) {
	workspace := t.TempDir()
	checkout := filepath.Join(workspace, "company-system")
	if err := os.MkdirAll(checkout, 0o755); err != nil {
		t.Fatal(err)
	}
	cmd := exec.Command("git", "init", "--quiet", checkout)
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Fatalf("git init: %v %s", err, out)
	}
	definition := ac.DesignSystemDefinition{SchemaVersion: "1", ID: "company-system", Name: "Company System", Owner: ac.DesignSystemOwner{Level: "company", ID: "company-a"}, Tokens: []ac.DesignToken{}, Components: []ac.DesignComponent{{ID: "button", Name: "Button", Documentation: "guide.md", TokenIDs: []string{}, States: []string{}, Variants: []ac.DesignVariant{}, Examples: []string{"examples/preview.html"}}}, Assets: []string{"assets/logo.svg"}, ContrastPairs: []ac.ContrastPair{}}
	definitionBytes, _ := json.Marshal(definition)
	guide := []byte("# Guide")
	example := []byte("<main>Company preview</main>")
	asset := []byte("<svg xmlns=\"http://www.w3.org/2000/svg\"></svg>")
	writeFixture(t, checkout, "design-system.json", definitionBytes)
	writeFixture(t, checkout, "guide.md", guide)
	writeFixture(t, checkout, "examples/preview.html", example)
	writeFixture(t, checkout, "assets/logo.svg", asset)
	bindings := map[string]any{"schema_version": "1", "project_id": "project-a", "company_id": "company-a", "sources": map[string]any{"default": nil, "project": nil, "company": map[string]any{"repository_id": "company-repo", "checkout_root": "company-system", "revision": nil, "definition_path": "design-system.json"}}}
	bindingsBytes, _ := json.Marshal(bindings)
	writeFixture(t, workspace, "bindings.json", bindingsBytes)
	records := []ac.DigestRecord{{SourceID: "company-repo", Path: "design-system.json", Content: definitionBytes}, {SourceID: "company-repo", Path: "guide.md", Content: guide}, {SourceID: "company-repo", Path: "examples/preview.html", Content: example}, {SourceID: "company-repo", Path: "assets/logo.svg", Content: asset}}
	digest, err := ac.InventoryDigest("company-repo", records)
	if err != nil {
		t.Fatal(err)
	}
	level := "company"
	result, _ := json.Marshal(ac.DesignSystemResponse{Outcome: "go", InventoryDigest: &digest, Items: []ac.DesignSystemDefinition{definition}, SelectedLevel: &level})
	var response map[string]any
	_ = json.Unmarshal(result, &response)
	sourceObject := map[string]any{"repository_id": "company-repo", "owner_level": "company", "owner_id": "company-a", "definition_path": "design-system.json"}
	response["source"] = sourceObject
	result, _ = json.Marshal(response)
	files := map[string][]byte{}
	artifact, err := addDesignSystemFiles(files, workspace, "bindings.json", result)
	if err != nil {
		t.Fatal(err)
	}
	if artifact.State != "available" || artifact.Entry != "design/system/examples/preview.html" || len(artifact.Files) != 4 || string(files["design/system/assets/logo.svg"]) != string(asset) {
		t.Fatalf("artifact=%+v", artifact)
	}
}

func TestLandingRejectsIdentityAndOutOfRootRowsWithoutPartialAdmission(t *testing.T) {
	root := t.TempDir()
	body := []byte("<html></html>")
	writeFixture(t, root, "design/landing/index.html", body)
	private := []byte("private")
	writeFixture(t, root, "private.md", private)
	rows := []any{landingFileRow("design/landing/index.html", body), landingFileRow("private.md", private)}
	writeLandingManifest(t, root, rows)
	files := map[string][]byte{}
	if _, err := addLanding(files, root, "other-project", "company-a"); err == nil || len(files) != 0 {
		t.Fatal("identity mismatch partially admitted files")
	}
	if _, err := addLanding(files, root, "project-a", "company-a"); err == nil || len(files) != 0 {
		t.Fatal("unadmitted private path partially admitted files")
	}
	rows = []any{landingFileRow("design/landing/index.html", body)}
	for _, name := range []string{"domain_entities.md", "project_constitution.md", "project_landing.md", "project_mandate.md", "system_roadmap.md"} {
		content := []byte("# " + name)
		writeFixture(t, root, name, content)
		rows = append(rows, landingFileRow(name, content))
	}
	writeLandingManifest(t, root, rows)
	artifact, err := addLanding(files, root, "project-a", "company-a")
	if err != nil || artifact.State != "available" || len(artifact.Files) != 6 || len(files) != 6 {
		t.Fatalf("canonical relative evidence was not admitted: artifact=%+v files=%d err=%v", artifact, len(files), err)
	}
}

func TestVisualOriginComparesOnlyCompatibleHashDomains(t *testing.T) {
	root := t.TempDir()
	kDigest, rDigest, dDigest := "sha256:"+strings.Repeat("a", 64), "sha256:"+strings.Repeat("b", 64), "sha256:"+strings.Repeat("c", 64)
	manifest := map[string]any{"local_visual_artifact": map[string]any{"generated_at_utc": "2026-10-06T22:20:47Z", "generator": "fixture", "foundation_origin": map[string]any{"head_commit": "abc", "source_tree": "working_tree", "knowledge_source_digest": "sha256:k", "knowledge_source_encoding": knowledgeSourceEncoding, "roadmap_source_digest": "sha256:r", "roadmap_source_encoding": roadmapSourceEncoding, "legacy_source_snapshot_encoding": "sha256-utf8-sorted-path-tab-content-sha256-newline-v1"}, "design_system_origin": map[string]any{"repository_id": "repo", "inventory_digest": "sha256:d", "inventory_encoding": designSystemEncoding}}}
	manifest["local_visual_artifact"].(map[string]any)["foundation_origin"].(map[string]any)["knowledge_source_digest"] = kDigest
	manifest["local_visual_artifact"].(map[string]any)["foundation_origin"].(map[string]any)["roadmap_source_digest"] = rDigest
	manifest["local_visual_artifact"].(map[string]any)["design_system_origin"].(map[string]any)["inventory_digest"] = dDigest
	data, _ := json.Marshal(manifest)
	writeFixture(t, root, "project_landing.manifest.json", data)
	knowledge, _ := json.Marshal(map[string]any{"landing": map[string]string{"observed_source_digest": kDigest}, "roadmap": map[string]string{"observed_source_digest": rDigest}})
	design, _ := json.Marshal(map[string]string{"inventory_digest": dDigest})
	var observed map[string]string
	if err := json.Unmarshal(visualOriginObservation(root, knowledge, design), &observed); err != nil {
		t.Fatal(err)
	}
	if observed["state"] != "matching" || observed["knowledge_source_state"] != "matching" || observed["roadmap_source_state"] != "matching" || observed["design_system_state"] != "matching" {
		t.Fatalf("compatible origin comparison: %v", observed)
	}
	changedKnowledge, _ := json.Marshal(map[string]any{"landing": map[string]string{"observed_source_digest": "sha256:" + strings.Repeat("d", 64)}, "roadmap": map[string]string{"observed_source_digest": rDigest}})
	if err := json.Unmarshal(visualOriginObservation(root, changedKnowledge, design), &observed); err != nil {
		t.Fatal(err)
	}
	if observed["state"] != "mismatch" {
		t.Fatalf("digest mismatch was not distinct: %v", observed)
	}
	manifest["local_visual_artifact"].(map[string]any)["foundation_origin"].(map[string]any)["knowledge_source_encoding"] = "sha256-utf8-sorted-path-tab-content-sha256-newline-v1"
	data, _ = json.Marshal(manifest)
	writeFixture(t, root, "project_landing.manifest.json", data)
	if err := json.Unmarshal(visualOriginObservation(root, knowledge, design), &observed); err != nil {
		t.Fatal(err)
	}
	if observed["state"] != "unverifiable" || observed["knowledge_source_state"] != "unverifiable" {
		t.Fatalf("incompatible legacy domain was compared: %v", observed)
	}
}

func landingFileRow(name string, content []byte) map[string]any {
	digest := sha256.Sum256(content)
	return map[string]any{"path": name, "content_digest": "sha256:" + hex.EncodeToString(digest[:])}
}
func writeLandingManifest(t *testing.T, root string, rows []any) {
	t.Helper()
	manifest := map[string]any{"local_visual_artifact": map[string]any{"path": "design/landing/index.html", "project_id": "project-a", "company_id": "company-a", "artifact_files": rows}}
	manifestBytes, err := json.Marshal(manifest)
	if err != nil {
		t.Fatal(err)
	}
	writeFixture(t, root, "project_landing.manifest.json", manifestBytes)
}

func writeFixture(t *testing.T, root, relative string, data []byte) {
	t.Helper()
	full := filepath.Join(root, filepath.FromSlash(relative))
	if err := os.MkdirAll(filepath.Dir(full), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(full, data, 0o644); err != nil {
		t.Fatal(err)
	}
}

func apiFixtureManifest(id string, assets ...string) ac.Manifest {
	return ac.Manifest{SchemaVersion: ac.PrototypeSchemaVersion, ID: id, AuthoringMode: "design_system_first", EntryPoint: "index.html",
		Screens: []ac.Screen{{ID: "main", Name: "Main", Path: "index.html", DefaultStateID: "default", States: []ac.State{{ID: "default", Name: "Default", IdentifierImage: "images/main.webp", ApprovedReferences: []ac.ApprovedReference{}}}}},
		Sources: []string{"index.html"}, Assets: append([]string{"images/main.webp"}, assets...), Transitions: []ac.Transition{}, Scenarios: []ac.Scenario{}, Related: []ac.Related{}, DesignSystemRef: nil}
}

func prototypeAdapterResponse(projectID, digest string, items []ac.Item) ac.Response {
	return ac.Response{
		SchemaVersion: ac.PrototypeSchemaVersion, ProjectID: projectID, Target: ac.TargetPrototypes,
		AuthorityScope: ac.AuthorityScope, Mode: "working-tree", Revision: nil, Outcome: "go",
		InventoryDigest: &digest, Items: items, Diagnostics: []ac.Diagnostic{},
		DesignSystemValidation: "not_evaluated",
	}
}
