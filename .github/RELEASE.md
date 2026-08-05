# Release / Publish (tag → GitHub Actions)

Publishing is automated. Push a version tag on `main` and CI publishes everything.

## One-time setup

### 1. pub.dev automated publishing (OIDC)

1. Open [gazepoint_sdk Admin](https://pub.dev/packages/gazepoint_sdk/admin)
2. Under **Automated publishing** → enable **publishing from GitHub Actions**
3. Set:
   - **Repository:** `Tareq-Ghassan/FaceDetection-GazePoint`
   - **Tag pattern:** `v{{version}}`
4. Do **not** require an environment unless you also create a matching GitHub Environment

### 2. GitHub secret for native repo tags (required)

Without this secret the **Tag Android + iOS** job fails.

1. Create a classic PAT: https://github.com/settings/tokens/new  
   - Scopes: **`repo`** (full) is simplest for public repos tagging  
   - Or fine-grained: Resource owner `Tareq-Ghassan`, repos:
     - `GazePointSDK-Android`
     - `GazePointSDK-iOS`
     - `GazePointSDK-Flutter`
     - Permissions: **Contents → Read and write**
2. In **this** umbrella repo:  
   https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/settings/secrets/actions  
   → **New repository secret**
3. Name: `SUBMODULES_TOKEN`  
4. Value: paste the PAT → Save

After adding it, re-run the failed workflow job (or push a new version tag).

## Every release

1. Land your changes on `main` (including submodule bumps).
2. Set the version in `flutter/pubspec.yaml` (and native version fields) to the new number, e.g. `2.1.0`.
3. Commit + push to `main`.
4. Tag and push:

```bash
git checkout main
git pull
git tag v2.1.0
git push origin v2.1.0
```

Or create the tag on GitHub: **Releases → Draft a new release → choose tag `v2.1.0`**.

## What the pipeline does

| Job | Action |
|-----|--------|
| Validate | Ensures tag `vX.Y.Z` matches `flutter/pubspec.yaml` |
| Publish Flutter | `dart pub publish` to pub.dev via OIDC |
| Release native | Tags `GazePointSDK-Android` / `-iOS` / `-Flutter` at the submodule SHAs with `X.Y.Z`, then pings JitPack |

## Tag rules

- Umbrella tag: `v2.1.0` (leading `v` required)
- Must be greater than previously published versions
- Must match `flutter/pubspec.yaml` exactly (`2.1.0`)
- Native submodule repos get tag `2.1.0` (no `v`), same as the existing `2.0.0` tags

## Verify

- Actions: https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/actions
- pub.dev: https://pub.dev/packages/gazepoint_sdk
- JitPack: https://jitpack.io/#Tareq-Ghassan/GazePointSDK-Android
- iOS SPM URL: https://github.com/Tareq-Ghassan/GazePointSDK-iOS
