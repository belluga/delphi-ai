package main

import (
	"errors"
	"flag"
	"os"
	"path/filepath"
	"strings"

	"delphi-local-api/internal/source"
)

type operationContext struct {
	workspace, project, foundation, projectID string
	companyID, bindingsPath, defaultOwnerID   string
}

func addContextFlags(flags *flag.FlagSet, designSystem bool) *operationContext {
	c := &operationContext{}
	flags.StringVar(&c.workspace, "workspace-root", "", "explicit absolute workspace root")
	flags.StringVar(&c.project, "project-root", "", "workspace-relative Project root")
	flags.StringVar(&c.foundation, "foundation-root", "", "workspace-relative Foundation checkout")
	flags.StringVar(&c.projectID, "project-id", "", "explicit Project identity")
	if designSystem {
		flags.StringVar(&c.companyID, "company-id", "", "explicit Company identity")
		flags.StringVar(&c.bindingsPath, "source-bindings", "", "workspace-relative private source bindings")
		flags.StringVar(&c.defaultOwnerID, "default-owner-id", "", "explicit owner identity for a non-null default source")
	}
	return c
}

func resolveWorkspaceRoot(value string) (string, error) {
	if hostRoot := os.Getenv("DELPHI_LOCAL_API_HOST_WORKSPACE"); hostRoot != "" {
		if value != hostRoot {
			return "", errors.New("workspace-root does not match the launcher-selected workspace")
		}
		value = "/workspace"
	}
	if !filepath.IsAbs(value) {
		return "", errors.New("workspace-root must be an existing absolute directory")
	}
	root, err := filepath.Abs(value)
	if err != nil || source.RejectSymlinkComponents(root) != nil {
		return "", errors.New("workspace-root is unsafe")
	}
	info, err := os.Stat(root)
	if err != nil || !info.IsDir() {
		return "", errors.New("workspace-root must be an existing absolute directory")
	}
	return root, nil
}

func resolveWorkspacePath(root, relative string, allowDot bool) (string, error) {
	if allowDot && relative == "." {
		return root, nil
	}
	if err := source.ValidateRelativePath(relative); err != nil {
		return "", errors.New("workspace paths must be safe relative paths")
	}
	return source.ContainedPath(root, relative)
}

func parseFlags(flags *flag.FlagSet, args []string) error {
	flags.SetOutput(new(strings.Builder))
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
	if err := flags.Parse(args); err != nil || flags.NArg() != 0 {
		return errors.New("invalid arguments")
	}
	return nil
}

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
