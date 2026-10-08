package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"

	ac "delphi-local-api/internal/artifact_catalog"
	"delphi-local-api/internal/source"
)

func main() { os.Exit(run(os.Args[1:], os.Stdout, os.Stderr)) }

func run(args []string, stdout, stderr io.Writer) int {
	if len(args) < 1 {
		return report(stderr, 64, "expected prototypes or design-system")
	}
	switch args[0] {
	case ac.TargetPrototypes:
		return runPrototypes(args[1:], stdout, stderr)
	case ac.TargetDesignSystem:
		return runDesignSystem(args[1:], stdout, stderr)
	default:
		return report(stderr, 64, "expected prototypes or design-system")
	}
}

func runPrototypes(args []string, stdout, stderr io.Writer) int {
	flags := flag.NewFlagSet("artifact-status prototypes", flag.ContinueOnError)
	ctx := addContextFlags(flags, false)
	mode := flags.String("mode", "", "working-tree or committed")
	revision := flags.String("revision", "", "committed revision selector")
	if err := parseFlags(flags, args); err != nil {
		return report(stderr, 64, err.Error())
	}
	if *mode != "working-tree" && *mode != "committed" || !validIdentity(ctx.projectID) || ctx.workspace == "" || ctx.project == "" || ctx.foundation == "" {
		return report(stderr, 64, "workspace-root, project-root, foundation-root, project-id, and valid mode are required")
	}
	if *mode == "working-tree" && *revision != "" || *mode == "committed" && *revision != "" && *revision != "HEAD" && !isFullRevision(*revision) {
		return report(stderr, 64, "revision selector is invalid for the selected mode")
	}
	workspaceRoot, err := resolveWorkspaceRoot(ctx.workspace)
	if err != nil {
		return report(stderr, 64, err.Error())
	}
	projectRoot, err := resolveWorkspacePath(workspaceRoot, ctx.project, true)
	if err != nil {
		return report(stderr, 64, err.Error())
	}
	foundationRoot, pathErr := resolveWorkspacePath(workspaceRoot, ctx.foundation, false)
	if pathErr == nil {
		if info, statErr := os.Stat(projectRoot); statErr != nil || !info.IsDir() {
			pathErr = errors.New("selected Project root is unavailable")
		}
	}
	if pathErr != nil {
		response := noGoResponse(*mode, ctx.projectID, *revision, "source_unavailable", "prototypes/catalog.json", "selected Project or Foundation source is unavailable or unsafe", "Select existing workspace-contained Project and Foundation directories without symlink components.")
		return emitResponse(response, stdout, stderr)
	}
	var selected source.Source
	if *mode == "working-tree" {
		selected, err = source.NewWorkingTree(foundationRoot)
	} else {
		selected, err = source.NewGitTree(foundationRoot, *revision)
	}
	if err != nil {
		code, message := "source_unavailable", "selected Foundation source is unavailable or unsafe"
		if errors.Is(err, source.ErrRevisionUnavailable) {
			code, message = "revision_unavailable", "requested Foundation revision is unavailable"
		}
		response := noGoResponse(*mode, ctx.projectID, *revision, code, "prototypes/catalog.json", message, "Use an existing exact Foundation Git root and an available committed revision.")
		return emitResponse(response, stdout, stderr)
	}
	response := ac.Evaluate(selected, ctx.projectID)
	code := 2
	if response.Outcome == "go" {
		code = 0
	}
	return emitResponseWithCode(response, code, stdout, stderr)
}

func emitResponse(response any, stdout, stderr io.Writer) int {
	return emitResponseWithCode(response, 2, stdout, stderr)
}

func emitResponseWithCode(response any, code int, stdout, stderr io.Writer) int {
	data, err := json.MarshalIndent(response, "", "  ")
	if err != nil {
		return report(stderr, 70, "cannot encode evaluator response")
	}
	data = append(data, '\n')
	if _, err := stdout.Write(data); err != nil {
		return report(stderr, 70, "cannot write evaluator response")
	}
	return code
}

func noGoResponse(mode, projectID, revision, code, path, message, resolution string) ac.Response {
	var revisionValue *string
	if isFullRevision(revision) {
		revisionValue = &revision
	}
	return ac.Response{
		SchemaVersion: ac.SchemaVersion, ProjectID: projectID, Target: ac.TargetPrototypes,
		AuthorityScope: ac.AuthorityScope, Mode: mode, Revision: revisionValue,
		Outcome: "no_go", Items: []ac.Item{}, Diagnostics: []ac.Diagnostic{{
			Code: code, SourceID: &projectID, Path: &path, Message: message, Resolution: resolution,
		}}, DesignSystemValidation: ac.DesignSystemPending,
	}
}

func report(stderr io.Writer, code int, message string) int {
	fmt.Fprintln(stderr, "artifact-status:", message)
	return code
}

func isFullRevision(value string) bool {
	if len(value) != 40 && len(value) != 64 {
		return false
	}
	for _, char := range value {
		if !((char >= '0' && char <= '9') || (char >= 'a' && char <= 'f')) {
			return false
		}
	}
	return true
}

func trustedRoot(workspaceRoot, requested string) (string, error) {
	root, err := resolveWorkspacePath(workspaceRoot, requested, true)
	if err != nil {
		return "", err
	}
	if info, err := os.Stat(root); err != nil || !info.IsDir() {
		return "", errors.New("selected root is unavailable")
	}
	return filepath.Clean(root), nil
}
