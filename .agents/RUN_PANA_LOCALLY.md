# How to Run Pana Locally

## Prerequisites

1. **Dart SDK** installed (comes with Flutter)
2. **Flutter SDK** installed

## Quick Start

### 1. Navigate to Flutter Package
```bash
cd flutter
```

### 2. Install Pana
```bash
# Install specific version (same as CI)
dart pub global activate pana 0.23.17

# Or install latest version
dart pub global activate pana
```

### 3. Run Pana Analysis
```bash
# Basic analysis
pana

# With detailed output
pana --verbose

# JSON output (same as CI)
pana --json

# Save to file
pana --json > pana-report.json
```

## Understanding the Output

### Score Breakdown
```
Package: gazepoint_sdk v3.0.1

SCORES:
  Overall: XXX/160 points

SECTIONS:
  ✓ Follow Dart file conventions: XX/30
  ✓ Provide documentation: XX/20
  ✓ Platform support: XX/20
  ✓ Pass static analysis: XX/50
  ✓ Support up-to-date dependencies: XX/40
```

### Target Score: 160/160
- Follow Dart file conventions: 30/30
- Provide documentation: 20/20
- Platform support: 20/20
- Pass static analysis: 50/50
- Support up-to-date dependencies: 40/40

## Common Issues & Fixes

### Issue: Files don't match Dart formatter
```bash
# Format all files
dart format lib/

# Check formatting without changes
dart format --set-exit-if-changed lib/
```

### Issue: Missing dartdoc comments
```bash
# Check which files need documentation
dart doc --dry-run
```

### Issue: Analysis errors
```bash
# Run analyzer
dart analyze

# Fix common issues
dart fix --apply
```

## Verify Before Pushing

```bash
# 1. Format code
dart format lib/

# 2. Run analyzer
dart analyze

# 3. Run tests (if any)
flutter test

# 4. Run Pana
pana --json > pana-report.json

# 5. Check score
cat pana-report.json | jq '.scores'
```

## Quick Check Script

Create a file `check-quality.sh`:
```bash
#!/bin/bash
set -e

echo "🔍 Running quality checks..."
echo ""

echo "1️⃣ Formatting..."
dart format lib/ --set-exit-if-changed
if [ $? -eq 0 ]; then
  echo "   ✅ Code is properly formatted"
else
  echo "   ❌ Code needs formatting"
  exit 1
fi

echo ""
echo "2️⃣ Analysis..."
dart analyze
if [ $? -eq 0 ]; then
  echo "   ✅ No analysis issues"
else
  echo "   ❌ Analysis issues found"
  exit 1
fi

echo ""
echo "3️⃣ Pana Analysis..."
pana --json > pana-report.json
SCORE=$(cat pana-report.json | jq -r '.scores.grantedPoints')
MAX=$(cat pana-report.json | jq -r '.scores.maxPoints')

echo "   📊 Score: $SCORE/$MAX"
if [ "$SCORE" -eq "$MAX" ]; then
  echo "   🎉 Perfect score!"
else
  echo "   ⚠️  Not perfect yet"
  cat pana-report.json | jq '.report.sections[] | select(.grantedPoints < .maxPoints)'
fi
```

Make it executable:
```bash
chmod +x check-quality.sh
./check-quality.sh
```

## Troubleshooting

### Pana not found
```bash
# Add Dart global bin to PATH
export PATH="$PATH:$HOME/.pub-cache/bin"

# Or for Flutter:
export PATH="$PATH:$HOME/flutter/.pub-cache/bin"
```

### Pana version mismatch
```bash
# Check current version
pana --version

# Install specific version
dart pub global activate pana 0.23.17
```

### Cache issues
```bash
# Clear pub cache
dart pub cache clean

# Reinstall pana
dart pub global activate pana 0.23.17
```

## Compare with CI

Your CI uses Pana 0.23.17, so install the same version locally:
```bash
dart pub global activate pana 0.23.17
```

Check the version:
```bash
pana --version
# Should output: 0.23.17
```
