package main

import (
	"flag"
	"io"
	"os"
	"path/filepath"

	ac "delphi-local-api/internal/artifact_catalog"
	"delphi-local-api/internal/source"
)

func runDesignSystem(args []string, stdout, stderr io.Writer) int {
	flags := flag.NewFlagSet("artifact-status design-system", flag.ContinueOnError)
	ctx := addContextFlags(flags, true)
	mode := flags.String("mode", "", "working-tree or committed")
	if err := parseFlags(flags, args); err != nil {
		return report(stderr, 64, err.Error())
	}
	if ctx.workspace == "" || ctx.project == "" || ctx.foundation == "" || !validIdentity(ctx.projectID) || !validIdentity(ctx.companyID) || *mode != "working-tree" && *mode != "committed" {
		return report(stderr, 64, "explicit workspace, project, foundation, identities, and mode are required")
	}
	workspace, err := resolveWorkspaceRoot(ctx.workspace)
	if err != nil {
		return report(stderr, 64, err.Error())
	}
	project, err := resolveWorkspacePath(workspace, ctx.project, true)
	if err != nil {
		return report(stderr, 64, err.Error())
	}
	foundation, err := resolveWorkspacePath(workspace, ctx.foundation, false)
	if err != nil {
		return designSystemFailure(ctx.projectID, ctx.companyID, *mode, "source_unavailable", stdout, stderr)
	}
	if err := source.RejectSymlinkComponents(project); err != nil {
		return designSystemFailure(ctx.projectID, ctx.companyID, *mode, "source_unavailable", stdout, stderr)
	}
	projectInfo, err := os.Stat(project)
	if err != nil || !projectInfo.IsDir() {
		return designSystemFailure(ctx.projectID, ctx.companyID, *mode, "source_unavailable", stdout, stderr)
	}
	var bindings ac.SourceBindings
	if ctx.bindingsPath == "" {
		bindings = ac.StandardProjectBindings(ctx.projectID, ctx.companyID, ctx.foundation)
	} else {
		if source.ValidateRelativePath(ctx.bindingsPath) != nil {
			return report(stderr, 64, "source-bindings must be a safe workspace-relative path")
		}
		bindingFile, pathErr := source.ContainedPath(workspace, ctx.bindingsPath)
		if pathErr != nil {
			return designSystemFailure(ctx.projectID, ctx.companyID, *mode, "read_failed", stdout, stderr)
		}
		data, readErr := source.ReadBounded(bindingFile, ac.MaxSourceBindingsBytes)
		if readErr != nil {
			return designSystemFailure(ctx.projectID, ctx.companyID, *mode, "read_failed", stdout, stderr)
		}
		bindings, err = ac.DecodeSourceBindings(data)
		if err != nil {
			return designSystemFailure(ctx.projectID, ctx.companyID, *mode, "invalid_schema", stdout, stderr)
		}
	}
	if bindings.Sources.Default != nil && !validIdentity(ctx.defaultOwnerID) {
		return report(stderr, 64, "default-owner-id is required when the default source is non-null")
	}
	diagnostics := ac.ValidateSourceBindings(bindings, *mode, ctx.projectID, ctx.companyID, ctx.defaultOwnerID)
	if len(diagnostics) != 0 {
		response := ac.DesignSystemResponse{SchemaVersion: ac.SchemaVersion, ProjectID: ctx.projectID, CompanyID: ctx.companyID, Target: ac.TargetDesignSystem, AuthorityScope: ac.AuthorityScope, Mode: *mode, Outcome: "no_go", Items: []ac.DesignSystemDefinition{}, Diagnostics: diagnostics, DesignSystemValidation: "not_evaluated"}
		return emitResponse(response, stdout, stderr)
	}
	level, binding := ac.SelectSourceBinding(bindings)
	if binding == nil {
		return designSystemFailure(ctx.projectID, ctx.companyID, *mode, "source_binding_missing", stdout, stderr)
	}
	checkout, err := source.ContainedPath(workspace, binding.CheckoutRoot)
	if err != nil {
		return designSystemFailure(ctx.projectID, ctx.companyID, *mode, "source_unavailable", stdout, stderr)
	}
	if level == "project" && filepath.Clean(checkout) != filepath.Clean(foundation) {
		return designSystemFailure(ctx.projectID, ctx.companyID, *mode, "owner_mismatch", stdout, stderr)
	}
	var selected source.Source
	if *mode == "working-tree" {
		selected, err = source.NewWorkingTree(checkout)
	} else if binding.Revision == nil {
		err = source.ErrRevisionUnavailable
	} else {
		selected, err = source.NewGitTree(checkout, *binding.Revision)
	}
	if err != nil {
		return designSystemFailure(ctx.projectID, ctx.companyID, *mode, "source_unavailable", stdout, stderr)
	}
	response := ac.EvaluateDesignSystem(selected, ctx.projectID, ctx.companyID, ctx.defaultOwnerID, level, *binding)
	code := 2
	if response.Outcome == "go" {
		code = 0
	}
	return emitResponseWithCode(response, code, stdout, stderr)
}

func designSystemFailure(projectID, companyID, mode, code string, stdout, stderr io.Writer) int {
	response := ac.DesignSystemResponse{SchemaVersion: ac.SchemaVersion, ProjectID: projectID, CompanyID: companyID, Target: ac.TargetDesignSystem, AuthorityScope: ac.AuthorityScope, Mode: mode, Outcome: "no_go", Items: []ac.DesignSystemDefinition{}, Diagnostics: []ac.Diagnostic{{Code: code, Message: "selected Design System source is unavailable or invalid", Resolution: "Restore the selected workspace-contained source and retry the complete evaluation."}}, DesignSystemValidation: "not_evaluated"}
	return emitResponse(response, stdout, stderr)
}
