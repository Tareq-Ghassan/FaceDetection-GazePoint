# Creating GitHub Repositories for Platform SDKs

## Quick Setup Guide

Follow these steps to convert the platform directories to proper Git submodules:

## Step 1: Create GitHub Repositories

Go to GitHub and create these **4 new repositories**:

### 1. GazePointSDK-Web
- **URL**: https://github.com/Tareq-Ghassan/GazePointSDK-Web
- **Description**: "Real-time eye tracking and gaze point detection for web browsers using MediaPipe and TensorFlow.js"
- **Public/Private**: Public (recommended) or Private
- **Initialize**: ❌ **Do NOT** initialize with README, .gitignore, or license

### 2. GazePointSDK-Windows
- **URL**: https://github.com/Tareq-Ghassan/GazePointSDK-Windows
- **Description**: "Real-time eye tracking and gaze point detection for Windows applications using .NET and Windows Media Foundation"
- **Public/Private**: Public (recommended) or Private
- **Initialize**: ❌ **Do NOT** initialize with README, .gitignore, or license

### 3. GazePointSDK-macOS
- **URL**: https://github.com/Tareq-Ghassan/GazePointSDK-macOS
- **Description**: "Real-time eye tracking and gaze point detection for macOS applications using Swift and Vision framework"
- **Public/Private**: Public (recommended) or Private
- **Initialize**: ❌ **Do NOT** initialize with README, .gitignore, or license

### 4. GazePointSDK-Linux
- **URL**: https://github.com/Tareq-Ghassan/GazePointSDK-Linux
- **Description**: "Real-time eye tracking and gaze point detection for Linux applications using C++, OpenCV, and dlib"
- **Public/Private**: Public (recommended) or Private
- **Initialize**: ❌ **Do NOT** initialize with README, .gitignore, or license

## Step 2: Run the Setup Script

After creating all 4 repositories on GitHub, run:

```bash
cd /workspace
./SETUP_SUBMODULES.sh
```

The script will:
1. ✅ Initialize Git in each platform directory
2. ✅ Create initial commits
3. ✅ Push code to the new repositories
4. ✅ Remove directories from main repo
5. ✅ Add them back as submodules
6. ✅ Update .gitmodules
7. ✅ Commit and push changes

## Step 3: Verify

After the script completes, verify the submodules:

```bash
git submodule status
```

You should see:
```
 <commit> android (heads/main)
 <commit> ios (heads/main)
 <commit> web (heads/main)
 <commit> windows (heads/main)
 <commit> macos (heads/main)
 <commit> linux (heads/main)
 <commit> flutter (heads/main)
```

## Alternative: Manual Setup

If you prefer to do it manually:

### For each platform (web, windows, macos, linux):

```bash
# 1. Navigate to platform directory
cd web/

# 2. Initialize git
git init
git add .
git commit -m "feat: initial Web SDK implementation"

# 3. Add remote and push
git remote add origin https://github.com/Tareq-Ghassan/GazePointSDK-Web.git
git branch -M main
git push -u origin main

# 4. Go back to main repo
cd ..

# 5. Remove directory
rm -rf web/

# 6. Add as submodule
git submodule add https://github.com/Tareq-Ghassan/GazePointSDK-Web.git web

# Repeat for windows, macos, linux...
```

### Final commit:

```bash
git add .gitmodules web windows macos linux
git commit -m "feat: convert platform SDKs to Git submodules"
git push
```

## Troubleshooting

### If you get "repository not found":
- Make sure you created the GitHub repository
- Check that the repository name matches exactly
- Ensure you have push access to the repository

### If you get "directory already exists":
- Remove the directory first: `rm -rf <directory>/`
- Then add as submodule

### If push fails:
- Check your Git credentials
- Make sure you're authenticated with GitHub
- Try using SSH URLs instead of HTTPS

## What This Achieves

After completion, your repository structure will be:

```
FaceDetection-GazePoint/
├── android/         [submodule → GazePointSDK-Android]
├── ios/             [submodule → GazePointSDK-iOS]
├── web/             [submodule → GazePointSDK-Web] ⭐ NEW
├── windows/         [submodule → GazePointSDK-Windows] ⭐ NEW
├── macos/           [submodule → GazePointSDK-macOS] ⭐ NEW
├── linux/           [submodule → GazePointSDK-Linux] ⭐ NEW
└── flutter/         [submodule → GazePointSDK-Flutter]
```

Each platform can now:
- ✅ Be developed independently
- ✅ Have its own versioning
- ✅ Be published separately
- ✅ Be used standalone OR via Flutter

---

**Need help?** Check `MULTI_PLATFORM_ARCHITECTURE.md` for detailed architecture documentation.
