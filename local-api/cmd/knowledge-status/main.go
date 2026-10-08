package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	ks "delphi-local-api/internal/knowledge_status"
	"delphi-local-api/internal/source"
)

const markerName = "knowledge_review.manifest.json"

func main() { os.Exit(run(os.Args[1:], os.Stdout, os.Stderr)) }

type cliError struct {
	code int
	err  error
}

func (e *cliError) Error() string    { return e.err.Error() }
func invalid(err error) error        { return &cliError{code: 64, err: err} }
func infrastructure(err error) error { return &cliError{code: 70, err: err} }

func run(args []string, stdout, stderr io.Writer) int {
	if len(args) < 1 {
		fmt.Fprintln(stderr, "knowledge-status: expected status, review-packet, or record-review")
		return 64
	}
	var err error
	switch args[0] {
	case "status":
		err = runStatus(args[1:], stdout)
	case "review-packet":
		err = runPacket(args[1:], stdout)
	case "record-review":
		err = runRecord(args[1:])
	default:
		fmt.Fprintln(stderr, "knowledge-status: expected status, review-packet, or record-review")
		return 64
	}
	if err == nil {
		return 0
	}
	code := 2
	var typed *cliError
	if errors.As(err, &typed) {
		code = typed.code
	}
	if code != 2 {
		fmt.Fprintln(stderr, "knowledge-status:", err.Error())
	}
	return code
}

func roots(flags *flag.FlagSet) (*string, *string, *string, *string) {
	workspace := flags.String("workspace-root", "", "explicit absolute workspace root")
	project := flags.String("project-root", "", "workspace-relative Project root")
	foundation := flags.String("foundation-root", "", "workspace-relative Foundation Git checkout")
	projectID := flags.String("project-id", "", "explicit Project identity")
	return workspace, project, foundation, projectID
}

func parseCommon(flags *flag.FlagSet, args []string, workspace, project, foundation, projectID *string) (string, error) {
	flags.SetOutput(io.Discard)
	if err := rejectDuplicateFlags(args); err != nil {
		return "", invalid(err)
	}
	if err := flags.Parse(args); err != nil || flags.NArg() != 0 {
		if err == nil {
			err = errors.New("unexpected positional arguments")
		}
		return "", invalid(errors.New("invalid arguments"))
	}
	if *workspace == "" || *project == "" || *foundation == "" || !validIdentity(*projectID) {
		return "", invalid(errors.New("workspace-root, project-root, foundation-root, and project-id are required"))
	}
	root, err := resolveContext(*workspace, *project, *foundation)
	if err != nil {
		return "", err
	}
	if err := source.RequireRepositoryRoot(root); err != nil {
		return "", errors.New("selected Foundation is not an available Git checkout root")
	}
	return root, nil
}

func runStatus(args []string, stdout io.Writer) error {
	flags := flag.NewFlagSet("status", flag.ContinueOnError)
	workspace, project, foundation, projectID := roots(flags)
	foundationRoot, err := parseCommon(flags, args, workspace, project, foundation, projectID)
	if err != nil {
		return err
	}
	markerPath := filepath.Join(foundationRoot, markerName)
	marker, exists, markerErr := ks.LoadMarker(markerPath)
	if markerErr != nil {
		marker = ks.Marker{}
		exists = true
	}
	landing, landingErr := ks.CollectLanding(foundationRoot)
	candidates, candidateErr := gitOutput(foundationRoot, "ls-files", "--cached", "--others", "--exclude-standard", "-z")
	var roadmap ks.Snapshot
	roadmapErr := candidateErr
	if roadmapErr == nil {
		roadmap, roadmapErr = ks.CollectRoadmap(foundationRoot, strings.Split(strings.TrimSuffix(candidates, "\x00"), "\x00"))
	}
	landingDoc, docErr := ks.ReadBounded(filepath.Join(foundationRoot, "project_landing.md"), ks.MaxDocumentBytes)
	if docErr != nil {
		landingErr = docErr
	}
	roadmapDoc, roadmapDocErr := ks.ReadBounded(filepath.Join(foundationRoot, "system_roadmap.md"), ks.MaxDocumentBytes)
	if roadmapDocErr != nil {
		roadmapErr = roadmapDocErr
	}
	if landingErr == nil && roadmapErr == nil && landing.BytesRead+int64(len(landingDoc)+len(roadmapDoc)) > ks.MaxAggregateBytes {
		landingErr = errors.New("aggregate evaluation byte limit exceeded")
		roadmapErr = errors.New("aggregate evaluation byte limit exceeded")
	}
	response := ks.Evaluate(landing, roadmap, landingDoc, roadmapDoc, marker, exists, *projectID, landingErr, roadmapErr)
	data, err := json.MarshalIndent(response, "", "  ")
	if err != nil {
		return err
	}
	data = append(data, '\n')
	if _, err := stdout.Write(data); err != nil {
		return infrastructure(errors.New("cannot write status response"))
	}
	return nil
}

func runPacket(args []string, stdout io.Writer) error {
	flags := flag.NewFlagSet("review-packet", flag.ContinueOnError)
	workspace, project, foundation, projectID := roots(flags)
	target := flags.String("target", "", "target: landing or roadmap")
	revision := flags.String("revision", "HEAD", "committed Foundation revision")
	foundationRoot, err := parseCommon(flags, args, workspace, project, foundation, projectID)
	if err != nil {
		return err
	}
	if *target != "landing" && *target != "roadmap" {
		return invalid(errors.New("target must be landing or roadmap"))
	}
	packet, err := committedPacket(foundationRoot, *target, *revision)
	if err != nil {
		return err
	}
	data, err := json.MarshalIndent(packet, "", "  ")
	if err != nil {
		return err
	}
	data = append(data, '\n')
	if _, err := stdout.Write(data); err != nil {
		return infrastructure(errors.New("cannot write review packet"))
	}
	return nil
}

func runRecord(args []string) error {
	flags := flag.NewFlagSet("record-review", flag.ContinueOnError)
	workspace, project, foundation, projectID := roots(flags)
	target := flags.String("target", "", "target: landing or roadmap")
	expected := flags.String("expected-packet-digest", "", "human-approved packet digest")
	reviewedBy := flags.String("reviewed-by", "", "attributable reviewer label")
	reference := flags.String("review-reference", "", "reference to the human approval message")
	revision := flags.String("revision", "", "reviewed committed Foundation revision")
	foundationRoot, err := parseCommon(flags, args, workspace, project, foundation, projectID)
	if err != nil {
		return err
	}
	if *target != "landing" && *target != "roadmap" || !fullRevision(*revision) || *expected == "" || *reviewedBy == "" || *reference == "" {
		return invalid(errors.New("record-review requires target, full revision, expected digest, reviewed-by, and review-reference"))
	}
	workspaceRoot, _ := filepath.Abs(*workspace)
	projectRoot := workspaceRoot
	if *project != "." {
		projectRoot, err = source.ContainedPath(workspaceRoot, *project)
		if err != nil {
			return err
		}
	}
	if err := validateReviewTarget(projectRoot, foundationRoot); err != nil {
		return err
	}
	if err := ks.RejectSymlinkComponents(foundationRoot); err != nil {
		return err
	}
	markerPath := filepath.Join(foundationRoot, markerName)
	lockPath := markerPath + ".lock"
	lock, err := acquireMarkerLock(lockPath)
	if err != nil {
		return fmt.Errorf("marker lock unavailable: %w", err)
	}
	lock.Close()
	defer os.Remove(lockPath)
	packet, err := committedPacket(foundationRoot, *target, *revision)
	if err != nil {
		return err
	}
	head, err := gitOutput(foundationRoot, "rev-parse", "HEAD")
	if err != nil {
		return err
	}
	if strings.TrimSpace(head) != packet.SourceRevision {
		return errors.New("Foundation HEAD changed since the approved packet revision")
	}
	if packet.PacketDigest != *expected {
		return errors.New("approved packet digest does not match selected committed packet")
	}
	working, err := workingPacket(foundationRoot, *target, packet.SourceRevision)
	if err != nil {
		return err
	}
	if working.PacketDigest != packet.PacketDigest {
		return errors.New("working tree differs from inspected committed packet")
	}
	marker, exists, err := ks.LoadMarker(markerPath)
	if err != nil {
		return fmt.Errorf("cannot read marker: %w", err)
	}
	if !exists {
		marker = ks.Marker{SchemaVersion: ks.SchemaVersion, ProjectID: *projectID}
	} else if err := ks.ValidateMarker(marker, *projectID); err != nil {
		return fmt.Errorf("cannot update semantically invalid marker: %w", err)
	}
	review := &ks.Review{ReviewedSourceDigest: packet.SourceDigest, ReviewedDocumentDigest: packet.DocumentDigest, ReviewedPacketDigest: packet.PacketDigest, ReviewedRevision: packet.SourceRevision, ReviewedBy: *reviewedBy, ReviewReference: *reference}
	switch *target {
	case "landing":
		marker.Landing = review
	case "roadmap":
		marker.Roadmap = review
	default:
		return errors.New("target must be landing or roadmap")
	}
	if err := ks.ValidateMarker(marker, *projectID); err != nil {
		return fmt.Errorf("candidate review marker is invalid: %w", err)
	}
	data, err := json.MarshalIndent(marker, "", "  ")
	if err != nil {
		return err
	}
	data = append(data, '\n')
	if len(data) > ks.MaxMarkerBytes {
		return errors.New("candidate review marker exceeds the serialized size limit")
	}
	if err := atomicWrite(markerPath, data, 0o600); err != nil {
		return infrastructure(errors.New("cannot replace review marker"))
	}
	return nil
}

func validateReviewTarget(projectRoot, foundationRoot string) error {
	projectRoot = filepath.Clean(projectRoot)
	foundationRoot = filepath.Clean(foundationRoot)
	if foundationRoot == projectRoot {
		return errors.New("Foundation cannot be the Project root for review recording")
	}
	rel, err := filepath.Rel(foundationRoot, projectRoot)
	if err != nil || rel == "." || rel != ".." && !strings.HasPrefix(rel, ".."+string(os.PathSeparator)) {
		return errors.New("Foundation cannot contain the Project root for review recording")
	}
	return nil
}

func acquireMarkerLock(path string) (*os.File, error) {
	return acquireMarkerLockWithWait(path, time.Sleep)
}

func acquireMarkerLockWithWait(path string, wait func(time.Duration)) (*os.File, error) {
	deadline := time.Now().Add(30 * time.Second)
	for {
		lock, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o600)
		if err == nil {
			return lock, nil
		}
		if !errors.Is(err, os.ErrExist) {
			return nil, err
		}
		if time.Now().After(deadline) {
			return nil, errors.New("timed out waiting for review marker lock")
		}
		wait(20 * time.Millisecond)
	}
}

func committedPacket(root, target, revision string) (ks.Packet, error) {
	if err := ks.RejectSymlinkComponents(root); err != nil {
		return ks.Packet{}, err
	}
	resolved, err := gitOutput(root, "rev-parse", "--verify", "--end-of-options", revision+"^{commit}")
	if err != nil {
		return ks.Packet{}, err
	}
	resolved = strings.TrimSpace(resolved)
	all, err := gitOutput(root, "ls-tree", "-r", "-z", resolved)
	if err != nil {
		return ks.Packet{}, err
	}
	treeModes := make(map[string]string)
	paths := make([]string, 0)
	entries := []string{}
	if all != "" {
		entries = strings.Split(strings.TrimSuffix(all, "\x00"), "\x00")
	}
	for _, entry := range entries {
		metadata, path, found := strings.Cut(entry, "\t")
		if !found {
			return ks.Packet{}, errors.New("malformed Foundation tree entry")
		}
		fields := strings.Fields(metadata)
		if len(fields) != 3 {
			return ks.Packet{}, errors.New("malformed Foundation tree metadata")
		}
		treeModes[path] = fields[0]
		paths = append(paths, path)
	}
	selected := make([]string, 0)
	if target == "landing" {
		for _, path := range paths {
			if landingSourcePath(path) {
				selected = append(selected, path)
				if len(selected) > ks.MaxInputs {
					return ks.Packet{}, errors.New("review packet input limit exceeded")
				}
			}
		}
		for _, required := range []string{"project_mandate.md", "domain_entities.md", "project_constitution.md", "system_roadmap.md"} {
			if !contains(selected, required) {
				return ks.Packet{}, fmt.Errorf("required source missing at revision: %s", required)
			}
		}
	} else if target == "roadmap" {
		for _, path := range paths {
			if roadmapPath(path) {
				selected = append(selected, path)
				if len(selected) > ks.MaxInputs {
					return ks.Packet{}, errors.New("review packet input limit exceeded")
				}
			}
		}
	} else {
		return ks.Packet{}, errors.New("target must be landing or roadmap")
	}
	inputs := make([]ks.Input, 0, len(selected))
	var total int64
	for _, path := range selected {
		if err := ks.ValidatePath(path); err != nil {
			return ks.Packet{}, err
		}
		if treeModes[path] != "100644" && treeModes[path] != "100755" {
			return ks.Packet{}, fmt.Errorf("non-regular committed input: %s", path)
		}
		var digest string
		if target == "landing" {
			data, e := gitBytes(root, resolved, path, ks.MaxDocumentBytes)
			if e != nil {
				return ks.Packet{}, e
			}
			total += int64(len(data))
			if len(data) > ks.MaxDocumentBytes || total > ks.MaxAggregateBytes {
				return ks.Packet{}, errors.New("review packet input limit exceeded")
			}
			digest = ks.DigestBytes(data)
		}
		inputs = append(inputs, ks.Input{Path: path, ContentDigest: digest})
	}
	if len(inputs) > ks.MaxInputs {
		return ks.Packet{}, errors.New("review packet input limit exceeded")
	}
	sourceDigest, err := ks.HashRecords(inputs)
	if err != nil {
		return ks.Packet{}, err
	}
	outPath := "project_landing.md"
	if target == "roadmap" {
		outPath = "system_roadmap.md"
	}
	if treeModes[outPath] != "100644" && treeModes[outPath] != "100755" {
		return ks.Packet{}, fmt.Errorf("non-regular committed output: %s", outPath)
	}
	document, err := gitBytes(root, resolved, outPath, ks.MaxDocumentBytes)
	if err != nil {
		return ks.Packet{}, err
	}
	if len(document) > ks.MaxDocumentBytes {
		return ks.Packet{}, errors.New("review output exceeds size limit")
	}
	if target == "landing" && total+int64(len(document)) > ks.MaxAggregateBytes {
		return ks.Packet{}, errors.New("review packet aggregate byte limit exceeded")
	}
	packet := ks.Packet{Target: target, SourceRevision: resolved, SourceDigest: sourceDigest, OutputPath: outPath, DocumentDigest: ks.DigestBytes(document), Inputs: inputs}
	packet.PacketDigest, err = ks.PacketDigest(packet)
	if err != nil {
		return ks.Packet{}, err
	}
	return packet, nil
}

func workingPacket(root, target, revision string) (ks.Packet, error) {
	packet, err := committedPacket(root, target, revision)
	if err != nil {
		return ks.Packet{}, err
	}
	var current ks.Snapshot
	if target == "landing" {
		current, err = ks.CollectLanding(root)
	} else {
		listing, e := gitOutput(root, "ls-files", "--cached", "--others", "--exclude-standard", "-z")
		if e != nil {
			return ks.Packet{}, e
		}
		current, err = ks.CollectRoadmap(root, strings.Split(strings.TrimSuffix(listing, "\x00"), "\x00"))
	}
	if err != nil {
		return ks.Packet{}, err
	}
	docPath := filepath.Join(root, filepath.FromSlash(packet.OutputPath))
	document, err := ks.ReadBounded(docPath, ks.MaxDocumentBytes)
	if err != nil {
		return ks.Packet{}, err
	}
	packet.SourceDigest = current.Digest
	packet.Inputs = current.Inputs
	packet.DocumentDigest = ks.DigestBytes(document)
	packet.PacketDigest, err = ks.PacketDigest(packet)
	return packet, err
}

func landingSourcePath(path string) bool {
	if path == "project_mandate.md" || path == "domain_entities.md" || path == "project_constitution.md" || path == "system_roadmap.md" {
		return true
	}
	return (strings.HasPrefix(path, "policies/") || strings.HasPrefix(path, "modules/")) && ks.IsMarkdownPath(path) && !ignoredLandingPath(path)
}
func roadmapPath(path string) bool {
	return strings.HasPrefix(path, "todos/") && !strings.HasPrefix(path, "todos/ephemeral/") && ks.IsMarkdownPath(path) && !ignoredPath(path)
}
func ignoredPath(path string) bool {
	for _, part := range strings.Split(filepath.ToSlash(path), "/") {
		lower := strings.ToLower(part)
		if lower == "tmp" || lower == "temp" || lower == "generated" {
			return true
		}
	}
	return false
}
func ignoredLandingPath(path string) bool {
	for _, part := range strings.Split(filepath.ToSlash(path), "/") {
		lower := strings.ToLower(part)
		if lower == "tmp" || lower == "temp" || lower == "generated" {
			return true
		}
	}
	return false
}
func contains(paths []string, want string) bool {
	for _, path := range paths {
		if path == want {
			return true
		}
	}
	return false
}

func gitBytes(root, revision, path string, limit int64) ([]byte, error) {
	data, err := boundedCommandOutput(limit, "git", "--no-replace-objects", "-C", root, "show", revision+":"+path)
	if err != nil {
		return nil, fmt.Errorf("cannot read committed Foundation path %s", path)
	}
	return data, nil
}
func gitOutput(root string, args ...string) (string, error) {
	data, err := boundedCommandOutput(ks.MaxAggregateBytes, "git", append([]string{"--no-replace-objects", "-C", root}, args...)...)
	if err != nil {
		return "", fmt.Errorf("git %s failed", strings.Join(args, " "))
	}
	return string(data), nil
}

func boundedCommandOutput(limit int64, name string, args ...string) ([]byte, error) {
	cmd := exec.Command(name, args...)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return nil, err
	}
	if err := cmd.Start(); err != nil {
		return nil, err
	}
	data, readErr := io.ReadAll(io.LimitReader(stdout, limit+1))
	if readErr != nil {
		_ = cmd.Process.Kill()
		_ = cmd.Wait()
		return nil, readErr
	}
	if int64(len(data)) > limit {
		_ = cmd.Process.Kill()
		_ = cmd.Wait()
		return nil, errors.New("command output exceeds limit")
	}
	waitErr := cmd.Wait()
	if waitErr != nil {
		return nil, waitErr
	}
	return data, nil
}

func atomicWrite(path string, data []byte, mode os.FileMode) error {
	if err := ks.RejectSymlinkComponents(filepath.Dir(path)); err != nil {
		return err
	}
	return atomicWriteUsing(path, data, mode, os.Rename)
}

func atomicWriteUsing(path string, data []byte, mode os.FileMode, rename func(string, string) error) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	tmp, err := os.CreateTemp(filepath.Dir(path), ".knowledge-status-*")
	if err != nil {
		return err
	}
	name := tmp.Name()
	defer os.Remove(name)
	if err := tmp.Chmod(mode); err != nil {
		tmp.Close()
		return err
	}
	if _, err := tmp.Write(data); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Sync(); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Close(); err != nil {
		return err
	}
	if err := rename(name, path); err != nil {
		return err
	}
	directory, err := os.Open(filepath.Dir(path))
	if err != nil {
		return err
	}
	defer directory.Close()
	return directory.Sync()
}
