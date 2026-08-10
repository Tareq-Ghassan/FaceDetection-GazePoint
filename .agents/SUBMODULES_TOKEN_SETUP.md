# GitHub Personal Access Token (PAT) Setup for SUBMODULES_TOKEN

## What is SUBMODULES_TOKEN?

A GitHub Personal Access Token (PAT) that allows the CI/CD workflow to create tags in all your GazePointSDK submodule repositories.

## How to Create It

### Step 1: Go to GitHub Settings
1. Click your profile picture (top right) → **Settings**
2. Scroll down to **Developer settings** (bottom left)
3. Click **Personal access tokens** → **Tokens (classic)**
4. Click **Generate new token** → **Generate new token (classic)**

### Step 2: Configure the Token
1. **Note**: `GazePointSDK Submodules Token`
2. **Expiration**: Choose `No expiration` or `1 year`
3. **Select scopes**:
   - ✅ **repo** (Full control of private repositories)
     - This includes: repo:status, repo_deployment, public_repo, repo:invite, security_events

### Step 3: Generate and Copy
1. Click **Generate token** at the bottom
2. ⚠️ **IMPORTANT**: Copy the token immediately (starts with `ghp_`)
3. You won't be able to see it again!

### Step 4: Add to Repository Secrets
1. Go to your repository: `https://github.com/Tareq-Ghassan/FaceDetection-GazePoint`
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `SUBMODULES_TOKEN`
5. Secret: Paste your token (the `ghp_...` string)
6. Click **Add secret**

## What It Looks Like

```
ghp_1234567890abcdefghijklmnopqrstuvwxyzABC
```

## Repositories This Token Needs Access To

The token will be used to tag commits in these repositories:
- GazePointSDK-Android
- GazePointSDK-iOS
- GazePointSDK-Flutter
- GazePointSDK-Web
- GazePointSDK-Windows
- GazePointSDK-macOS
- GazePointSDK-Linux

Since you own all these repositories, a single PAT with `repo` scope will work for all of them.

## Security Note

This token has write access to your repositories, so:
- Never commit it to your code
- Only add it as a GitHub Secret
- GitHub will automatically redact it in logs
