# Release / Publish

Each SDK releases **from its own GitHub repository**. Tagging this umbrella is optional and only publishes Flutter (for existing pub.dev OIDC).

A **git tag is not a GitHub Release**. The sidebar **Releases → Latest** only updates when the tag workflow runs `softprops/action-gh-release` (`permissions: contents: write`), or when you run `gh release create <tag> --generate-notes`. After every tag, `gh release list --repo <owner/repo> --limit 1` must show **Latest** equal to that tag. Do not re-run pub.dev publish just to fix the sidebar.

## Android only

```bash
cd android   # or clone GazePointSDK-Android
# commit on main
git tag 2.2.0
git push origin main 2.2.0
```

JitPack: `com.github.Tareq-Ghassan:GazePointSDK-Android:2.2.0`

No Flutter, iOS, or umbrella commit is required.

## iOS only

```bash
cd ios
git tag 2.2.0
git push origin main 2.2.0
```

SPM URL: `https://github.com/Tareq-Ghassan/GazePointSDK-iOS`

## Flutter only (pub.dev)

1. On [gazepoint_sdk Admin](https://pub.dev/packages/gazepoint_sdk/admin) enable GitHub Actions publishing for **either**:
   - `Tareq-Ghassan/GazePointSDK-Flutter` (preferred), tag `v{{version}}`
   - or `Tareq-Ghassan/FaceDetection-GazePoint` (legacy umbrella workflow)
2. Set `version:` in `flutter/pubspec.yaml`
3. Tag that repo:

```bash
cd flutter
git tag v3.0.4
git push origin main v3.0.4
```

Android/iOS tags are **not** created.

## Web / Windows / macOS / Linux

Tag the corresponding `GazePointSDK-*` repository the same way.

## Umbrella SHA bumps (optional)

`git submodule update --remote` then commit in FaceDetection-GazePoint only if you want the umbrella lockfile to point at newer SDK SHAs. That is documentation, not a release.
