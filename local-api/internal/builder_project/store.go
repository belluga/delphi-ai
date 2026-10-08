package builder_project

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"syscall"
	"time"

	"delphi-local-api/internal/codec"
	"delphi-local-api/internal/source"
)

const (
	RegistrySchema = "builder-project-registry-v1"
	SnapshotSchema = "builder-project-snapshot-v1"
	RegistryLimit  = 128 << 10
	SnapshotLimit  = 32 << 20
)

var (
	ErrBusy     = errors.New("registry_busy: another mutation is in progress; retry the operation")
	ErrConflict = errors.New("Project identity is already bound to different Company or source context")
)

type Binding struct {
	WorkspaceRoot        string `json:"workspace_root"`
	ProjectRoot          string `json:"project_root"`
	FoundationRoot       string `json:"foundation_root"`
	SourceBindingsPath   string `json:"source_bindings_path,omitempty"`
	SourceBindingsDigest string `json:"source_bindings_digest,omitempty"`
	DefaultOwnerID       string `json:"default_owner_id,omitempty"`
}

type Registration struct {
	ProjectID   string
	ProjectName string
	CompanyID   string
	CompanyName string
	Binding     Binding
}

type Artifact struct {
	ID         string   `json:"id"`
	Kind       string   `json:"kind"`
	Name       string   `json:"name"`
	State      string   `json:"state"`
	Entry      string   `json:"entry_point,omitempty"`
	Files      []string `json:"files,omitempty"`
	Diagnostic string   `json:"diagnostic,omitempty"`
}

type Snapshot struct {
	SchemaVersion string                     `json:"schema_version"`
	ProjectID     string                     `json:"project_id"`
	CompanyID     string                     `json:"company_id"`
	ObservedAt    string                     `json:"observed_at"`
	Files         map[string][]byte          `json:"files"`
	Artifacts     []Artifact                 `json:"artifacts"`
	Observations  map[string]json.RawMessage `json:"observations"`
}

type Project struct {
	ID                    string     `json:"id"`
	Name                  string     `json:"name"`
	CompanyID             string     `json:"company_id"`
	Binding               *Binding   `json:"binding,omitempty"`
	RegisteredAt          string     `json:"registered_at"`
	PreparationState      string     `json:"preparation_state"`
	PreparationDiagnostic string     `json:"preparation_diagnostic,omitempty"`
	SnapshotFingerprint   string     `json:"snapshot_fingerprint,omitempty"`
	Artifacts             []Artifact `json:"artifacts"`
}

type Company struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}
type Preference struct {
	ProjectID  string  `json:"project_id"`
	Binding    Binding `json:"binding"`
	DeclinedAt string  `json:"declined_at"`
}
type registry struct {
	SchemaVersion string                `json:"schema_version"`
	Companies     map[string]Company    `json:"companies"`
	Projects      map[string]Project    `json:"projects"`
	Preferences   map[string]Preference `json:"preferences"`
}
type Catalog struct {
	SchemaVersion string    `json:"schema_version"`
	Companies     []Company `json:"companies"`
	Projects      []Project `json:"projects"`
}

type Store struct{ root string }

func Open(root string) (*Store, error) {
	if !filepath.IsAbs(root) {
		return nil, errors.New("state-root must be absolute")
	}
	if err := source.RejectSymlinkComponents(root); err != nil {
		return nil, errors.New("state-root is unsafe")
	}
	info, err := os.Stat(root)
	if err == nil && (!info.IsDir() || info.Mode().Perm()&0o077 != 0) {
		return nil, errors.New("state-root is not a directory")
	}
	if errors.Is(err, os.ErrNotExist) {
		return nil, errors.New("state directory unavailable")
	}
	if err != nil {
		return nil, errors.New("state directory unavailable")
	}
	return &Store{root: filepath.Clean(root)}, nil
}

func (s *Store) Register(input Registration, prepare func(Registration) (Snapshot, error)) (Project, error) {
	if err := validateRegistration(input); err != nil {
		return Project{}, err
	}
	lock, err := s.lock()
	if err != nil {
		return Project{}, err
	}
	defer unlock(lock)
	r, err := s.readRegistry()
	if err != nil {
		return Project{}, err
	}
	if prior, ok := r.Projects[input.ProjectID]; ok && (prior.CompanyID != input.CompanyID || prior.Binding == nil || *prior.Binding != input.Binding) {
		return Project{}, ErrConflict
	}
	company, ok := r.Companies[input.CompanyID]
	if !ok {
		r.Companies[input.CompanyID] = Company{ID: input.CompanyID, Name: input.CompanyName}
	} else if company.Name != input.CompanyName {
		company.Name = input.CompanyName
		r.Companies[input.CompanyID] = company
	}
	p, exists := r.Projects[input.ProjectID]
	if !exists {
		binding := input.Binding
		p = Project{ID: input.ProjectID, Name: input.ProjectName, CompanyID: input.CompanyID, Binding: &binding, RegisteredAt: time.Now().UTC().Format(time.RFC3339Nano), PreparationState: "not_ready", Artifacts: []Artifact{}}
	}
	// Keep the explicit identity metadata in the registry even when artifact
	// preparation fails so a retry can recover the same binding.
	snapshot, prepErr := prepare(input)
	if prepErr == nil {
		if snapshot.SchemaVersion != SnapshotSchema || snapshot.ProjectID != input.ProjectID || snapshot.CompanyID != input.CompanyID {
			prepErr = errors.New("prepared snapshot identity is invalid")
		}
	}
	if prepErr == nil {
		fingerprint, writeErr := s.writeSnapshot(snapshot)
		if writeErr != nil {
			prepErr = writeErr
		} else {
			p.SnapshotFingerprint = fingerprint
			p.PreparationState = "ready"
			p.PreparationDiagnostic = ""
			p.Artifacts = snapshot.Artifacts
		}
	}
	if prepErr != nil {
		p.PreparationState = "not_ready"
		p.PreparationDiagnostic = "snapshot preparation failed; retry registration after correcting the source"
		p.Artifacts = snapshot.Artifacts
		if !exists {
			p.SnapshotFingerprint = ""
		}
	}
	p.Name = input.ProjectName
	r.Projects[input.ProjectID] = p
	delete(r.Preferences, input.ProjectID)
	if err := s.writeRegistry(r); err != nil {
		return Project{}, err
	}
	if prepErr != nil {
		return p, fmt.Errorf("registration saved but consumer preparation failed: %w", prepErr)
	}
	return p, nil
}

func (s *Store) Decline(projectID string, binding Binding) error {
	if !validID(projectID) {
		return errors.New("valid project-id is required")
	}
	lock, err := s.lock()
	if err != nil {
		return err
	}
	defer unlock(lock)
	r, err := s.readRegistry()
	if err != nil {
		return err
	}
	if _, exists := r.Projects[projectID]; exists {
		p := r.Projects[projectID]
		if p.Binding == nil || !sameContext(*p.Binding, binding) {
			return ErrConflict
		}
		return errors.New("already_registered: registration cannot be removed by declining optional integration")
	}
	r.Preferences[projectID] = Preference{ProjectID: projectID, Binding: binding, DeclinedAt: time.Now().UTC().Format(time.RFC3339Nano)}
	return s.writeRegistry(r)
}

func (s *Store) List() (Catalog, error) {
	r, err := s.readRegistry()
	if err != nil {
		return Catalog{}, err
	}
	c := Catalog{SchemaVersion: "1", Companies: []Company{}, Projects: []Project{}}
	for _, company := range r.Companies {
		c.Companies = append(c.Companies, company)
	}
	for _, p := range r.Projects {
		c.Projects = append(c.Projects, publicProject(p))
	}
	sort.Slice(c.Companies, func(i, j int) bool { return c.Companies[i].ID < c.Companies[j].ID })
	sort.Slice(c.Projects, func(i, j int) bool { return c.Projects[i].ID < c.Projects[j].ID })
	return c, nil
}

func (s *Store) LoadSnapshot(projectID, companyID, fingerprint string) (Snapshot, error) {
	if !validID(projectID) || !validID(companyID) || len(fingerprint) != 64 {
		return Snapshot{}, errors.New("snapshot identity is invalid")
	}
	if _, err := hex.DecodeString(fingerprint); err != nil {
		return Snapshot{}, errors.New("snapshot fingerprint is invalid")
	}
	path := filepath.Join(s.root, "snapshots", fingerprint+".json")
	data, err := source.ReadBounded(path, SnapshotLimit)
	if err != nil {
		return Snapshot{}, errors.New("immutable snapshot is unavailable")
	}
	sum := sha256.Sum256(data)
	if hex.EncodeToString(sum[:]) != fingerprint {
		return Snapshot{}, errors.New("immutable snapshot fingerprint mismatch")
	}
	var snapshot Snapshot
	if json.Unmarshal(data, &snapshot) != nil || snapshot.SchemaVersion != SnapshotSchema || snapshot.ProjectID != projectID || snapshot.CompanyID != companyID || snapshot.Files == nil {
		return Snapshot{}, errors.New("immutable snapshot identity is invalid")
	}
	if err := enforceSnapshotBounds(snapshot.Files); err != nil {
		return Snapshot{}, err
	}
	return snapshot, nil
}

func (s *Store) Status(projectID string, binding Binding) (Project, bool, bool, error) {
	r, err := s.readRegistry()
	if err != nil {
		return Project{}, false, false, err
	}
	p, ok := r.Projects[projectID]
	if ok {
		if p.Binding == nil || !sameContext(*p.Binding, binding) {
			return Project{}, false, false, ErrConflict
		}
		return p, true, false, nil
	}
	preference, declined := r.Preferences[projectID]
	if declined && !sameContext(preference.Binding, binding) {
		return Project{}, false, false, ErrConflict
	}
	return Project{}, false, declined, nil
}

// ResolveBinding returns the private binding already recorded for a Project.
// It does not create state or infer a binding for an unregistered Project.
func (s *Store) ResolveBinding(projectID string) (Project, Binding, bool, bool, error) {
	if !validID(projectID) {
		return Project{}, Binding{}, false, false, errors.New("valid project-id is required")
	}
	r, err := s.readRegistry()
	if err != nil {
		return Project{}, Binding{}, false, false, err
	}
	if p, ok := r.Projects[projectID]; ok {
		if p.Binding == nil {
			return Project{}, Binding{}, false, false, ErrConflict
		}
		return p, *p.Binding, true, false, nil
	}
	preference, declined := r.Preferences[projectID]
	if declined {
		return Project{}, preference.Binding, false, true, nil
	}
	return Project{}, Binding{}, false, false, nil
}

func sameContext(a, b Binding) bool {
	return a.WorkspaceRoot == b.WorkspaceRoot && a.ProjectRoot == b.ProjectRoot && a.FoundationRoot == b.FoundationRoot
}

func publicProject(p Project) Project { p.Binding = nil; return p }

func (s *Store) lock() (*os.File, error) {
	if err := os.MkdirAll(s.root, 0o700); err != nil {
		return nil, errors.New("state directory unavailable")
	}
	if err := source.RejectSymlinkComponents(s.root); err != nil {
		return nil, errors.New("state-root is unsafe")
	}
	if err := os.Chmod(s.root, 0o700); err != nil {
		return nil, errors.New("state directory permissions unavailable")
	}
	path := filepath.Join(s.root, ".registry.lock")
	file, err := os.OpenFile(path, os.O_CREATE|os.O_RDWR, 0o600)
	if err != nil {
		return nil, errors.New("registry lock unavailable")
	}
	if err := syscall.Flock(int(file.Fd()), syscall.LOCK_EX|syscall.LOCK_NB); err != nil {
		file.Close()
		if err == syscall.EWOULDBLOCK || err == syscall.EAGAIN {
			return nil, ErrBusy
		}
		return nil, errors.New("registry lock unavailable")
	}
	return file, nil
}
func unlock(file *os.File) { _ = syscall.Flock(int(file.Fd()), syscall.LOCK_UN); _ = file.Close() }

func (s *Store) readRegistry() (registry, error) {
	path := filepath.Join(s.root, "registry.json")
	data, err := source.ReadBounded(path, RegistryLimit)
	if errors.Is(err, os.ErrNotExist) {
		return emptyRegistry(), nil
	}
	if err != nil {
		return registry{}, errors.New("registry is unavailable or unsafe")
	}
	if codec.ValidateJSON(data, RegistryLimit) != nil {
		return registry{}, errors.New("registry is corrupt")
	}
	var r registry
	if json.Unmarshal(data, &r) != nil || r.SchemaVersion != RegistrySchema || r.Companies == nil || r.Projects == nil || r.Preferences == nil {
		return registry{}, errors.New("registry is corrupt")
	}
	for id, company := range r.Companies {
		if !validID(id) || id != company.ID || !validName(company.Name) {
			return registry{}, errors.New("registry is corrupt")
		}
	}
	for id, project := range r.Projects {
		company, exists := r.Companies[project.CompanyID]
		validFingerprint := len(project.SnapshotFingerprint) == 64
		if validFingerprint {
			_, decodeErr := hex.DecodeString(project.SnapshotFingerprint)
			validFingerprint = decodeErr == nil && strings.ToLower(project.SnapshotFingerprint) == project.SnapshotFingerprint
		}
		stateValid := (project.PreparationState == "ready" && validFingerprint) || (project.PreparationState == "not_ready" && (project.SnapshotFingerprint == "" || validFingerprint))
		if !validID(id) || id != project.ID || !exists || project.Binding == nil || !validName(project.Name) || !stateValid || project.RegisteredAt == "" || validateRegistration(Registration{ProjectID: project.ID, ProjectName: project.Name, CompanyID: company.ID, CompanyName: company.Name, Binding: *project.Binding}) != nil {
			return registry{}, errors.New("registry is corrupt")
		}
		for _, artifact := range project.Artifacts {
			if artifact.ID == "" || (artifact.State != "available" && artifact.State != "pending" && artifact.State != "invalid") {
				return registry{}, errors.New("registry is corrupt")
			}
		}
	}
	for id, preference := range r.Preferences {
		if !validID(id) || id != preference.ProjectID || validBinding(id, preference.Binding) != nil {
			return registry{}, errors.New("registry is corrupt")
		}
	}
	return r, nil
}

func (s *Store) writeRegistry(r registry) error {
	data, err := json.MarshalIndent(r, "", "  ")
	if err != nil || len(data)+1 > RegistryLimit {
		return errors.New("registry metadata limit exceeded")
	}
	return atomicWrite(filepath.Join(s.root, "registry.json"), append(data, '\n'), 0o600)
}

func (s *Store) writeSnapshot(snapshot Snapshot) (string, error) {
	data, err := json.Marshal(snapshot)
	if err != nil || len(data) > SnapshotLimit {
		return "", errors.New("snapshot limit exceeded")
	}
	sum := sha256.Sum256(data)
	fingerprint := hex.EncodeToString(sum[:])
	path := filepath.Join(s.root, "snapshots", fingerprint+".json")
	if err := os.MkdirAll(filepath.Dir(path), 0o700); err != nil {
		return "", errors.New("snapshot directory unavailable")
	}
	if err := source.RejectSymlinkComponents(filepath.Dir(path)); err != nil {
		return "", errors.New("snapshot path is unsafe")
	}
	if _, err := os.Lstat(path); err == nil {
		if _, verifyErr := s.LoadSnapshot(snapshot.ProjectID, snapshot.CompanyID, fingerprint); verifyErr != nil {
			return "", errors.New("existing immutable snapshot failed integrity validation")
		}
		return fingerprint, nil
	}
	if err := atomicWrite(path, data, 0o444); err != nil {
		return "", err
	}
	return fingerprint, nil
}

func atomicWrite(path string, data []byte, mode os.FileMode) error {
	dir := filepath.Dir(path)
	tmp, err := os.CreateTemp(dir, ".builder-project-*.tmp")
	if err != nil {
		return errors.New("safe write failed")
	}
	tmpPath := tmp.Name()
	defer os.Remove(tmpPath)
	if err := tmp.Chmod(mode); err != nil {
		tmp.Close()
		return errors.New("safe write failed")
	}
	if _, err := tmp.Write(data); err != nil {
		tmp.Close()
		return errors.New("safe write failed")
	}
	if err := tmp.Sync(); err != nil {
		tmp.Close()
		return errors.New("safe write failed")
	}
	if err := tmp.Close(); err != nil {
		return errors.New("safe write failed")
	}
	if err := os.Rename(tmpPath, path); err != nil {
		return errors.New("safe write failed")
	}
	if d, err := os.Open(dir); err == nil {
		_ = d.Sync()
		_ = d.Close()
	}
	return nil
}

func emptyRegistry() registry {
	return registry{SchemaVersion: RegistrySchema, Companies: map[string]Company{}, Projects: map[string]Project{}, Preferences: map[string]Preference{}}
}
func validID(id string) bool {
	if len(id) < 1 || len(id) > 64 || id[0] < 'a' || id[0] > 'z' {
		return false
	}
	for _, r := range id {
		if !(r >= 'a' && r <= 'z' || r >= '0' && r <= '9' || r == '-') {
			return false
		}
	}
	return true
}
func validateRegistration(r Registration) error {
	if !validID(r.ProjectID) || !validID(r.CompanyID) || !validName(r.ProjectName) || !validName(r.CompanyName) {
		return errors.New("valid Project and Company identities and bounded names are required")
	}
	return validBinding(r.ProjectID, r.Binding)
}
func validName(name string) bool {
	return strings.TrimSpace(name) != "" && len([]rune(name)) <= 160
}
func validBinding(projectID string, binding Binding) error {
	if !validID(projectID) {
		return errors.New("valid project-id is required")
	}
	if !filepath.IsAbs(binding.WorkspaceRoot) || binding.ProjectRoot == "" || binding.FoundationRoot == "" {
		return errors.New("explicit workspace, Project and Foundation context is required")
	}
	if binding.ProjectRoot != "." && source.ValidateRelativePath(binding.ProjectRoot) != nil {
		return errors.New("Project root must be workspace-relative")
	}
	if err := source.ValidateRelativePath(binding.FoundationRoot); err != nil {
		return errors.New("Foundation root must be workspace-relative")
	}
	if binding.SourceBindingsPath == "" {
		if binding.SourceBindingsDigest != "" {
			return errors.New("source bindings reference is invalid")
		}
	} else {
		digest := strings.TrimPrefix(binding.SourceBindingsDigest, "sha256:")
		_, digestErr := hex.DecodeString(digest)
		if source.ValidateRelativePath(binding.SourceBindingsPath) != nil || len(binding.SourceBindingsDigest) != 71 || !strings.HasPrefix(binding.SourceBindingsDigest, "sha256:") || digestErr != nil || strings.ToLower(digest) != digest {
			return errors.New("source bindings reference is invalid")
		}
	}
	return nil
}
