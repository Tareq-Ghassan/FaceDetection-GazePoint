# Workflow rules

Submodules exist so **each platform is its own product**. A change in Android must not require a Flutter, iOS, or umbrella commit.

## Independent SDK releases

| Change | Repo | Release |
|--------|------|---------|
| Android library / example | GazePointSDK-Android | Tag that repo → JitPack |
| iOS library / example | GazePointSDK-iOS | Tag that repo → SPM |
| Flutter Dart, plugin wrappers, pubspec | GazePointSDK-Flutter | Tag `vX.Y.Z` on that repo → pub.dev |
| Web / Windows / macOS / Linux | That SDK repo | Tag that repo |

- Feature branches live only in the repo that owns the files. The umbrella does not need the same branch name.
- `.gitmodules` tracks `branch = main` for `git submodule update --remote`. That updates the umbrella lockfile SHA; it is optional and is not part of a platform release.
- Do **not** copy Android Kotlin into Flutter. The plugin depends on `com.github.Tareq-Ghassan:GazePointSDK-Android:<version>`. Bump that version in `flutter/android/build.gradle` only when Flutter users should pick up a new Android SDK.
- iOS still uses a source snapshot under `flutter/ios/Classes/GazePointSDK` (CocoaPods). Releasing GazePointSDK-iOS does not update pub.dev until that snapshot is refreshed in the Flutter repo.

## Issues, branches, PRs

Work in the repo that owns the files. Do not commit to `main`.

1. Open a GitHub issue in **that** repo (not all seven unless the change really spans them).
2. Create a branch in that repo.
3. Push and open a pull request that references the issue (`Fixes #N`).
4. After merge, delete the branch.

pub.dev "Report an issue" goes to GazePointSDK-Flutter. Keep that as the Flutter inbox. Native-only bugs go to the native repo.

## Examples

Examples live in each SDK (`android/example`, `ios/Example`, `flutter/example`, …), not in the umbrella.

## Docs versions

When a package version changes, update install snippets in **that** SDK README and the umbrella README / EXAMPLES / TESTING / PUBLISHING_GUIDE in the same change. Do not leave `gazepoint_sdk: ^3.0.0` in docs after 3.0.3 is on pub.dev.
