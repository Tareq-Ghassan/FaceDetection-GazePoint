#!/bin/bash
# Script to convert platform directories to Git submodules
set -e

echo "🚀 Setting up GazePoint SDK platform submodules..."

# GitHub username
GITHUB_USER="Tareq-Ghassan"

# Check if repos exist first
echo ""
echo "⚠️  Create these 4 GitHub repositories first:"
echo "  - https://github.com/${GITHUB_USER}/GazePointSDK-Web"
echo "  - https://github.com/${GITHUB_USER}/GazePointSDK-Windows"
echo "  - https://github.com/${GITHUB_USER}/GazePointSDK-macOS"
echo "  - https://github.com/${GITHUB_USER}/GazePointSDK-Linux"
echo ""
read -p "Have you created all 4 repositories? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Please create the repositories first"
    exit 1
fi

# Process each platform
for platform in web windows macos linux; do
    case $platform in
        web) repo="GazePointSDK-Web" ;;
        windows) repo="GazePointSDK-Windows" ;;
        macos) repo="GazePointSDK-macOS" ;;
        linux) repo="GazePointSDK-Linux" ;;
    esac
    
    echo "Processing $platform..."
    cd "$platform"
    git init
    git add .
    git commit -m "feat: initial $platform SDK implementation"
    git remote add origin "https://github.com/${GITHUB_USER}/${repo}.git"
    git branch -M main
    git push -u origin main
    cd ..
    
    rm -rf "$platform"
    git submodule add "https://github.com/${GITHUB_USER}/${repo}.git" "$platform"
done

git add .gitmodules web windows macos linux
git commit -m "feat: convert platform SDKs to Git submodules"
git push

echo "✅ Done!"
