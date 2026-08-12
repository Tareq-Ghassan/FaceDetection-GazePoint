# Agent Helper Files

This directory contains setup scripts and detailed technical documentation primarily used by automated agents and during initial repository setup.

## Files in this Directory

### Setup & Configuration
- **`SETUP_SUBMODULES.sh`** - Automated script to convert platform directories to Git submodules
- **`CREATE_REPOS.md`** - Step-by-step guide for creating the platform SDK repositories on GitHub
- **`SUBMODULES_SETUP.md`** - Comprehensive Git submodules usage guide and troubleshooting

### Architecture & Release
- **`WORKFLOW_RULES.md`** - Independent per-SDK branches, releases, and issue routing
- **`MULTI_PLATFORM_ARCHITECTURE.md`** - Detailed technical architecture documentation for the multi-platform SDK system
- **`RELEASE.md`** - Internal release process and GitHub Actions workflow documentation

## For Users

If you're looking for user-facing documentation, see the root directory:

- **[README.md](../README.md)** - Main project documentation
- **[EXAMPLES.md](../EXAMPLES.md)** - Examples for all platforms
- **[TESTING.md](../TESTING.md)** - How to run every SDK and Flutter on each platform
- **[PUBLISHING_GUIDE.md](../PUBLISHING_GUIDE.md)** - Publishing guide for package maintainers

## For Contributors

These files are useful if you're:
- Setting up the repository structure from scratch
- Understanding the submodule architecture
- Configuring CI/CD pipelines
- Contributing to the build/release process

## Note

Most users and contributors won't need these files. They're kept here to avoid cluttering the root directory while remaining accessible for advanced use cases.
