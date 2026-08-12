# Publishing Guide for GazePoint SDK

**Independent releases:** tag the SDK repo you changed. Do not tag every platform together. Short version: [`.agents/RELEASE.md`](.agents/RELEASE.md).

This guide walks you through publishing the GazePoint SDK to all supported platforms: pub.dev (Flutter), CocoaPods/SPM (iOS), and JitPack/Maven (Android).

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Publishing to pub.dev (Flutter)](#publishing-to-pubdev-flutter)
3. [Publishing to iOS Platforms](#publishing-to-ios-platforms)
4. [Publishing to Android Platforms](#publishing-to-android-platforms)
5. [Version Management](#version-management)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts

- **pub.dev**: Google account with verified publisher
- **CocoaPods**: CocoaPods Trunk account
- **JitPack**: GitHub account (JitPack uses GitHub releases)
- **Maven Central** (optional): Sonatype account

### Required Tools

```bash
# Flutter/Dart
flutter --version  # Should be 3.38.4+
dart --version     # Should be 3.5+

# iOS
pod --version      # CocoaPods 1.11+
swift --version    # Swift 6.0+

# Android
./gradlew --version  # Gradle 8.0+
```

### Repository Preparation

Ensure all tests pass and code is clean:

```bash
# Flutter tests
cd flutter
flutter test
flutter analyze
dart format --set-exit-if-changed .

# iOS tests
cd ../ios
swift test

# Android tests
cd ../android
./gradlew test
```

---

## Publishing to pub.dev (Flutter)

### Step 1: Verify Package Quality

Run pub.dev analysis to check your package score:

```bash
cd flutter
flutter pub publish --dry-run
```

This shows:
- Package score breakdown
- Missing documentation
- Platform support issues
- Any blocking errors

**Target Score**: Aim for 130+ points for good visibility.

### Step 2: Update Version

Update version in `flutter/pubspec.yaml`:

```yaml
version: 2.0.0  # Increment according to semver
```

Also update `flutter/CHANGELOG.md`:

```markdown
## 2.0.0

* Initial stable release
* Real-time gaze tracking at 30 FPS
* Multi-point calibration support
* iOS and Android platform support
```

### Step 3: Verify Publisher

First-time only - verify your publisher:

```bash
# Login to pub.dev
dart pub login

# Create a verified publisher (if needed)
# Go to: https://pub.dev/create-publisher
```

Add publisher to `pubspec.yaml`:

```yaml
publish_to: 'https://pub.dev'
# publisher: your-domain.com  # Optional verified publisher
```

### Step 4: Publish

```bash
# Final dry run
flutter pub publish --dry-run

# If all looks good, publish!
flutter pub publish
```

You'll be asked to confirm. Type `y` to proceed.

### Step 5: Verify Publication

- Check your package: `https://pub.dev/packages/gazepoint_sdk`
- Verify documentation: `https://pub.dev/documentation/gazepoint_sdk/latest/`
- Check package score on the pub.dev page

### Common Issues

**Issue**: "Package validation failed"
- **Fix**: Run `flutter pub publish --dry-run` and address all errors

**Issue**: "Missing example"
- **Fix**: Ensure `flutter/example/` directory exists with working code

**Issue**: "Documentation score low"
- **Fix**: Add dartdoc comments to all public APIs

---

## Publishing to iOS Platforms

iOS has two main distribution methods: **CocoaPods** and **Swift Package Manager**.

### Option A: CocoaPods

#### Step 1: Register with CocoaPods Trunk

First-time only:

```bash
pod trunk register your-email@example.com 'Your Name' --description='MacBook Pro'
```

Check your email and click the verification link.

Verify registration:

```bash
pod trunk me
```

#### Step 2: Update Podspec

Edit `ios/GazePointSDK.podspec`:

```ruby
Pod::Spec.new do |s|
  s.name             = 'GazePointSDK'
  s.version          = '2.0.0'  # Update this
  s.summary          = 'GazePoint SDK for iOS — eye tracking and gaze point detection'
  s.description      = <<-DESC
    Native iOS GazePoint SDK using Vision face landmarks for gaze estimation.
    Supports real-time gaze tracking, head pose compensation, and blink detection.
  DESC
  s.homepage         = 'https://github.com/Tareq-Ghassan/GazePointSDK-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'your-email@example.com' }
  s.source           = {
    :git => 'https://github.com/Tareq-Ghassan/GazePointSDK-iOS.git',
    :tag => s.version.to_s
  }
  s.source_files     = 'Sources/GazePointSDK/**/*.swift'
  s.ios.deployment_target = '16.0'
  s.swift_version    = '6.0'
  s.frameworks       = 'Vision', 'UIKit', 'AVFoundation', 'CoreMedia'
end
```

#### Step 3: Validate Podspec

```bash
cd ios
pod spec lint GazePointSDK.podspec --allow-warnings
```

Fix any errors that appear.

#### Step 4: Create Git Tag

CocoaPods requires a git tag matching the version:

```bash
cd ios
git tag 2.0.0
git push origin 2.0.0
```

#### Step 5: Publish to CocoaPods

```bash
pod trunk push GazePointSDK.podspec --allow-warnings
```

#### Step 6: Verify

```bash
pod search GazePointSDK
```

Your pod should appear in search results.

Users can now install via:

```ruby
pod 'GazePointSDK', '~> 2.0'
```

### Option B: Swift Package Manager (SPM)

SPM uses GitHub releases - no separate publishing step needed!

#### Step 1: Verify Package.swift

Ensure `ios/Package.swift` is properly configured:

```swift
// swift-tools-version:6.3
import PackageDescription

let package = Package(
    name: "GazePointSDK",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "GazePointSDK",
            targets: ["GazePointSDK"]
        ),
    ],
    targets: [
        .target(
            name: "GazePointSDK",
            path: "Sources/GazePointSDK"
        )
    ]
)
```

#### Step 2: Create GitHub Release

```bash
cd ios
git tag 2.0.0
git push origin 2.0.0
```

Then create a release on GitHub:
1. Go to `https://github.com/Tareq-Ghassan/GazePointSDK-iOS/releases/new`
2. Select tag: `2.0.0`
3. Release title: `v2.0.0`
4. Add release notes
5. Click "Publish release"

#### Step 3: Verify

Users can now add to their `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Tareq-Ghassan/GazePointSDK-iOS.git", from: "2.0.0")
]
```

Or add via Xcode:
- File → Add Package Dependencies
- Enter: `https://github.com/Tareq-Ghassan/GazePointSDK-iOS.git`

---

## Publishing to Android Platforms

Android has two main options: **JitPack** (easiest) and **Maven Central** (more official).

### Option A: JitPack (Recommended for Open Source)

JitPack automatically builds and serves your library from GitHub releases.

#### Step 1: Verify build.gradle

Your `android/gazepoint-sdk/build.gradle` already has Maven publishing configured:

```gradle
publishing {
    publications {
        release(MavenPublication) {
            from components.release
            groupId = 'com.github.Tareq-Ghassan'
            artifactId = 'GazePointSDK-Android'
            version = android.defaultConfig.versionName
        }
    }
}
```

#### Step 2: Create GitHub Release

```bash
cd android
git tag 2.0.0
git push origin 2.0.0
```

Create release on GitHub:
1. Go to `https://github.com/Tareq-Ghassan/GazePointSDK-Android/releases/new`
2. Select tag: `2.0.0`
3. Title: `v2.0.0`
4. Add release notes
5. Publish

#### Step 3: Trigger JitPack Build

Visit: `https://jitpack.io/#Tareq-Ghassan/GazePointSDK-Android`

Click "Get it" for version 2.0.0. JitPack will build your library.

#### Step 4: Verify

Users can now add to their `build.gradle`:

```gradle
// Project level build.gradle
repositories {
    maven { url 'https://jitpack.io' }
}

// App level build.gradle
dependencies {
    implementation 'com.github.Tareq-Ghassan:GazePointSDK-Android:2.0.0'
}
```

Check build status: `https://jitpack.io/#Tareq-Ghassan/GazePointSDK-Android`

### Option B: Maven Central (Production)

Maven Central is more official but requires more setup.

#### Step 1: Create Sonatype Account

1. Go to: `https://issues.sonatype.org/`
2. Create account
3. Create a JIRA ticket to claim your groupId (e.g., `io.github.tareq-ghassan`)

#### Step 2: Set up GPG Signing

```bash
# Generate GPG key
gpg --gen-key

# List keys
gpg --list-keys

# Export public key
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
```

#### Step 3: Configure gradle.properties

Add to `~/.gradle/gradle.properties`:

```properties
signing.keyId=YOUR_KEY_ID
signing.password=YOUR_KEY_PASSWORD
signing.secretKeyRingFile=/path/to/secring.gpg

ossrhUsername=your-sonatype-username
ossrhPassword=your-sonatype-password
```

#### Step 4: Update build.gradle

Add to `android/gazepoint-sdk/build.gradle`:

```gradle
plugins {
    id 'maven-publish'
    id 'signing'
}

publishing {
    publications {
        release(MavenPublication) {
            groupId = 'io.github.tareq-ghassan'
            artifactId = 'gazepoint-sdk'
            version = '2.0.0'

            pom {
                name = 'GazePoint SDK'
                description = 'Eye tracking and gaze point detection for Android'
                url = 'https://github.com/Tareq-Ghassan/GazePointSDK-Android'
                
                licenses {
                    license {
                        name = 'MIT License'
                        url = 'https://opensource.org/licenses/MIT'
                    }
                }
                
                developers {
                    developer {
                        id = 'tareq-ghassan'
                        name = 'Tareq Abu Saleh'
                        email = 'your-email@example.com'
                    }
                }
                
                scm {
                    connection = 'scm:git:git://github.com/Tareq-Ghassan/GazePointSDK-Android.git'
                    developerConnection = 'scm:git:ssh://github.com/Tareq-Ghassan/GazePointSDK-Android.git'
                    url = 'https://github.com/Tareq-Ghassan/GazePointSDK-Android'
                }
            }
        }
    }
    
    repositories {
        maven {
            url = "https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/"
            credentials {
                username = ossrhUsername
                password = ossrhPassword
            }
        }
    }
}

signing {
    sign publishing.publications.release
}
```

#### Step 5: Publish

```bash
cd android
./gradlew publishReleasePublicationToMavenRepository
```

#### Step 6: Release on Sonatype

1. Login to: `https://s01.oss.sonatype.org/`
2. Go to "Staging Repositories"
3. Find your repository
4. Click "Close" then "Release"

Users can then add:

```gradle
dependencies {
    implementation 'io.github.tareq-ghassan:gazepoint-sdk:2.0.0'
}
```

---

## Version Management

### Semantic Versioning

Follow [semver.org](https://semver.org/):

- **Major** (2.0.0): Breaking API changes
- **Minor** (2.1.0): New features, backward compatible
- **Patch** (2.0.1): Bug fixes, backward compatible

### Files to Update

When releasing a new version, update:

1. **Flutter**:
   - `flutter/pubspec.yaml` → `version:`
   - `flutter/CHANGELOG.md`

2. **iOS**:
   - `ios/GazePointSDK.podspec` → `s.version`
   - `ios/Package.swift` (version is in git tag)

3. **Android**:
   - `android/gazepoint-sdk/build.gradle` → `versionName`
   - `android/gazepoint-sdk/build.gradle` → `versionCode` (increment)

4. **Main README**:
   - Update version badges
   - Update installation instructions

### Synchronize Versions

It's best practice to keep all platform versions synchronized:

```bash
# Use the same version everywhere
VERSION="2.0.0"

# Update all at once
./scripts/bump-version.sh $VERSION  # Create this script
```

---

## Troubleshooting

### pub.dev Issues

**Error: "Package validation failed"**
```bash
# Check detailed errors
flutter pub publish --dry-run
```

**Error: "Unauthorized"**
```bash
# Re-authenticate
dart pub logout
dart pub login
```

### CocoaPods Issues

**Error: "Unable to find a specification"**
```bash
# Update local pods cache
pod repo update
```

**Error: "Tag not found"**
```bash
# Verify tag exists
git tag -l
git push origin 2.0.0
```

### JitPack Issues

**Build fails on JitPack**
- Check logs at: `https://jitpack.io/com/github/Tareq-Ghassan/GazePointSDK-Android/2.1.1/build.log`
- Tags `2.0.0` and `2.1.0` are JitPack `Error`. Use **2.1.1**.
- Common fix: Ensure `build.gradle` has correct `maven-publish` configuration

**404 when trying to use library**
- Trigger build manually: Visit `https://jitpack.io/#Tareq-Ghassan/GazePointSDK-Android`
- Click "Get it" button for your version

### General Tips

1. **Always test before publishing**:
   ```bash
   # pub.dev
   flutter pub publish --dry-run
   
   # CocoaPods
   pod spec lint --allow-warnings
   
   # Android
   ./gradlew build
   ```

2. **Create a pre-release checklist**:
   - [ ] All tests passing
   - [ ] Documentation updated
   - [ ] Version bumped in all files
   - [ ] CHANGELOG updated
   - [ ] Example apps working

3. **Tag releases consistently**:
   ```bash
   git tag -a 2.0.0 -m "Release version 2.0.0"
   git push origin 2.0.0
   ```

4. **Use GitHub Releases** for all platforms:
   - Creates a historical record
   - Provides release notes
   - Required for SPM and JitPack

---

## Quick Reference

### Publish Checklist

- [ ] Run all tests
- [ ] Update version numbers
- [ ] Update CHANGELOG
- [ ] Create git tag
- [ ] Push to GitHub
- [ ] Publish to pub.dev
- [ ] Publish to CocoaPods
- [ ] Create GitHub release (triggers JitPack)
- [ ] Verify all installations work
- [ ] Announce release

### Installation Commands

**Flutter:**
```yaml
dependencies:
  gazepoint_sdk: ^3.0.4
```

**iOS CocoaPods:**
```ruby
pod 'GazePointSDK', :git => 'https://github.com/Tareq-Ghassan/GazePointSDK-iOS.git', :tag => '2.1.1'
```

**iOS SPM:**
```swift
.package(url: "https://github.com/Tareq-Ghassan/GazePointSDK-iOS.git", from: "2.1.1")
```

**Android JitPack:**
```gradle
implementation 'com.github.Tareq-Ghassan:GazePointSDK-Android:2.1.1'
```

---

## Additional Resources

- [pub.dev Publishing Guide](https://dart.dev/tools/pub/publishing)
- [CocoaPods Trunk Guide](https://guides.cocoapods.org/making/getting-setup-with-trunk.html)
- [Swift Package Manager Guide](https://developer.apple.com/documentation/xcode/creating_a_standalone_swift_package_with_xcode)
- [JitPack Documentation](https://jitpack.io/docs/)
- [Maven Central Guide](https://central.sonatype.org/publish/publish-guide/)

---

**Last Updated**: August 13, 2026
