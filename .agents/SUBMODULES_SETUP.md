# Git Submodules Setup Guide

This umbrella repository ([FaceDetection-GazePoint](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint)) uses Git submodules for the platform SDKs.

## Repository Structure

```
FaceDetection-GazePoint/          (umbrella lockfile)
├── android/          → GazePointSDK-Android   (includes example/)
├── ios/              → GazePointSDK-iOS       (includes Example/)
├── flutter/          → GazePointSDK-Flutter   (includes example/)
├── web/ windows/ macos/ linux/
├── .gitmodules
└── README.md
```

Examples live **inside each SDK repo**, not in the umbrella.

## Initial Setup (already done for this project)

Submodules are declared in `.gitmodules`:

```gitconfig
[submodule "android"]
	path = android
	url = https://github.com/Tareq-Ghassan/GazePointSDK-Android.git
[submodule "ios"]
	path = ios
	url = https://github.com/Tareq-Ghassan/GazePointSDK-iOS.git
[submodule "flutter"]
	path = flutter
	url = https://github.com/Tareq-Ghassan/GazePointSDK-Flutter.git
```

If you are recreating this layout from scratch:

```bash
git submodule add https://github.com/Tareq-Ghassan/GazePointSDK-Android.git android
git submodule add https://github.com/Tareq-Ghassan/GazePointSDK-iOS.git ios
git submodule add https://github.com/Tareq-Ghassan/GazePointSDK-Flutter.git flutter
git add .gitmodules android ios flutter
git commit -m "chore: add platform SDKs as submodules"
```

## Cloning with Submodules

```bash
git clone --recurse-submodules https://github.com/Tareq-Ghassan/FaceDetection-GazePoint.git

# Or if already cloned without submodules:
cd FaceDetection-GazePoint
git submodule update --init --recursive
```

## Updating Submodules

```bash
# All submodules to latest remote commits on their tracked branches
git submodule update --remote --merge

# One submodule
cd android
git checkout main
git pull origin main
cd ..
git add android
git commit -m "chore: update Android submodule"
```

## Making Changes in a Submodule

Work on `main` (or a feature branch) **in that submodule repo**. Push and tag there. Do not create the same branch name on the umbrella.

```bash
cd android
git checkout main
# edit, commit, push, tag — Flutter/iOS stay untouched
```

To refresh the umbrella lockfile later (optional):

```bash
cd ..
git add android
git commit -m "chore: point Android submodule at latest main"
```

## Common Commands

```bash
git submodule status
git diff --submodule
git submodule foreach 'git status -sb'
git submodule foreach 'git pull origin main'
```

## Troubleshooting

### Detached HEAD in a submodule

Normal — submodules pin a commit. To work on a branch:

```bash
cd android
git checkout main
# make changes…
cd ..
git add android
git commit -m "chore: update Android submodule"
```

### Submodule stuck at an old commit

```bash
cd android
git fetch
git checkout main
git pull
cd ..
git add android
git commit -m "chore: update Android submodule to latest"
```

## Benefits

1. Independent versioning and release cycles per platform
2. Cleaner history in each SDK repo
3. Example apps can stay in the umbrella without bloating SDK packages

## Support

Open an issue on [FaceDetection-GazePoint](https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/issues).

---

Last updated: 2026-07-31
