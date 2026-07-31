# Git Submodules Setup Guide

This repository uses Git submodules to organize platform-specific SDKs. This guide explains how to set up and work with the submodules.

## Repository Structure

```
GazePointSDK/
├── android/          (submodule → GazePointSDK-Android)
├── ios/              (submodule → GazePointSDK-iOS)
├── flutter/          (submodule → GazePointSDK-Flutter)
├── .gitignore
├── README.md
├── LICENSE
└── SUBMODULES_SETUP.md (this file)
```

## Initial Setup Steps

### 1. Create Separate Repositories

First, create three separate repositories on GitHub:

1. `GazePointSDK-Android` - Android SDK repository
2. `GazePointSDK-iOS` - iOS SDK repository
3. `GazePointSDK-Flutter` - Flutter SDK repository

### 2. Move Platform Code to Separate Repos

#### For Android:

```bash
# In a new directory
git clone https://github.com/yourusername/GazePointSDK.git temp-android
cd temp-android

# Keep only Android code
git filter-branch --subdirectory-filter app -- --all
# Or use git-filter-repo (recommended):
git filter-repo --path app/ --path build.gradle --path gradle/ --path settings.gradle

# Push to Android repo
git remote set-url origin https://github.com/yourusername/GazePointSDK-Android.git
git push -u origin main

cd ..
rm -rf temp-android
```

#### For iOS:

```bash
# In a new directory
git clone https://github.com/yourusername/GazePointSDK.git temp-ios
cd temp-ios

# Keep only iOS code
git filter-repo --path ios-sdk/

# Push to iOS repo
git remote set-url origin https://github.com/yourusername/GazePointSDK-iOS.git
git push -u origin main

cd ..
rm -rf temp-ios
```

#### For Flutter:

```bash
# In a new directory
git clone https://github.com/yourusername/GazePointSDK.git temp-flutter
cd temp-flutter

# Keep only Flutter code
git filter-repo --path flutter-sdk/

# Push to Flutter repo
git remote set-url origin https://github.com/yourusername/GazePointSDK-Flutter.git
git push -u origin main

cd ..
rm -rf temp-flutter
```

### 3. Add Submodules to Main Repository

In the main GazePointSDK repository:

```bash
# Remove the platform directories (they'll be added as submodules)
git rm -rf app/ build.gradle gradle/ settings.gradle gradle.properties gradlew gradlew.bat
git rm -rf ios-sdk/
git rm -rf flutter-sdk/
git commit -m "chore: remove platform code in preparation for submodules"

# Add submodules
git submodule add https://github.com/yourusername/GazePointSDK-Android.git android
git submodule add https://github.com/yourusername/GazePointSDK-iOS.git ios
git submodule add https://github.com/yourusername/GazePointSDK-Flutter.git flutter

# Commit the submodules
git add .gitmodules android ios flutter
git commit -m "chore: add platform SDKs as submodules"

# Push changes
git push origin main
```

## Working with Submodules

### Cloning the Repository with Submodules

```bash
# Clone with all submodules
git clone --recurse-submodules https://github.com/yourusername/GazePointSDK.git

# Or if you already cloned without submodules:
git clone https://github.com/yourusername/GazePointSDK.git
cd GazePointSDK
git submodule init
git submodule update
```

### Updating Submodules

#### Update all submodules to latest:

```bash
git submodule update --remote --merge
```

#### Update a specific submodule:

```bash
cd android
git pull origin main
cd ..
git add android
git commit -m "chore: update Android submodule"
git push
```

### Making Changes in Submodules

When you make changes in a submodule:

```bash
# Go to the submodule directory
cd android

# Make changes, commit them
git add .
git commit -m "feat: add new feature"

# Push to the submodule repository
git push origin main

# Go back to main repository
cd ..

# Update the submodule reference in main repo
git add android
git commit -m "chore: update Android submodule reference"
git push
```

### Creating a New Branch Across All Repos

```bash
# Create feature branch in main repo
git checkout -b feature/new-feature

# Create matching branch in each submodule
cd android && git checkout -b feature/new-feature && cd ..
cd ios && git checkout -b feature/new-feature && cd ..
cd flutter && git checkout -b feature/new-feature && cd ..

# Make changes, commit, push
# ...

# Push all branches
git push origin feature/new-feature
cd android && git push origin feature/new-feature && cd ..
cd ios && git push origin feature/new-feature && cd ..
cd flutter && git push origin feature/new-feature && cd ..
```

## Common Commands Cheat Sheet

```bash
# Clone with submodules
git clone --recurse-submodules <repo-url>

# Initialize submodules (if cloned without --recurse-submodules)
git submodule init
git submodule update

# Update all submodules to latest
git submodule update --remote --merge

# Update specific submodule
cd <submodule-dir>
git pull origin main
cd ..
git add <submodule-dir>
git commit -m "chore: update <submodule> submodule"

# Check submodule status
git submodule status

# See what changed in submodules
git diff --submodule

# Execute command in all submodules
git submodule foreach 'git pull origin main'

# Remove a submodule
git submodule deinit -f <submodule-path>
git rm -f <submodule-path>
rm -rf .git/modules/<submodule-path>
```

## Troubleshooting

### Submodule is detached HEAD

This is normal. Submodules track specific commits, not branches. To work on a branch:

```bash
cd <submodule-dir>
git checkout main  # or your branch
# Make changes...
cd ..
git add <submodule-dir>
git commit -m "chore: update submodule"
```

### Submodule changes not showing

```bash
git submodule update --remote
```

### Conflicts in submodule references

```bash
# Accept theirs
git checkout --theirs <submodule-dir>

# Accept ours
git checkout --ours <submodule-dir>

# Then:
git add <submodule-dir>
git submodule update --init
```

### Submodule stuck at old commit

```bash
cd <submodule-dir>
git fetch
git checkout main
git pull
cd ..
git add <submodule-dir>
git commit -m "chore: update submodule to latest"
```

## Benefits of This Structure

1. **Separation of Concerns** - Each platform has its own repository, CI/CD, and release cycle
2. **Independent Versioning** - Android, iOS, and Flutter can have different version numbers
3. **Easier Contributions** - Contributors can work on specific platforms without cloning everything
4. **Cleaner History** - Platform-specific commits don't clutter the main repo history
5. **Flexible Workflows** - Different teams can work independently on each platform
6. **Better CI/CD** - Each platform can have its own build and deployment pipeline

## Alternative: Mono-repo Approach

If submodules become too complex, consider using a mono-repo tool:
- **Turborepo** - For JavaScript/TypeScript projects
- **Nx** - For cross-platform development
- **Bazel** - For large-scale projects
- **Git subtree** - Alternative to submodules (copies instead of references)

## Additional Resources

- [Git Submodules Official Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [GitHub Submodules Guide](https://github.blog/2016-02-01-working-with-submodules/)
- [Atlassian Git Submodules Tutorial](https://www.atlassian.com/git/tutorials/git-submodule)

## Support

If you encounter issues with submodules, please:
1. Check this guide first
2. Search existing issues
3. Create a new issue with details about your problem

---

Last updated: 2026-07-29
