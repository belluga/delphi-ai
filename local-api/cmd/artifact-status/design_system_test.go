package main

import (
	"bytes"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func bindingFixture(t *testing.T, data string) (string, []string) {
	t.Helper()
	w, _, _ := artifactFixture(t)
	path := filepath.Join(w, "bindings.json")
	if err := os.WriteFile(path, []byte(data), 0o600); err != nil {
		t.Fatal(err)
	}
	args := []string{"--workspace-root", w, "--project-root", "project", "--foundation-root", "foundation", "--project-id", "fixture-project", "--company-id", "fixture-company", "--source-bindings", "bindings.json", "--mode", "working-tree"}
	return w, args
}

const validBindings = `{"schema_version":"1","project_id":"fixture-project","company_id":"fixture-company","sources":{"project":{"repository_id":"project-repo","checkout_root":"foundation","revision":null,"definition_path":"design/design-system/design-system.json"},"company":null,"default":null}}`

func TestDesignSystemRequiresMatchingExplicitContextAndUsesSelectedProject(t *testing.T) {
	_, args := bindingFixture(t, validBindings)
	var stdout, stderr bytes.Buffer
	code := run(append([]string{"design-system"}, args...), &stdout, &stderr)
	if code != 2 || stderr.Len() != 0 {
		t.Fatalf("selected missing definition must be semantic no-go: code=%d stderr=%q", code, stderr.String())
	}
	var response struct {
		Outcome       string  `json:"outcome"`
		SelectedLevel *string `json:"selected_level"`
		Diagnostics   []struct {
			Code string `json:"code"`
		} `json:"diagnostics"`
	}
	if err := json.Unmarshal(stdout.Bytes(), &response); err != nil {
		t.Fatal(err)
	}
	if response.Outcome != "no_go" || response.SelectedLevel == nil || *response.SelectedLevel != "project" {
		t.Fatalf("selected project source was not evaluated: %#v", response)
	}
	for _, d := range response.Diagnostics {
		if d.Code == "missing_file" {
			return
		}
	}
	t.Fatalf("missing selected definition did not fail semantically: %#v", response.Diagnostics)
}

func TestDesignSystemUsesStandardProjectSourceWithoutBindingFile(t *testing.T) {
	workspace, project, foundation := artifactFixture(t)
	write := func(relative, contents string) {
		t.Helper()
		path := filepath.Join(foundation, filepath.FromSlash(relative))
		if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(path, []byte(contents), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	write("design/system/design-system.json", `{"schema_version":"1","id":"standard-system","name":"Standard System","owner":{"level":"project","id":"fixture-project"},"tokens":[{"id":"ink","type":"color","value":"#111111"}],"components":[{"id":"button","name":"Button","documentation":"guide.md","token_ids":["ink"],"states":[],"variants":[],"examples":["examples.html"]}],"assets":[],"contrast_pairs":[]}`)
	write("design/system/guide.md", "## Overview\nPurpose.\n## Foundations\nTokens.\n## Components\nButtons.\n")
	write("design/system/examples.html", "<main>Standard system</main>")
	args := []string{"design-system", "--workspace-root", workspace, "--project-root", filepath.Base(project), "--foundation-root", filepath.Base(foundation), "--project-id", "fixture-project", "--company-id", "fixture-company", "--mode", "working-tree"}
	var stdout, stderr bytes.Buffer
	if code := run(args, &stdout, &stderr); code != 0 || stderr.Len() != 0 {
		t.Fatalf("mapless standard Project source: code=%d stdout=%s stderr=%s", code, stdout.String(), stderr.String())
	}
	var provider struct {
		Outcome                string  `json:"outcome"`
		SelectedLevel          string  `json:"selected_level"`
		DesignSystemValidation string  `json:"design_system_validation"`
		InventoryDigest        *string `json:"inventory_digest"`
		Items                  []struct {
			ID    string `json:"id"`
			Owner struct {
				Level string `json:"level"`
				ID    string `json:"id"`
			} `json:"owner"`
		} `json:"items"`
	}
	if err := json.Unmarshal(stdout.Bytes(), &provider); err != nil {
		t.Fatal(err)
	}
	if provider.Outcome != "go" || provider.SelectedLevel != "project" || provider.DesignSystemValidation != "valid" || provider.InventoryDigest == nil || *provider.InventoryDigest == "" || len(provider.Items) != 1 || provider.Items[0].ID != "standard-system" || provider.Items[0].Owner.Level != "project" || provider.Items[0].Owner.ID != "fixture-project" {
		t.Fatalf("mapless Project source was not fully admitted: %+v", provider)
	}
	write("design/system/guide.md", "## Overview\nPurpose.\n## Components\nButtons.\n")
	stdout.Reset()
	stderr.Reset()
	if code := run(args, &stdout, &stderr); code != 2 || stderr.Len() != 0 || !strings.Contains(stdout.String(), `"code": "invalid_schema"`) || !strings.Contains(stdout.String(), `"outcome": "no_go"`) || !strings.Contains(stdout.String(), `"inventory_digest": null`) {
		t.Fatalf("invalid guide did not fail the public operation: code=%d stdout=%s stderr=%s", code, stdout.String(), stderr.String())
	}
	stdout.Reset()
	stderr.Reset()
	args[len(args)-1] = "committed"
	if code := run(args, &stdout, &stderr); code != 2 || stderr.Len() != 0 || !strings.Contains(stdout.String(), `"code": "revision_unavailable"`) {
		t.Fatalf("mapless committed mode must fail without a pin: code=%d stdout=%s stderr=%s", code, stdout.String(), stderr.String())
	}
}

func TestDesignSystemRejectsBindingIdentityAndStrictSchemaWithoutFallback(t *testing.T) {
	for name, data := range map[string]string{
		"mismatched project": `{"schema_version":"1","project_id":"other","company_id":"fixture-company","sources":{"project":null,"company":null,"default":null}}`,
		"unknown key":        `{"schema_version":"1","project_id":"fixture-project","company_id":"fixture-company","unexpected":true,"sources":{"project":null,"company":null,"default":null}}`,
		"broken selected project does not fallback": `{"schema_version":"1","project_id":"fixture-project","company_id":"fixture-company","sources":{"project":{"repository_id":"project-repo","checkout_root":"foundation","revision":null,"definition_path":"design/missing/design-system.json"},"company":{"repository_id":"company-repo","checkout_root":"foundation","revision":null,"definition_path":"design/design-system/design-system.json"},"default":null}}`,
	} {
		t.Run(name, func(t *testing.T) {
			_, args := bindingFixture(t, data)
			var stdout, stderr bytes.Buffer
			code := run(append([]string{"design-system"}, args...), &stdout, &stderr)
			if code != 2 || stderr.Len() != 0 {
				t.Fatalf("code=%d stdout=%q stderr=%q", code, stdout.String(), stderr.String())
			}
			var response map[string]json.RawMessage
			if err := json.Unmarshal(stdout.Bytes(), &response); err != nil {
				t.Fatal(err)
			}
			if string(response["outcome"]) != `"no_go"` {
				t.Fatalf("not no-go: %s", stdout.String())
			}
			if name == "broken selected project does not fallback" && string(response["selected_level"]) != `"project"` {
				t.Fatalf("fell back from broken selected project: %s", stdout.String())
			}
		})
	}
}

func TestDesignSystemMissingContextAndUnsafePathHaveDistinctExitClasses(t *testing.T) {
	_, args := bindingFixture(t, validBindings)
	var stdout, stderr bytes.Buffer
	code := run([]string{"design-system", "--workspace-root"}, &stdout, &stderr)
	if code != 64 || stdout.Len() != 0 || stderr.Len() == 0 {
		t.Fatalf("missing context code=%d stdout=%q stderr=%q", code, stdout.String(), stderr.String())
	}
	stdout.Reset()
	stderr.Reset()
	args = append(append([]string{}, args[:len(args)-2]...), "--source-bindings", "../private.json")
	code = run(append([]string{"design-system"}, args...), &stdout, &stderr)
	if code != 64 {
		t.Fatalf("unsafe binding path code=%d stdout=%q stderr=%q", code, stdout.String(), stderr.String())
	}
}

func TestDesignSystemValidationDoesNotExposeUnselectedRepositoryIdentity(t *testing.T) {
	const sentinel = "privatecompanysentinel"
	data := `{"schema_version":"1","project_id":"fixture-project","company_id":"fixture-company","sources":{"project":{"repository_id":"selected-project","checkout_root":"foundation","revision":null,"definition_path":"design/system/design-system.json"},"company":{"repository_id":"` + sentinel + `","checkout_root":"../private","revision":null,"definition_path":"design/system/design-system.json"},"default":null}}`
	_, args := bindingFixture(t, data)
	var stdout, stderr bytes.Buffer
	code := run(append([]string{"design-system"}, args...), &stdout, &stderr)
	if code != 2 || stderr.Len() != 0 || !strings.Contains(stdout.String(), `"outcome": "no_go"`) {
		t.Fatalf("code=%d stdout=%q stderr=%q", code, stdout.String(), stderr.String())
	}
	if strings.Contains(stdout.String(), sentinel) || strings.Contains(stderr.String(), sentinel) {
		t.Fatalf("binding identity leaked in validation output: stdout=%q stderr=%q", stdout.String(), stderr.String())
	}
	var response struct {
		Diagnostics []struct {
			SourceID string `json:"source_id"`
		} `json:"diagnostics"`
	}
	if err := json.Unmarshal(stdout.Bytes(), &response); err != nil {
		t.Fatal(err)
	}
	if len(response.Diagnostics) == 0 || response.Diagnostics[0].SourceID != "company" {
		t.Fatalf("validation should identify the source slot without echoing its repository id: %#v", response.Diagnostics)
	}
}
