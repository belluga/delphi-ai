package main

import (
	"errors"
	"os"
	"path/filepath"
	"strings"

	"delphi-local-api/internal/source"
)

func validIdentity(value string) bool {
	if len(value) < 1 || len(value) > 64 || value[0] < 'a' || value[0] > 'z' {
		return false
	}
	for _, char := range value {
		if !((char >= 'a' && char <= 'z') || (char >= '0' && char <= '9') || char == '-') {
			return false
		}
	}
	return true
}

func fullRevision(value string) bool {
	if len(value) != 40 && len(value) != 64 {
		return false
	}
	for _, char := range value {
		if !((char >= 'a' && char <= 'f') || (char >= '0' && char <= '9')) {
			return false
		}
	}
	return true
}

func resolveContext(workspace, project, foundation string) (string, error) {
	if hostRoot := os.Getenv("DELPHI_LOCAL_API_HOST_WORKSPACE"); hostRoot != "" {
		if workspace != hostRoot {
			return "", invalid(errors.New("workspace-root does not match the launcher-selected workspace"))
		}
		workspace = "/workspace"
	}
	if !filepath.IsAbs(workspace) {
		return "", invalid(errors.New("workspace-root must be absolute"))
	}
	workspaceRoot, err := filepath.Abs(workspace)
	if err != nil {
		return "", invalid(errors.New("workspace-root cannot be resolved"))
	}
	if err := source.RejectSymlinkComponents(workspaceRoot); err != nil {
		return "", invalid(errors.New("workspace-root is unsafe"))
	}
	info, err := os.Stat(workspaceRoot)
	if err != nil || !info.IsDir() {
		return "", invalid(errors.New("workspace-root must be an existing directory"))
	}
	projectRoot := workspaceRoot
	if project != "." {
		if err := source.ValidateRelativePath(project); err != nil {
			return "", invalid(errors.New("project-root must be a safe workspace-relative path"))
		}
		projectRoot, err = source.ContainedPath(workspaceRoot, project)
		if err != nil {
			return "", err
		}
	}
	if info, err := os.Stat(projectRoot); err != nil || !info.IsDir() {
		return "", errors.New("selected Project root is unavailable")
	}
	if err := source.ValidateRelativePath(foundation); err != nil {
		return "", invalid(errors.New("foundation-root must be a safe workspace-relative path"))
	}
	foundationRoot, err := source.ContainedPath(workspaceRoot, foundation)
	if err != nil {
		return "", err
	}
	return foundationRoot, nil
}

func rejectDuplicateFlags(args []string) error {
	seen := make(map[string]struct{})
	for _, arg := range args {
		if arg == "--" {
			break
		}
		if !strings.HasPrefix(arg, "-") || arg == "-" {
			continue
		}
		name := strings.TrimLeft(strings.SplitN(arg, "=", 2)[0], "-")
		if _, exists := seen[name]; exists {
			return errors.New("duplicate option")
		}
		seen[name] = struct{}{}
	}
	return nil
}
