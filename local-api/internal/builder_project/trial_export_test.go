package builder_project

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
)

func TestExportDisposableTwoCompanyTrial(t *testing.T) {
	root := os.Getenv("DELPHI_LOCAL_API_TRIAL_OUTPUT_ROOT")
	if root == "" {
		return
	}
	if root != "/trial-output" {
		t.Fatal("trial export target must be the dedicated test-only mount")
	}
	entries, err := os.ReadDir(root)
	if err != nil || len(entries) != 0 {
		t.Fatal("trial output root must be empty")
	}
	workspace := filepath.Join(root, "workspace")
	state := filepath.Join(root, "state")
	if err := os.MkdirAll(state, 0o700); err != nil {
		t.Fatal(err)
	}
	for _, fixture := range []struct {
		name, projectID, companyID string
		populated                  bool
	}{
		{"trial-a", "trial-project-a", "trial-company-a", true},
		{"trial-b", "trial-project-b", "trial-company-b", false},
	} {
		projectRoot := filepath.Join(workspace, fixture.name)
		foundation := filepath.Join(projectRoot, "foundation")
		if err := os.MkdirAll(foundation, 0o700); err != nil {
			t.Fatal(err)
		}
		for path, content := range map[string]string{
			"project_mandate.md":      "# Trial mandate\n",
			"domain_entities.md":      "# Trial entities\n",
			"project_constitution.md": "# Trial constitution\n",
			"system_roadmap.md":       "# Trial roadmap\n",
			"project_landing.md":      "# Trial landing\n",
		} {
			if err := writeTrialFile(foundation, path, []byte(content)); err != nil {
				t.Fatal(err)
			}
		}
		if fixture.populated {
			landingHTML := []byte("<!doctype html><html><head><link rel=\"stylesheet\" href=\"./landing.css\"></head><body><main id=\"trial-a\">Trial Project A</main><img alt=\"Fixture marker\" src=\"./assets/marker.svg\"></body></html>")
			css := []byte("body { background: #eef; } main { color: #123; }")
			asset := []byte("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\"><text y=\"14\">A</text></svg>")
			rows := []map[string]string{}
			for _, item := range []struct {
				path    string
				content []byte
			}{{"design/landing/index.html", landingHTML}, {"design/landing/landing.css", css}, {"design/landing/assets/marker.svg", asset}} {
				path, content := item.path, item.content
				if err := writeTrialFile(foundation, path, content); err != nil {
					t.Fatal(err)
				}
				sum := sha256.Sum256(content)
				rows = append(rows, map[string]string{"path": path, "content_digest": "sha256:" + hex.EncodeToString(sum[:])})
			}
			manifest := map[string]any{"local_visual_artifact": map[string]any{"path": "design/landing/index.html", "project_id": fixture.projectID, "company_id": fixture.companyID, "artifact_files": rows}}
			data, err := json.Marshal(manifest)
			if err != nil {
				t.Fatal(err)
			}
			if err := writeTrialFile(foundation, "project_landing.manifest.json", append(data, '\n')); err != nil {
				t.Fatal(err)
			}
		} else {
			if err := writeTrialFile(foundation, "prototypes/catalog.json", []byte(`{"schema_version":"2","project_id":"trial-project-b","prototypes":null}`)); err != nil {
				t.Fatal(err)
			}
		}
		if out, err := exec.Command("git", "-C", foundation, "init", "--quiet").CombinedOutput(); err != nil {
			t.Fatalf("initialize fixture Foundation: %s", out)
		}
	}
	t.Logf("disposable trial exported: workspace=%s state=%s", workspace, state)
}

func writeTrialFile(root, relative string, data []byte) error {
	path := filepath.Join(root, filepath.FromSlash(relative))
	if err := os.MkdirAll(filepath.Dir(path), 0o700); err != nil {
		return err
	}
	return os.WriteFile(path, data, 0o600)
}
