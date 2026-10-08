package builder_project

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

func TestRegisterListConflictDeclineAndRecovery(t *testing.T) {
	store, err := Open(privateTempDir(t))
	if err != nil {
		t.Fatal(err)
	}
	input := trial("project-a", "company-a")
	prepare := func(r Registration) (Snapshot, error) { return readySnapshot(r), nil }
	p, err := store.Register(input, prepare)
	if err != nil || p.PreparationState != "ready" || p.SnapshotFingerprint == "" {
		t.Fatalf("register: %#v, %v", p, err)
	}
	if _, err := store.Register(input, prepare); err != nil {
		t.Fatalf("matching retry: %v", err)
	}
	renamed := input
	renamed.CompanyName = "Company A Renamed"
	renamed.ProjectName = "Project A Renamed"
	if _, err := store.Register(renamed, prepare); err != nil {
		t.Fatalf("display-name refresh conflicted with stable identity: %v", err)
	}
	updated, err := store.List()
	if err != nil || updated.Companies[0].Name != renamed.CompanyName || updated.Projects[0].Name != renamed.ProjectName {
		t.Fatalf("display metadata was not refreshed: %#v %v", updated, err)
	}
	input = renamed
	conflict := input
	conflict.CompanyID = "company-b"
	conflict.CompanyName = "Company B"
	if _, err := store.Register(conflict, prepare); !errors.Is(err, ErrConflict) {
		t.Fatalf("conflict=%v", err)
	}
	status, found, declined, err := store.Status(input.ProjectID, input.Binding)
	if err != nil || !found || status.Binding == nil || declined {
		t.Fatalf("status leaked binding or lost project: %#v %v %v %v", status, found, declined, err)
	}
	catalog, err := store.List()
	if err != nil || len(catalog.Projects) != 1 || len(catalog.Companies) != 1 {
		t.Fatalf("list=%#v %v", catalog, err)
	}
	public, _ := json.Marshal(catalog)
	if strings.Contains(string(public), "workspace_root") {
		t.Fatal("public catalog exposed the private source context")
	}
	if err := store.Decline(input.ProjectID, input.Binding); err == nil {
		t.Fatal("decline removed a registered Project")
	}
	catalog, err = store.List()
	if err != nil || len(catalog.Projects) != 1 || len(catalog.Companies) != 1 {
		t.Fatalf("registered Project was destructively removed: %#v %v", catalog, err)
	}
	if err := store.Decline("absent-project", input.Binding); err != nil {
		t.Fatal(err)
	}
	_, found, declined, err = store.Status("absent-project", input.Binding)
	if err != nil || found || !declined {
		t.Fatalf("refusal was not retained: found=%v declined=%v err=%v", found, declined, err)
	}
	if _, err := store.Register(input, prepare); err != nil {
		t.Fatalf("authorized retry after refusal: %v", err)
	}
}

func TestResolveBindingUsesPrivateRegistrationWithoutCallerPath(t *testing.T) {
	store, err := Open(privateTempDir(t))
	if err != nil {
		t.Fatal(err)
	}
	input := trial("project-a", "company-a")
	if _, err := store.Register(input, func(r Registration) (Snapshot, error) { return readySnapshot(r), nil }); err != nil {
		t.Fatal(err)
	}
	project, binding, found, declined, err := store.ResolveBinding(input.ProjectID)
	if err != nil || !found || declined || project.CompanyID != input.CompanyID || binding != input.Binding {
		t.Fatalf("resolved binding mismatch: project=%#v binding=%#v found=%v declined=%v err=%v", project, binding, found, declined, err)
	}
	if _, _, found, declined, err := store.ResolveBinding("absent-project"); err != nil || found || declined {
		t.Fatalf("unregistered Project was not reported as absent: found=%v declined=%v err=%v", found, declined, err)
	}
	if err := store.Decline("declined-project", input.Binding); err != nil {
		t.Fatal(err)
	}
	_, declinedBinding, found, declined, err := store.ResolveBinding("declined-project")
	if err != nil || found || !declined || declinedBinding != input.Binding {
		t.Fatalf("declined binding was not retained: binding=%#v found=%v declined=%v err=%v", declinedBinding, found, declined, err)
	}
}

func TestPreparationFailurePersistsNotReadyAndRetryRecovers(t *testing.T) {
	store, err := Open(privateTempDir(t))
	if err != nil {
		t.Fatal(err)
	}
	input := trial("project-a", "company-a")
	p, err := store.Register(input, func(Registration) (Snapshot, error) {
		return Snapshot{Artifacts: []Artifact{{ID: "landing", State: "pending"}}}, errors.New("fixture failure")
	})
	if err == nil || p.PreparationState != "not_ready" || p.SnapshotFingerprint != "" {
		t.Fatalf("partial preparation was not explicit: %#v %v", p, err)
	}
	p, err = store.Register(input, func(r Registration) (Snapshot, error) { return readySnapshot(r), nil })
	if err != nil || p.PreparationState != "ready" || p.SnapshotFingerprint == "" {
		t.Fatalf("retry did not recover: %#v %v", p, err)
	}
}

func TestCorruptRegistryIsNotAbsenceAndMutationLockIsBusy(t *testing.T) {
	root := privateTempDir(t)
	store, err := Open(root)
	if err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(root, "registry.json"), []byte("{"), 0o600); err != nil {
		t.Fatal(err)
	}
	if _, err := store.List(); err == nil {
		t.Fatal("corrupt registry was reported as empty")
	}
	if err := os.Remove(filepath.Join(root, "registry.json")); err != nil {
		t.Fatal(err)
	}
	duplicate := []byte(`{"schema_version":"builder-project-registry-v1","schema_version":"builder-project-registry-v1","companies":{},"projects":{},"preferences":{}}`)
	if err := os.WriteFile(filepath.Join(root, "registry.json"), duplicate, 0o600); err != nil {
		t.Fatal(err)
	}
	if _, err := store.List(); err == nil {
		t.Fatal("duplicate registry keys were accepted")
	}
	if err := os.Remove(filepath.Join(root, "registry.json")); err != nil {
		t.Fatal(err)
	}
	companyMismatch := emptyRegistry()
	companyMismatch.Companies["wrong-key"] = Company{ID: "company-a", Name: "Company A"}
	orphanProject := emptyRegistry()
	orphanProject.Projects["project-a"] = Project{ID: "project-a", Name: "Project A", CompanyID: "missing-company", Binding: func() *Binding { b := trial("project-a", "missing-company").Binding; return &b }(), PreparationState: "not_ready", Artifacts: []Artifact{}}
	malformedBinding := emptyRegistry()
	malformedBinding.Companies["company-a"] = Company{ID: "company-a", Name: "Company A"}
	badDigestBinding := trial("project-a", "company-a").Binding
	badDigestBinding.SourceBindingsPath = "bindings.json"
	badDigestBinding.SourceBindingsDigest = "sha256:" + strings.Repeat("g", 64)
	malformedBinding.Projects["project-a"] = Project{ID: "project-a", Name: "Project A", CompanyID: "company-a", Binding: &badDigestBinding, RegisteredAt: time.Now().UTC().Format(time.RFC3339Nano), PreparationState: "not_ready", Artifacts: []Artifact{}}
	for name, invalid := range map[string]registry{"map key mismatch": companyMismatch, "orphan Company": orphanProject, "malformed lowercase SHA-256 source binding": malformedBinding} {
		data, err := json.Marshal(invalid)
		if err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(filepath.Join(root, "registry.json"), data, 0o600); err != nil {
			t.Fatal(err)
		}
		if _, err := store.List(); err == nil {
			t.Fatalf("%s was accepted as a valid registry", name)
		}
	}
	if err := os.Remove(filepath.Join(root, "registry.json")); err != nil {
		t.Fatal(err)
	}
	validPrior := emptyRegistry()
	validPrior.Companies["company-a"] = Company{ID: "company-a", Name: "Company A"}
	binding := trial("project-a", "company-a").Binding
	validPrior.Projects["project-a"] = Project{ID: "project-a", Name: "Project A", CompanyID: "company-a", Binding: &binding, RegisteredAt: time.Now().UTC().Format(time.RFC3339Nano), PreparationState: "not_ready", SnapshotFingerprint: strings.Repeat("a", 64), Artifacts: []Artifact{{ID: "landing", State: "pending"}}}
	validBytes, _ := json.Marshal(validPrior)
	if err := os.WriteFile(filepath.Join(root, "registry.json"), validBytes, 0o600); err != nil {
		t.Fatal(err)
	}
	if _, err := store.List(); err != nil {
		t.Fatalf("not_ready with prior snapshot must remain valid: %v", err)
	}
	validPrior.Projects["project-a"] = Project{ID: "project-a", Name: "Project A", CompanyID: "company-a", Binding: &binding, RegisteredAt: time.Now().UTC().Format(time.RFC3339Nano), PreparationState: "ready", Artifacts: []Artifact{}}
	invalidBytes, _ := json.Marshal(validPrior)
	if err := os.WriteFile(filepath.Join(root, "registry.json"), invalidBytes, 0o600); err != nil {
		t.Fatal(err)
	}
	if _, err := store.List(); err == nil {
		t.Fatal("ready record without fingerprint was accepted")
	}
	if err := os.Remove(filepath.Join(root, "registry.json")); err != nil {
		t.Fatal(err)
	}
	lock, err := store.lock()
	if err != nil {
		t.Fatal(err)
	}
	if _, err := store.Register(trial("project-a", "company-a"), func(r Registration) (Snapshot, error) { return readySnapshot(r), nil }); !errors.Is(err, ErrBusy) {
		t.Fatalf("overlap=%v", err)
	}
	unlock(lock)
}

func TestMissingStateRootIsUnavailableWithoutCreation(t *testing.T) {
	root := filepath.Join(t.TempDir(), "not-created")
	if _, err := Open(root); err == nil {
		t.Fatal("missing state root was treated as an empty registry")
	}
	if _, err := os.Lstat(root); !errors.Is(err, os.ErrNotExist) {
		t.Fatalf("missing state root was created: %v", err)
	}
}

func TestFiveOverlappingRegistrationsAcrossTwoBatchesRetryWithoutLostRecords(t *testing.T) {
	store, err := Open(privateTempDir(t))
	if err != nil {
		t.Fatal(err)
	}
	var busyRetries atomic.Int32
	for batch := 0; batch < 2; batch++ {
		start := make(chan struct{})
		var wg sync.WaitGroup
		var ready sync.WaitGroup
		errs := make(chan error, 5)
		ready.Add(5)
		for i := 0; i < 5; i++ {
			projectID := fmt.Sprintf("project-%d-%d", batch, i)
			companyID := fmt.Sprintf("company-%d", batch)
			wg.Add(1)
			go func() {
				defer wg.Done()
				ready.Done()
				<-start
				input := trial(projectID, companyID)
				for attempt := 0; attempt < 1000; attempt++ {
					_, err := store.Register(input, func(r Registration) (Snapshot, error) { time.Sleep(2 * time.Millisecond); return readySnapshot(r), nil })
					if errors.Is(err, ErrBusy) {
						busyRetries.Add(1)
						time.Sleep(5 * time.Millisecond)
						continue
					}
					if err != nil {
						errs <- err
					}
					return
				}
				errs <- errors.New("registration did not recover from busy")
			}()
		}
		ready.Wait()
		close(start)
		wg.Wait()
		close(errs)
		for err := range errs {
			t.Fatal(err)
		}
	}
	if busyRetries.Load() == 0 {
		t.Fatal("overlapping batches never observed registry_busy")
	}
	catalog, err := store.List()
	if err != nil {
		t.Fatal(err)
	}
	if len(catalog.Projects) != 10 || len(catalog.Companies) != 2 {
		t.Fatalf("lost or duplicated records: projects=%d companies=%d", len(catalog.Projects), len(catalog.Companies))
	}
	want := map[string]string{}
	for batch := 0; batch < 2; batch++ {
		for i := 0; i < 5; i++ {
			want[fmt.Sprintf("project-%d-%d", batch, i)] = fmt.Sprintf("company-%d", batch)
		}
	}
	fingerprints := map[string]bool{}
	for _, project := range catalog.Projects {
		if want[project.ID] != project.CompanyID || project.PreparationState != "ready" || len(project.SnapshotFingerprint) != 64 || fingerprints[project.SnapshotFingerprint] {
			t.Fatalf("unexpected surviving record: %+v", project)
		}
		fingerprints[project.SnapshotFingerprint] = true
		snapshot, err := store.LoadSnapshot(project.ID, project.CompanyID, project.SnapshotFingerprint)
		if err != nil || string(snapshot.Files["design/landing/index.html"]) != "<main>"+project.ID+"</main>" {
			t.Fatalf("wrong immutable snapshot for %s: %v", project.ID, err)
		}
		delete(want, project.ID)
	}
	if len(want) != 0 {
		t.Fatalf("missing exact Project identities: %v", want)
	}
}

func trial(projectID, companyID string) Registration {
	return Registration{ProjectID: projectID, ProjectName: "Trial " + projectID, CompanyID: companyID, CompanyName: "Trial " + companyID, Binding: Binding{WorkspaceRoot: "/tmp/trial", ProjectRoot: "project", FoundationRoot: "project/foundation"}}
}
func privateTempDir(t *testing.T) string {
	t.Helper()
	root := t.TempDir()
	if err := os.Chmod(root, 0o700); err != nil {
		t.Fatal(err)
	}
	return root
}
func readySnapshot(r Registration) Snapshot {
	return Snapshot{SchemaVersion: SnapshotSchema, ProjectID: r.ProjectID, CompanyID: r.CompanyID, ObservedAt: time.Now().UTC().Format(time.RFC3339Nano), Files: map[string][]byte{"design/landing/index.html": []byte("<main>" + r.ProjectID + "</main>")}, Artifacts: []Artifact{{ID: "landing", Name: "Landing", State: "available", Entry: "design/landing/index.html", Files: []string{"design/landing/index.html"}}}}
}
