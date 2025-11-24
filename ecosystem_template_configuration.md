# Documentation: Ecosystem Template Configuration

**Version:** 1.0

## 1. Technology Stack

This section defines the non-negotiable technology stack to be used for all projects in this ecosystem.

* **Backend:** Laravel 12
* **Database:** MongoDB
* **Frontend:** Flutter
  * Manage Flutter SDK versions using [FVM](https://fvm.app/). All commands (including CI scripts) should invoke `fvm flutter …` unless explicitly running inside the CI Docker image. If a build needs to run via Docker, reuse the same Flutter image (e.g., `ghcr.io/cirruslabs/flutter`) with the host UID/GID so workspace permissions remain consistent.
