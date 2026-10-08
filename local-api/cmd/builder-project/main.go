package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

	ac "delphi-local-api/internal/artifact_catalog"
	"delphi-local-api/internal/builder_project"
	"delphi-local-api/internal/source"
)

type args struct {
	stateRoot, workspace, projectRoot, foundationRoot string
	projectID, projectName, companyID, companyName    string
	sourceBindings, defaultOwnerID                    string
	artifactKind, artifactID, ownerLevel              string
}
type response struct {
	SchemaVersion         string                     `json:"schema_version"`
	ProjectID             string                     `json:"project_id,omitempty"`
	ProjectName           string                     `json:"project_name,omitempty"`
	CompanyID             string                     `json:"company_id,omitempty"`
	CompanyName           string                     `json:"company_name,omitempty"`
	RegistrationState     string                     `json:"registration_state,omitempty"`
	ConsumerReadiness     string                     `json:"consumer_readiness,omitempty"`
	Artifacts             []builder_project.Artifact `json:"artifacts,omitempty"`
	CurrentObservations   map[string]json.RawMessage `json:"current_observations,omitempty"`
	SnapshotFingerprint   string                     `json:"snapshot_fingerprint,omitempty"`
	SnapshotObservedAt    string                     `json:"snapshot_observed_at,omitempty"`
	SnapshotObservations  map[string]json.RawMessage `json:"snapshot_observations,omitempty"`
	ObservedAt            string                     `json:"observed_at"`
	NextAction            string                     `json:"next_action"`
	Diagnostic            string                     `json:"diagnostic,omitempty"`
	Catalog               *builder_project.Catalog   `json:"catalog,omitempty"`
	FoundationDestination string                     `json:"foundation_destination,omitempty"`
	FoundationRoot        string                     `json:"foundation_root,omitempty"`
	AuthoringDestination  string                     `json:"authoring_destination,omitempty"`
	SelectedOwnerLevel    string                     `json:"selected_owner_level,omitempty"`
	SelectedOwnerID       string                     `json:"selected_owner_id,omitempty"`
	SourceBindingsPath    string                     `json:"source_bindings_path,omitempty"`
	DefaultOwnerID        string                     `json:"default_owner_id,omitempty"`
}

func main() { os.Exit(run(os.Args[1:], os.Stdout, os.Stderr)) }
func run(argv []string, out, stderr io.Writer) int {
	if len(argv) < 1 {
		return report(stderr, 64, "expected register, status, list, decline, or context")
	}
	action := argv[0]
	argv = argv[1:]
	if action != "register" && action != "status" && action != "list" && action != "decline" && action != "context" && action != "internal-context" {
		return report(stderr, 64, "expected register, status, list, decline, or context")
	}
	a := args{}
	flags := flag.NewFlagSet("builder-project "+action, flag.ContinueOnError)
	flags.SetOutput(io.Discard)
	flags.StringVar(&a.stateRoot, "state-root", "", "explicit absolute shared state directory")
	flags.StringVar(&a.workspace, "workspace-root", "", "explicit absolute workspace root")
	flags.StringVar(&a.projectRoot, "project-root", "", "workspace-relative Project root")
	flags.StringVar(&a.foundationRoot, "foundation-root", "", "workspace-relative Foundation Git root")
	flags.StringVar(&a.projectID, "project-id", "", "stable Project identity")
	if action == "register" {
		flags.StringVar(&a.projectName, "project-name", "", "display name")
		flags.StringVar(&a.companyName, "company-name", "", "display name")
		flags.StringVar(&a.sourceBindings, "source-bindings", "", "optional workspace-relative Design System source bindings")
	}
	if action == "register" || action == "context" || action == "internal-context" || action == "status" {
		flags.StringVar(&a.companyID, "company-id", "", "stable Company identity")
	}
	if action == "context" || action == "internal-context" {
		flags.StringVar(&a.ownerLevel, "owner-level", "project", "Design System authoring owner: project, company, or default")
		flags.StringVar(&a.defaultOwnerID, "default-owner-id", "", "confirmed default source owner identity")
	}
	if action == "register" || action == "status" {
		flags.StringVar(&a.defaultOwnerID, "default-owner-id", "", "confirmed default source owner identity")
	}
	if action == "status" {
		flags.StringVar(&a.artifactKind, "artifact-kind", "", "requested artifact kind: landing, design-system, or prototype")
		flags.StringVar(&a.artifactID, "artifact-id", "", "requested Prototype ID")
	}
	if err := parseFlags(flags, argv); err != nil {
		return report(stderr, 64, err.Error())
	}
	if !filepath.IsAbs(a.stateRoot) {
		return report(stderr, 64, "state-root must be absolute")
	}
	stateRoot := a.stateRoot
	if host := os.Getenv("DELPHI_LOCAL_API_HOST_STATE_ROOT"); host != "" && a.stateRoot == host {
		stateRoot = "/state"
	}
	store, err := builder_project.Open(stateRoot)
	if err != nil {
		return report(stderr, 2, err.Error())
	}
	if action == "list" {
		catalog, e := store.List()
		if e != nil {
			return report(stderr, 2, e.Error())
		}
		return emit(out, response{SchemaVersion: "1", ObservedAt: time.Now().UTC().Format(time.RFC3339Nano), NextAction: "Select a registered Project or register an explicitly confirmed Project.", Catalog: &catalog})
	}
	if a.workspace == "" || a.projectRoot == "" || !validID(a.projectID) {
		return report(stderr, 64, "workspace-root, project-root, and valid project-id are required")
	}
	binding := builder_project.Binding{WorkspaceRoot: a.workspace, ProjectRoot: a.projectRoot, FoundationRoot: a.foundationRoot}
	if action == "register" || action == "status" || action == "context" || action == "internal-context" || action == "decline" {
		p, stored, found, declined, resolveErr := store.ResolveBinding(a.projectID)
		if resolveErr != nil {
			return report(stderr, 2, resolveErr.Error())
		}
		if found || declined {
			if stored.WorkspaceRoot != binding.WorkspaceRoot || stored.ProjectRoot != binding.ProjectRoot {
				return report(stderr, 2, builder_project.ErrConflict.Error())
			}
			binding = stored
			if found && a.companyID != "" && a.companyID != p.CompanyID {
				return report(stderr, 2, builder_project.ErrConflict.Error())
			}
			if a.defaultOwnerID != "" && stored.DefaultOwnerID != "" && a.defaultOwnerID != stored.DefaultOwnerID {
				return report(stderr, 2, builder_project.ErrConflict.Error())
			}
			if found && a.companyID == "" {
				a.companyID = p.CompanyID
			}
		} else if binding.FoundationRoot == "" {
			binding.FoundationRoot = "foundation_documentation"
		}
	}
	if action == "register" && binding.FoundationRoot == "" {
		binding.FoundationRoot = "foundation_documentation"
	}
	if (action == "register" || action == "status" || action == "internal-context") && binding.SourceBindingsPath == "" && a.sourceBindings == "" && a.companyID != "" {
		if err := attachCanonicalSourceBindings(&binding, a.workspace, a.projectID, a.companyID, a.defaultOwnerID); err != nil {
			return report(stderr, 2, err.Error())
		}
	}
	if action == "context" || action == "internal-context" {
		if _, _, _, err := resolveContext(binding); err != nil {
			return report(stderr, 2, err.Error())
		}
		hostWorkspace := binding.WorkspaceRoot
		if host := os.Getenv("DELPHI_LOCAL_API_HOST_WORKSPACE"); host != "" {
			hostWorkspace = host
		}
		destination := filepath.Join(hostWorkspace, filepath.FromSlash(binding.FoundationRoot))
		ownerID := a.projectID
		authoringDestination := filepath.Join(destination, "design", "system")
		if a.ownerLevel != "project" {
			if a.ownerLevel != "company" && a.ownerLevel != "default" {
				return report(stderr, 64, "owner-level must be project, company, or default")
			}
			bindingPath := binding.SourceBindingsPath
			if bindingPath == "" {
				bindingPath = "local-api/source-bindings.json"
			}
			workspaceRoot := binding.WorkspaceRoot
			if host := os.Getenv("DELPHI_LOCAL_API_HOST_WORKSPACE"); host != "" {
				workspaceRoot = "/workspace"
			}
			path, e := source.ContainedPath(workspaceRoot, bindingPath)
			if e != nil {
				return report(stderr, 2, "Design System owner source is unavailable; initialize its API-owned binding through Delphi.")
			}
			data, e := source.ReadBounded(path, ac.MaxSourceBindingsBytes)
			if e != nil {
				return report(stderr, 2, "Design System owner source is unavailable; initialize its API-owned binding through Delphi.")
			}
			bindings, e := ac.DecodeSourceBindings(data)
			if e != nil || bindings.ProjectID != a.projectID || bindings.CompanyID != a.companyID {
				return report(stderr, 2, "Design System owner source does not match the selected Project and Company identities.")
			}
			var selected *ac.SourceBinding
			switch a.ownerLevel {
			case "company":
				selected = bindings.Sources.Company
				ownerID = a.companyID
			case "default":
				selected = bindings.Sources.Default
				if a.defaultOwnerID == "" {
					return report(stderr, 64, "default-owner-id is required when authoring the default Design System")
				}
				ownerID = a.defaultOwnerID
			}
			if selected == nil {
				return report(stderr, 2, "The requested Design System owner has no API-owned source binding.")
			}
			checkout, e := source.ContainedPath(workspaceRoot, selected.CheckoutRoot)
			if e != nil || source.RequireRepositoryRoot(checkout) != nil || selected.DefinitionPath != "design/system/design-system.json" {
				return report(stderr, 2, "The requested Design System source binding is invalid; repair it through Delphi.")
			}
			authoringDestination = filepath.Join(hostWorkspace, filepath.FromSlash(selected.CheckoutRoot), "design", "system")
		}
		result := response{SchemaVersion: "1", ProjectID: a.projectID, CompanyID: a.companyID, FoundationDestination: destination, FoundationRoot: binding.FoundationRoot, AuthoringDestination: authoringDestination, SelectedOwnerLevel: a.ownerLevel, SelectedOwnerID: ownerID, ObservedAt: time.Now().UTC().Format(time.RFC3339Nano), NextAction: "Author within the selected local destination and request fresh artifact status after writing."}
		if action == "internal-context" {
			result.SourceBindingsPath = binding.SourceBindingsPath
			result.DefaultOwnerID = binding.DefaultOwnerID
		}
		return emit(out, result)
	}
	if action == "register" && a.sourceBindings != "" {
		workspace := a.workspace
		if host := os.Getenv("DELPHI_LOCAL_API_HOST_WORKSPACE"); host != "" && workspace == host {
			workspace = "/workspace"
		}
		path, e := source.ContainedPath(workspace, a.sourceBindings)
		if e != nil {
			return report(stderr, 64, "source-bindings must be a safe workspace-relative path")
		}
		data, e := source.ReadBounded(path, ac.MaxSourceBindingsBytes)
		if e != nil {
			return report(stderr, 2, "source bindings are unavailable")
		}
		sum := sha256.Sum256(data)
		binding.SourceBindingsPath = a.sourceBindings
		binding.SourceBindingsDigest = "sha256:" + hex.EncodeToString(sum[:])
		binding.DefaultOwnerID = a.defaultOwnerID
	}
	switch action {
	case "register":
		if _, _, _, err := resolveContext(binding); err != nil {
			return report(stderr, 64, err.Error())
		}
		if err := stateOutsideSource(a.stateRoot, binding); err != nil {
			return report(stderr, 64, err.Error())
		}
		input := builder_project.Registration{ProjectID: a.projectID, ProjectName: a.projectName, CompanyID: a.companyID, CompanyName: a.companyName, Binding: binding}
		var prepared builder_project.Snapshot
		p, saveErr := store.Register(input, func(r builder_project.Registration) (builder_project.Snapshot, error) {
			var e error
			prepared, e = builder_project.Prepare(r, r.Binding.SourceBindingsPath, r.Binding.DefaultOwnerID)
			return prepared, e
		})
		if saveErr != nil {
			if strings.Contains(saveErr.Error(), "preparation failed") {
				return emitCode(out, fromProject(p, "registered", "not_ready", "Registration is saved; retry after correcting the source.", prepared.ObservedAt), 2)
			}
			return report(stderr, 2, saveErr.Error())
		}
		return emit(out, fromProject(p, "registered", "ready", "Select this Company and Project in the local Builder viewer.", prepared.ObservedAt))
	case "status":
		p, found, declined, readErr := store.Status(a.projectID, binding)
		if readErr != nil {
			return report(stderr, 2, readErr.Error())
		}
		current := builder_project.Snapshot{}
		var savedSnapshot *builder_project.Snapshot
		var prepErr error
		checkBinding := binding
		if found {
			checkBinding = *p.Binding
			if p.SnapshotFingerprint != "" {
				if saved, err := store.LoadSnapshot(p.ID, p.CompanyID, p.SnapshotFingerprint); err == nil {
					savedSnapshot = &saved
					current = saved
				}
			}
		}
		if _, _, _, prepErr = resolveContext(checkBinding); prepErr == nil {
			prepErr = stateOutsideSource(a.stateRoot, checkBinding)
		}
		if prepErr == nil && found {
			if err := verifySourceBindingFile(p.Binding); err != nil {
				prepErr = err
			}
		}
		if prepErr == nil && found {
			current, prepErr = builder_project.Prepare(builder_project.Registration{ProjectID: a.projectID, CompanyID: p.CompanyID, Binding: *p.Binding}, p.Binding.SourceBindingsPath, p.Binding.DefaultOwnerID)
		} else if prepErr == nil {
			companyID := a.companyID
			if binding.SourceBindingsPath != "" {
				companyID = a.companyID
			}
			current, prepErr = builder_project.Prepare(builder_project.Registration{ProjectID: a.projectID, CompanyID: companyID, Binding: binding}, binding.SourceBindingsPath, binding.DefaultOwnerID)
		}
		state := "not_registered"
		next := "Review the current artifacts and optionally register this explicitly selected Project."
		if found {
			state = "registered"
			next = "Review current artifact observations; select the registered Project in Builder."
		} else if declined {
			state = "declined"
			next = "The prior refusal is retained; ask only if the owner wants to reconsider."
		}
		resp := response{SchemaVersion: "1", ProjectID: a.projectID, RegistrationState: state, ConsumerReadiness: "not_ready", Artifacts: current.Artifacts, CurrentObservations: current.Observations, ObservedAt: current.ObservedAt, NextAction: next}
		if found {
			if savedSnapshot != nil {
				resp.SnapshotObservedAt = savedSnapshot.ObservedAt
				resp.SnapshotObservations = savedSnapshot.Observations
			}
			resp.ProjectName = p.Name
			resp.CompanyID = p.CompanyID
			resp.SnapshotFingerprint = p.SnapshotFingerprint
			catalog, e := store.List()
			if e != nil {
				return report(stderr, 2, e.Error())
			}
			for _, c := range catalog.Companies {
				if c.ID == p.CompanyID {
					resp.CompanyName = c.Name
				}
			}
			if p.PreparationState == "ready" {
				if _, e := store.LoadSnapshot(p.ID, p.CompanyID, p.SnapshotFingerprint); e == nil {
					resp.ConsumerReadiness = "ready"
				} else {
					resp.Diagnostic = "The last prepared snapshot failed integrity validation."
				}
			}
		}
		if prepErr != nil {
			resp.Diagnostic = "Fresh source observations could not be completed; the last verified saved snapshot is shown when available."
			resp.CurrentObservations = nil
			resp.ObservedAt = time.Now().UTC().Format(time.RFC3339Nano)
			if savedSnapshot != nil {
				resp.Artifacts = savedSnapshot.Artifacts
			}
			return emitCode(out, resp, 2)
		}
		if a.artifactKind != "" {
			if a.artifactKind != "landing" && a.artifactKind != "design-system" && a.artifactKind != "prototype" {
				return report(stderr, 64, "artifact-kind must be landing, design-system, or prototype")
			}
			if a.artifactKind == "prototype" && !validID(a.artifactID) {
				return report(stderr, 64, "prototype status requires a valid artifact-id")
			}
			requestedID := a.artifactKind
			requestedKind := a.artifactKind
			if a.artifactKind == "prototype" {
				requestedID = a.artifactID
			}
			if a.artifactKind == "design-system" {
				requestedKind = "design_system"
			}
			for _, artifact := range current.Artifacts {
				if artifact.ID == requestedID && artifact.Kind == requestedKind {
					if a.artifactKind == "design-system" && artifact.State == "available" {
						if missing := missingRequiredDesignSystemFile(artifact.Files); missing != "" {
							artifact.State = "invalid"
							artifact.Diagnostic = "required standard Design System file is missing: " + missing
						}
					}
					resp.Artifacts = []builder_project.Artifact{artifact}
					if artifact.State == "available" {
						resp.NextAction = "The requested artifact passes current structural integrity checks; visual fidelity, behavior, freshness, and human review remain separate."
						return emit(out, resp)
					}
					resp.Diagnostic = artifact.Diagnostic
					resp.NextAction = "Complete the requested artifact at its standard location, then request fresh status again."
					return emitCode(out, resp, 2)
				}
			}
			resp.Artifacts = []builder_project.Artifact{{ID: requestedID, Kind: a.artifactKind, Name: requestedID, State: "pending", Diagnostic: "requested artifact is absent from the accepted inventory"}}
			resp.NextAction = "Create the requested artifact at its standard location, then request fresh status again."
			return emitCode(out, resp, 2)
		}
		if found && resp.ConsumerReadiness != "ready" {
			return emitCode(out, resp, 2)
		}
		return emit(out, resp)
	case "decline":
		if _, _, _, err := resolveContext(binding); err != nil {
			return report(stderr, 64, err.Error())
		}
		if err := stateOutsideSource(a.stateRoot, binding); err != nil {
			return report(stderr, 64, err.Error())
		}
		if err := store.Decline(a.projectID, binding); err != nil {
			return report(stderr, 2, err.Error())
		}
		return emit(out, response{SchemaVersion: "1", ProjectID: a.projectID, RegistrationState: "declined", ConsumerReadiness: "not_ready", ObservedAt: time.Now().UTC().Format(time.RFC3339Nano), NextAction: "Optional Builder integration was declined for this Project context."})
	}
	return report(stderr, 64, "invalid operation")
}

func fromProject(p builder_project.Project, state, readiness, next, observedAt string) response {
	return response{SchemaVersion: "1", ProjectID: p.ID, ProjectName: p.Name, CompanyID: p.CompanyID, RegistrationState: state, ConsumerReadiness: readiness, Artifacts: p.Artifacts, SnapshotFingerprint: p.SnapshotFingerprint, ObservedAt: observedAt, NextAction: next}
}
func emit(w io.Writer, r response) int { return emitCode(w, r, 0) }
func emitCode(w io.Writer, r response, code int) int {
	data, err := json.MarshalIndent(r, "", "  ")
	if err != nil {
		return 70
	}
	data = append(data, '\n')
	if _, err = w.Write(data); err != nil {
		return 70
	}
	return code
}
func report(w io.Writer, code int, message string) int {
	fmt.Fprintln(w, "builder-project:", message)
	return code
}
func missingRequiredDesignSystemFile(files []string) string {
	for _, required := range []string{"design/system/guide.md", "design/system/examples.html"} {
		found := false
		for _, path := range files {
			if path == required {
				found = true
				break
			}
		}
		if !found {
			return required
		}
	}
	return ""
}
func parseFlags(f *flag.FlagSet, args []string) error {
	seen := map[string]bool{}
	for _, arg := range args {
		if arg == "--" {
			break
		}
		if !strings.HasPrefix(arg, "-") || arg == "-" {
			continue
		}
		name := strings.TrimLeft(strings.SplitN(arg, "=", 2)[0], "-")
		if seen[name] {
			return errors.New("duplicate option")
		}
		seen[name] = true
	}
	if err := f.Parse(args); err != nil || f.NArg() != 0 {
		return errors.New("invalid arguments")
	}
	return nil
}
func validID(value string) bool {
	if len(value) < 1 || len(value) > 64 || value[0] < 'a' || value[0] > 'z' {
		return false
	}
	for _, r := range value {
		if !(r >= 'a' && r <= 'z' || r >= '0' && r <= '9' || r == '-') {
			return false
		}
	}
	return true
}
func resolveContext(b builder_project.Binding) (string, string, string, error) {
	root := b.WorkspaceRoot
	if host := os.Getenv("DELPHI_LOCAL_API_HOST_WORKSPACE"); host != "" {
		if root != host {
			return "", "", "", errors.New("workspace-root does not match launcher-selected workspace")
		}
		root = "/workspace"
	}
	if !filepath.IsAbs(root) || source.RejectSymlinkComponents(root) != nil {
		return "", "", "", errors.New("workspace-root is unsafe")
	}
	project := root
	var e error
	if b.ProjectRoot != "." {
		project, e = source.ContainedPath(root, b.ProjectRoot)
		if e != nil {
			return "", "", "", errors.New("project-root is unsafe")
		}
	}
	foundation, e := source.ContainedPath(root, b.FoundationRoot)
	if e != nil {
		return "", "", "", errors.New("foundation-root is unsafe")
	}
	for _, p := range []string{project, foundation} {
		i, e := os.Stat(p)
		if e != nil || !i.IsDir() {
			return "", "", "", errors.New("selected source directory unavailable")
		}
	}
	if source.RequireRepositoryRoot(foundation) != nil {
		return "", "", "", errors.New("Foundation must be its Git checkout root")
	}
	return root, project, foundation, nil
}
func stateOutsideSource(state string, b builder_project.Binding) error {
	hostState := os.Getenv("DELPHI_LOCAL_API_HOST_STATE_ROOT")
	if hostState != "" && state == "/state" {
		state = hostState
	}
	root := b.WorkspaceRoot
	for _, relative := range []string{b.ProjectRoot, b.FoundationRoot} {
		sourcePath := filepath.Clean(root)
		if relative != "." {
			sourcePath = filepath.Join(root, filepath.FromSlash(relative))
		}
		a, _ := filepath.Abs(state)
		s, _ := filepath.Abs(sourcePath)
		if a == s || strings.HasPrefix(a, s+string(os.PathSeparator)) {
			return errors.New("state-root must be outside selected Project and Foundation checkouts")
		}
	}
	return nil
}
func verifySourceBindingFile(binding *builder_project.Binding) error {
	if binding == nil || binding.SourceBindingsPath == "" {
		return nil
	}
	root := binding.WorkspaceRoot
	if host := os.Getenv("DELPHI_LOCAL_API_HOST_WORKSPACE"); host != "" && root == host {
		root = "/workspace"
	}
	path, err := source.ContainedPath(root, binding.SourceBindingsPath)
	if err != nil {
		return builder_project.ErrConflict
	}
	data, err := source.ReadBounded(path, ac.MaxSourceBindingsBytes)
	if err != nil {
		return builder_project.ErrConflict
	}
	sum := sha256.Sum256(data)
	if "sha256:"+hex.EncodeToString(sum[:]) != binding.SourceBindingsDigest {
		return builder_project.ErrConflict
	}
	return nil
}

func attachCanonicalSourceBindings(binding *builder_project.Binding, workspace, projectID, companyID, defaultOwnerID string) error {
	if host := os.Getenv("DELPHI_LOCAL_API_HOST_WORKSPACE"); host != "" && workspace == host {
		workspace = "/workspace"
	}
	relative := "local-api/source-bindings.json"
	if err := source.RejectSymlinkComponents(filepath.Join(workspace, "local-api")); err != nil {
		return errors.New("configured Design System source bindings are unsafe; repair them through Delphi.")
	}
	full := filepath.Join(workspace, filepath.FromSlash(relative))
	if _, err := os.Lstat(full); os.IsNotExist(err) {
		return nil
	} else if err != nil {
		return errors.New("configured Design System source bindings are unavailable; repair them through Delphi.")
	}
	path, err := source.ContainedPath(workspace, relative)
	if err != nil {
		return errors.New("configured Design System source bindings are unsafe; repair them through Delphi.")
	}
	data, err := source.ReadBounded(path, ac.MaxSourceBindingsBytes)
	if err != nil {
		return errors.New("configured Design System source bindings are unreadable; repair them through Delphi.")
	}
	decoded, err := ac.DecodeSourceBindings(data)
	if err != nil || decoded.ProjectID != projectID || decoded.CompanyID != companyID {
		return errors.New("configured Design System source bindings do not match the selected Project and Company identities.")
	}
	sum := sha256.Sum256(data)
	binding.SourceBindingsPath = relative
	binding.SourceBindingsDigest = "sha256:" + hex.EncodeToString(sum[:])
	if decoded.Sources.Default != nil {
		binding.DefaultOwnerID = defaultOwnerID
	}
	return nil
}
