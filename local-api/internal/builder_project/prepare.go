package builder_project

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	ac "delphi-local-api/internal/artifact_catalog"
	"delphi-local-api/internal/source"
)

const maxPreparedBytes = 24 << 20

type prepContext struct {
	Binding        Binding
	ProjectID      string
	CompanyID      string
	SourceBindings string
	DefaultOwnerID string
}

func Prepare(r Registration, sourceBindings, defaultOwner string) (Snapshot, error) {
	return prepare(prepContext{Binding: r.Binding, ProjectID: r.ProjectID, CompanyID: r.CompanyID, SourceBindings: sourceBindings, DefaultOwnerID: defaultOwner})
}

func prepare(c prepContext) (Snapshot, error) {
	snapshot := Snapshot{SchemaVersion: SnapshotSchema, ProjectID: c.ProjectID, CompanyID: c.CompanyID, ObservedAt: time.Now().UTC().Format(time.RFC3339Nano), Files: map[string][]byte{}, Artifacts: []Artifact{}, Observations: map[string]json.RawMessage{}}
	workspace, project, foundation, err := resolveSourceContext(c.Binding)
	if err != nil {
		return snapshot, err
	}
	common := []string{"--workspace-root", c.Binding.WorkspaceRoot, "--project-root", c.Binding.ProjectRoot, "--foundation-root", c.Binding.FoundationRoot, "--project-id", c.ProjectID}
	knowledge, knowledgeCode, err := runEvaluator("knowledge-status", append([]string{"status"}, common...))
	if err != nil || knowledgeCode != 0 {
		return snapshot, errors.New("knowledge source observation failed")
	}
	snapshot.Observations["knowledge_status"] = append(json.RawMessage(nil), knowledge...)
	var designObservation []byte
	artifact, addErr := addLanding(snapshot.Files, foundation, c.ProjectID, c.CompanyID)
	if addErr != nil {
		artifact = Artifact{ID: "landing", Kind: "landing", Name: "Landing", State: "invalid", Diagnostic: "declared Landing artifact is invalid"}
	}
	snapshot.Artifacts = append(snapshot.Artifacts, artifact)
	prototype, prototypeCode, prototypeErr := runEvaluator("artifact-status", append([]string{"prototypes"}, append(common, "--mode", "working-tree")...))
	if prototypeErr != nil {
		return snapshot, errors.New("Prototype source evaluator failed")
	}
	if prototypeCode != 0 {
		state := "pending"
		if _, statErr := os.Lstat(filepath.Join(foundation, "prototypes", "catalog.json")); statErr == nil {
			state = "invalid"
		}
		snapshot.Artifacts = append(snapshot.Artifacts, Artifact{ID: "prototypes", Kind: "prototype_collection", Name: "Prototype", State: state, Diagnostic: "Prototype catalog is unavailable or invalid"})
	} else {
		snapshot.Observations["prototype_status"] = append(json.RawMessage(nil), prototype...)
		artifacts, addErr := addPrototypeFiles(snapshot.Files, foundation, c.ProjectID, prototype)
		if addErr != nil {
			snapshot.Artifacts = append(snapshot.Artifacts, Artifact{ID: "prototypes", Kind: "prototype_collection", Name: "Prototype", State: "invalid", Diagnostic: "declared Prototype inventory is invalid"})
		} else {
			snapshot.Artifacts = append(snapshot.Artifacts, artifacts...)
		}
	}
	standardProject := c.SourceBindings == ""
	args := append([]string{"design-system"}, common...)
	args = append(args, "--company-id", c.CompanyID)
	if !standardProject {
		args = append(args, "--source-bindings", c.SourceBindings)
	}
	args = append(args, "--mode", "working-tree")
	if c.DefaultOwnerID != "" {
		args = append(args, "--default-owner-id", c.DefaultOwnerID)
	}
	design, code, runErr := runEvaluator("artifact-status", args)
	if runErr != nil {
		return snapshot, errors.New("Design System source evaluator failed")
	}
	if code != 0 {
		snapshot.Artifacts = append(snapshot.Artifacts, Artifact{ID: "design-system", Kind: "design_system", Name: "Design System", State: "invalid", Diagnostic: "Design System source is unavailable or invalid"})
	} else {
		designObservation = append([]byte(nil), design...)
		snapshot.Observations["design_system_status"] = append(json.RawMessage(nil), design...)
		var bindingBytes []byte
		if standardProject {
			bindingBytes, err = json.Marshal(ac.StandardProjectBindings(c.ProjectID, c.CompanyID, c.Binding.FoundationRoot))
		} else {
			var bindingPath string
			bindingPath, err = source.ContainedPath(workspace, c.SourceBindings)
			if err == nil {
				bindingBytes, err = source.ReadBounded(bindingPath, ac.MaxSourceBindingsBytes)
			}
		}
		var artifact Artifact
		if err == nil {
			artifact, err = addDesignSystemFilesWithBindings(snapshot.Files, workspace, bindingBytes, design)
		}
		if err != nil {
			artifact = Artifact{ID: "design-system", Kind: "design_system", Name: "Design System", State: "invalid", Diagnostic: "declared Design System inventory is invalid"}
		}
		snapshot.Artifacts = append(snapshot.Artifacts, artifact)
	}
	snapshot.Observations["visual_origin"] = visualOriginObservation(foundation, knowledge, designObservation)
	if c.Binding.SourceBindingsPath != "" {
		full, e := source.ContainedPath(workspace, c.Binding.SourceBindingsPath)
		if e != nil {
			return snapshot, errors.New("source bindings changed during preparation")
		}
		current, e := source.ReadBounded(full, ac.MaxSourceBindingsBytes)
		if e != nil {
			return snapshot, errors.New("source bindings changed during preparation")
		}
		sum := sha256.Sum256(current)
		if "sha256:"+hex.EncodeToString(sum[:]) != c.Binding.SourceBindingsDigest {
			return snapshot, errors.New("source bindings changed during preparation")
		}
	}
	if err := enforceSnapshotBounds(snapshot.Files); err != nil {
		return snapshot, err
	}
	_ = workspace
	_ = project
	return snapshot, nil
}

const knowledgeSourceEncoding = "sha256-sorted-binary-records-v1-no-domain-prefix; each UTF-8 path is prefixed by a 4-byte big-endian byte length and followed by the raw 32-byte SHA-256 content digest"
const roadmapSourceEncoding = "sha256-sorted-binary-path-records-v1-no-domain-prefix; each UTF-8 path is prefixed by a 4-byte big-endian byte length"
const designSystemEncoding = "builder-artifact-inventory-v1"

func visualOriginObservation(foundation string, knowledge, design []byte) json.RawMessage {
	type target struct {
		ObservedSourceDigest *string `json:"observed_source_digest"`
	}
	var k struct {
		Landing target `json:"landing"`
		Roadmap target `json:"roadmap"`
	}
	_ = json.Unmarshal(knowledge, &k)
	var d struct {
		InventoryDigest *string `json:"inventory_digest"`
	}
	_ = json.Unmarshal(design, &d)
	var manifest struct {
		Visual struct {
			GeneratedAt string `json:"generated_at_utc"`
			Generator   string `json:"generator"`
			Origin      struct {
				HeadCommit        string `json:"head_commit"`
				SourceTree        string `json:"source_tree"`
				KnowledgeDigest   string `json:"knowledge_source_digest"`
				KnowledgeEncoding string `json:"knowledge_source_encoding"`
				RoadmapDigest     string `json:"roadmap_source_digest"`
				RoadmapEncoding   string `json:"roadmap_source_encoding"`
				LegacyEncoding    string `json:"legacy_source_snapshot_encoding"`
			} `json:"foundation_origin"`
			DS struct {
				RepositoryID      string `json:"repository_id"`
				InventoryDigest   string `json:"inventory_digest"`
				InventoryEncoding string `json:"inventory_encoding"`
			} `json:"design_system_origin"`
		} `json:"local_visual_artifact"`
	}
	result := map[string]any{"state": "unverifiable", "knowledge_source_state": "unverifiable", "roadmap_source_state": "unverifiable", "design_system_state": "unverifiable"}
	data, err := source.ReadBounded(filepath.Join(foundation, "project_landing.manifest.json"), 2<<20)
	if err != nil || json.Unmarshal(data, &manifest) != nil {
		return marshalObservation(result)
	}
	origin := manifest.Visual.Origin
	knowledgeState := compareOriginDigest(origin.KnowledgeEncoding, knowledgeSourceEncoding, origin.KnowledgeDigest, k.Landing.ObservedSourceDigest)
	roadmapState := compareOriginDigest(origin.RoadmapEncoding, roadmapSourceEncoding, origin.RoadmapDigest, k.Roadmap.ObservedSourceDigest)
	designState := compareOriginDigest(manifest.Visual.DS.InventoryEncoding, designSystemEncoding, manifest.Visual.DS.InventoryDigest, d.InventoryDigest)
	state := "unverifiable"
	if knowledgeState == "mismatch" || roadmapState == "mismatch" || designState == "mismatch" {
		state = "mismatch"
	} else if knowledgeState == "matching" && roadmapState == "matching" && designState == "matching" {
		state = "matching"
	}
	return marshalObservation(map[string]any{"state": state, "knowledge_source_state": knowledgeState, "roadmap_source_state": roadmapState, "design_system_state": designState, "generated_at_utc": manifest.Visual.GeneratedAt, "generator": manifest.Visual.Generator, "foundation_head_commit": origin.HeadCommit, "foundation_source_tree": origin.SourceTree, "legacy_source_snapshot_encoding": origin.LegacyEncoding, "design_system_repository_id": manifest.Visual.DS.RepositoryID})
}

func compareOriginDigest(declaredEncoding, supportedEncoding, declaredDigest string, observed *string) string {
	if declaredEncoding != supportedEncoding || observed == nil || !isSHA256Digest(declaredDigest) || !isSHA256Digest(*observed) {
		return "unverifiable"
	}
	if declaredDigest == *observed {
		return "matching"
	}
	return "mismatch"
}

func isSHA256Digest(value string) bool {
	if len(value) != 71 || !strings.HasPrefix(value, "sha256:") {
		return false
	}
	decoded, err := hex.DecodeString(strings.TrimPrefix(value, "sha256:"))
	return err == nil && hex.EncodeToString(decoded) == strings.TrimPrefix(value, "sha256:")
}

func marshalObservation(value any) json.RawMessage { data, _ := json.Marshal(value); return data }

func runEvaluator(name string, args []string) ([]byte, int, error) {
	binDir := os.Getenv("DELPHI_LOCAL_API_BIN_DIR")
	if binDir == "" {
		return nil, 70, errors.New("local evaluator binaries are unavailable")
	}
	bin := filepath.Join(binDir, name)
	cmd := exec.Command(bin, args...)
	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err == nil {
		return stdout.Bytes(), 0, nil
	}
	var exit *exec.ExitError
	if errors.As(err, &exit) {
		if exit.ExitCode() == 2 {
			return stdout.Bytes(), 2, nil
		}
		return nil, exit.ExitCode(), errors.New("local evaluator returned an invocation or infrastructure failure")
	}
	return nil, 70, errors.New("local evaluator could not run")
}

func resolveSourceContext(b Binding) (string, string, string, error) {
	if !filepath.IsAbs(b.WorkspaceRoot) {
		return "", "", "", errors.New("workspace-root must be absolute")
	}
	root, err := filepath.Abs(b.WorkspaceRoot)
	if err != nil || source.RejectSymlinkComponents(root) != nil {
		return "", "", "", errors.New("workspace-root is unsafe")
	}
	if host := os.Getenv("DELPHI_LOCAL_API_HOST_WORKSPACE"); host != "" {
		if root != host {
			return "", "", "", errors.New("workspace-root does not match selected workspace")
		}
		root = "/workspace"
	}
	if err := source.RejectSymlinkComponents(root); err != nil {
		return "", "", "", errors.New("workspace-root is unsafe")
	}
	project := root
	if b.ProjectRoot != "." {
		project, err = source.ContainedPath(root, b.ProjectRoot)
		if err != nil {
			return "", "", "", errors.New("Project root is unsafe")
		}
	}
	foundation, err := source.ContainedPath(root, b.FoundationRoot)
	if err != nil {
		return "", "", "", errors.New("Foundation root is unsafe")
	}
	for _, path := range []string{project, foundation} {
		info, e := os.Stat(path)
		if e != nil || !info.IsDir() {
			return "", "", "", errors.New("selected Project or Foundation is unavailable")
		}
	}
	if source.RequireRepositoryRoot(foundation) != nil {
		return "", "", "", errors.New("Foundation is not a Git checkout root")
	}
	return root, project, foundation, nil
}

func addLanding(files map[string][]byte, foundation, projectID, companyID string) (Artifact, error) {
	manifestPath := filepath.Join(foundation, "project_landing.manifest.json")
	data, err := source.ReadBounded(manifestPath, 2<<20)
	if errors.Is(err, os.ErrNotExist) {
		return Artifact{ID: "landing", Kind: "landing", Name: "Landing", State: "pending"}, nil
	}
	if err != nil {
		return Artifact{}, err
	}
	var manifest struct {
		Visual struct {
			Path      string `json:"path"`
			ProjectID string `json:"project_id"`
			CompanyID string `json:"company_id"`
			Files     []struct {
				Path   string `json:"path"`
				Digest string `json:"content_digest"`
			} `json:"artifact_files"`
		} `json:"local_visual_artifact"`
	}
	if json.Unmarshal(data, &manifest) != nil || manifest.Visual.Path != "design/landing/index.html" || len(manifest.Visual.Files) == 0 || manifest.Visual.ProjectID != projectID || (companyID != "" && manifest.Visual.CompanyID != companyID) {
		return Artifact{}, errors.New("invalid Landing manifest")
	}
	entry := manifest.Visual.Path
	if source.ValidateRelativePath(entry) != nil || !strings.HasPrefix(entry, "design/landing/") {
		return Artifact{}, errors.New("unsafe Landing entry")
	}
	paths := make([]string, 0, len(manifest.Visual.Files))
	admitted := map[string][]byte{}
	for _, row := range manifest.Visual.Files {
		managedFile := strings.HasPrefix(row.Path, "design/landing/")
		if source.ValidateRelativePath(row.Path) != nil || (!managedFile && !isCanonicalLandingEvidence(row.Path)) || !strings.HasPrefix(row.Digest, "sha256:") {
			return Artifact{}, errors.New("invalid Landing file reference")
		}
		if _, duplicate := admitted[row.Path]; duplicate {
			return Artifact{}, errors.New("duplicate Landing file reference")
		}
		content, e := readSource(foundation, row.Path)
		if e != nil {
			return Artifact{}, e
		}
		sum := sha256.Sum256(content)
		if "sha256:"+hex.EncodeToString(sum[:]) != row.Digest {
			return Artifact{}, errors.New("Landing file digest mismatch")
		}
		admitted[row.Path] = content
		paths = append(paths, row.Path)
	}
	if _, ok := admitted[entry]; !ok {
		return Artifact{}, errors.New("Landing entry is not admitted")
	}
	if _, ok := admitted["project_landing.md"]; !ok {
		return Artifact{}, errors.New("Landing manifest must admit canonical project_landing.md")
	}
	for path, content := range admitted {
		files[path] = content
	}
	return Artifact{ID: "landing", Kind: "landing", Name: "Landing", State: "available", Entry: entry, Files: paths}, nil
}

func isCanonicalLandingEvidence(path string) bool {
	switch path {
	case "domain_entities.md", "project_constitution.md", "project_landing.md", "project_mandate.md", "system_roadmap.md":
		return true
	default:
		return false
	}
}

func addPrototypeFiles(files map[string][]byte, foundation, projectID string, result []byte) ([]Artifact, error) {
	var response ac.Response
	if json.Unmarshal(result, &response) != nil || response.Outcome != "go" || response.InventoryDigest == nil {
		return nil, errors.New("invalid Prototype evaluator response")
	}
	catalogBytes, err := readSource(foundation, "prototypes/catalog.json")
	if err != nil {
		return nil, err
	}
	var catalog ac.Catalog
	if ac.DecodeStrict(catalogBytes, &catalog) != nil {
		return nil, errors.New("invalid admitted Prototype catalog")
	}
	admitted := map[string][]byte{"prototypes/catalog.json": catalogBytes}
	records := []ac.DigestRecord{{SourceID: projectID, Path: "prototypes/catalog.json", Content: catalogBytes}}
	artifacts := make([]Artifact, 0, len(response.Items))
	for _, item := range response.Items {
		var prototype *ac.Prototype
		for i := range catalog.Prototypes {
			if catalog.Prototypes[i].ID == item.ID {
				prototype = &catalog.Prototypes[i]
				break
			}
		}
		if prototype == nil {
			return nil, errors.New("evaluator item is absent from Prototype catalog")
		}
		manifestPath := prototype.Root + "/prototype.json"
		manifestBytes, e := readSource(foundation, manifestPath)
		if e != nil {
			return nil, e
		}
		var manifest ac.Manifest
		if ac.DecodeStrict(manifestBytes, &manifest) != nil {
			return nil, errors.New("invalid admitted Prototype manifest")
		}
		paths := []string{manifestPath}
		artifactFiles := map[string][]byte{manifestPath: manifestBytes}
		records = append(records, ac.DigestRecord{SourceID: projectID, Path: manifestPath, Content: manifestBytes})
		for _, relative := range append(append([]string{}, manifest.Sources...), manifest.Assets...) {
			path := prototype.Root + "/" + relative
			data, e := readSource(foundation, path)
			if e != nil {
				return nil, e
			}
			if _, exists := artifactFiles[path]; exists {
				continue
			}
			artifactFiles[path] = data
			paths = append(paths, path)
			records = append(records, ac.DigestRecord{SourceID: projectID, Path: path, Content: data})
		}
		for _, related := range manifest.Related {
			if !approvedPrototypeRelatedPath(related.Kind, related.Path) {
				return nil, errors.New("invalid Prototype evidence reference")
			}
			if _, exists := artifactFiles[related.Path]; exists {
				continue
			}
			data, e := readSource(foundation, related.Path)
			if e != nil {
				return nil, errors.New("declared Prototype evidence is unavailable")
			}
			artifactFiles[related.Path] = data
			paths = append(paths, related.Path)
		}
		for path, data := range artifactFiles {
			admitted[path] = data
		}
		entry := prototype.Root + "/" + manifest.EntryPoint
		artifacts = append(artifacts, Artifact{ID: item.ID, Kind: "prototype", Name: item.Name, State: "available", Entry: entry, Files: paths})
	}
	digest, e := ac.InventoryDigest(projectID, records)
	if e != nil || digest != *response.InventoryDigest {
		return nil, errors.New("Prototype admitted inventory fingerprint mismatch")
	}
	for path, data := range admitted {
		files[path] = data
	}
	if len(artifacts) == 0 {
		return []Artifact{{ID: "prototypes", Kind: "prototype_collection", Name: "Prototype", State: "pending"}}, nil
	}
	return artifacts, nil
}

func approvedPrototypeRelatedPath(kind, value string) bool {
	if (kind != "todo" && kind != "decision" && kind != "documentation") || source.ValidateRelativePath(value) != nil {
		return false
	}
	segments := strings.Split(value, "/")
	for _, segment := range segments {
		lower := strings.ToLower(segment)
		if strings.HasPrefix(segment, ".") || lower == "tmp" || lower == "temp" || lower == "generated" || lower == "ephemeral" {
			return false
		}
	}
	ext := strings.ToLower(filepath.Ext(value))
	if ext != ".md" && ext != ".markdown" {
		return false
	}
	if len(segments) == 1 {
		base := strings.TrimSuffix(segments[0], filepath.Ext(segments[0]))
		switch base {
		case "domain_entities", "project_constitution", "project_landing", "project_mandate", "system_roadmap":
			return true
		default:
			return false
		}
	}
	switch segments[0] {
	case "modules", "policies", "todos":
		return true
	default:
		return false
	}
}

func addDesignSystemFiles(files map[string][]byte, workspace, bindingsPath string, result []byte) (Artifact, error) {
	bindingsFull, err := source.ContainedPath(workspace, bindingsPath)
	if err != nil {
		return Artifact{}, err
	}
	bindingsBytes, err := source.ReadBounded(bindingsFull, ac.MaxSourceBindingsBytes)
	if err != nil {
		return Artifact{}, err
	}
	return addDesignSystemFilesWithBindings(files, workspace, bindingsBytes, result)
}

func addDesignSystemFilesWithBindings(files map[string][]byte, workspace string, bindingsBytes, result []byte) (Artifact, error) {
	bindings, err := ac.DecodeSourceBindings(bindingsBytes)
	if err != nil {
		return Artifact{}, err
	}
	level, binding := ac.SelectSourceBinding(bindings)
	if binding == nil {
		return Artifact{}, errors.New("no selected Design System source")
	}
	checkout, err := source.ContainedPath(workspace, binding.CheckoutRoot)
	if err != nil {
		return Artifact{}, err
	}
	if source.RequireRepositoryRoot(checkout) != nil {
		return Artifact{}, errors.New("selected Design System source is not a Git checkout root")
	}
	selected, err := source.NewWorkingTree(checkout)
	if err != nil {
		return Artifact{}, err
	}
	var response ac.DesignSystemResponse
	if json.Unmarshal(result, &response) != nil || response.Outcome != "go" || response.InventoryDigest == nil || len(response.Items) != 1 || response.Source == nil || response.SelectedLevel == nil || *response.SelectedLevel != level {
		return Artifact{}, errors.New("invalid Design System evaluator response")
	}
	definitionBytes, mode, err := selected.Read(binding.DefinitionPath, ac.MaxManifestBytes)
	if err != nil || mode != source.ModeRegular {
		return Artifact{}, errors.New("selected Design System definition is unavailable")
	}
	var definition ac.DesignSystemDefinition
	if ac.DecodeStrict(definitionBytes, &definition) != nil {
		return Artifact{}, errors.New("invalid admitted Design System definition")
	}
	root := strings.TrimSuffix(strings.TrimSuffix(binding.DefinitionPath, "design-system.json"), "/")
	virtualPaths := []string{"design/system/design-system.json"}
	virtual := map[string][]byte{"design/system/design-system.json": definitionBytes}
	records := []ac.DigestRecord{{SourceID: binding.RepositoryID, Path: binding.DefinitionPath, Content: definitionBytes}}
	declared := []string{}
	seen := map[string]bool{}
	var entry string
	addDeclared := func(p string) {
		if p != "" && !seen[p] {
			seen[p] = true
			declared = append(declared, p)
		}
	}
	for _, component := range definition.Components {
		addDeclared(component.Documentation)
		for _, example := range component.Examples {
			addDeclared(example)
			if entry == "" && strings.HasSuffix(example, ".html") {
				entry = "design/system/" + example
			}
		}
	}
	for _, asset := range definition.Assets {
		addDeclared(asset)
	}
	for _, relative := range declared {
		path := relative
		if root != "" {
			path = root + "/" + relative
		}
		content, mode, e := selected.Read(path, ac.MaxFileBytes)
		if e != nil || mode != source.ModeRegular {
			return Artifact{}, errors.New("selected Design System support file is unavailable")
		}
		virtualPath := "design/system/" + relative
		if source.ValidateRelativePath(virtualPath) != nil {
			return Artifact{}, errors.New("selected Design System support path is unsafe")
		}
		virtual[virtualPath] = content
		virtualPaths = append(virtualPaths, virtualPath)
		records = append(records, ac.DigestRecord{SourceID: binding.RepositoryID, Path: path, Content: content})
	}
	digest, e := ac.InventoryDigest(binding.RepositoryID, records)
	if e != nil || digest != *response.InventoryDigest {
		return Artifact{}, errors.New("Design System admitted inventory fingerprint mismatch")
	}
	if entry == "" {
		return Artifact{ID: "design-system", Kind: "design_system", Name: definition.Name, State: "pending", Diagnostic: "No declared HTML example is available for display."}, nil
	}
	for path, data := range virtual {
		files[path] = data
	}
	return Artifact{ID: "design-system", Kind: "design_system", Name: definition.Name, State: "available", Entry: entry, Files: virtualPaths}, nil
}

func readSource(root, path string) ([]byte, error) {
	full, err := source.ContainedPath(root, path)
	if err != nil {
		return nil, err
	}
	data, err := source.ReadBounded(full, 2<<20)
	if err != nil {
		return nil, err
	}
	return data, nil
}
func enforceSnapshotBounds(files map[string][]byte) error {
	total := 0
	for path, data := range files {
		if source.ValidateRelativePath(path) != nil || len(data) > 2<<20 {
			return errors.New("snapshot contains an unsafe or oversized file")
		}
		total += len(data)
		if total > maxPreparedBytes {
			return errors.New("snapshot content limit exceeded")
		}
	}
	return nil
}
