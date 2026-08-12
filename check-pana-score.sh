#!/bin/bash
# Quick script to check Pana score locally

set -e

echo "╔════════════════════════════════════════════════╗"
echo "║     Running Local Pana Analysis                ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found"
    echo "Please run this script from the flutter/ directory"
    exit 1
fi

# Check if pana is installed
if ! command -v pana &> /dev/null; then
    echo "📦 Pana not found. Installing..."
    dart pub global activate pana 0.23.17
    echo "✅ Pana installed"
    echo ""
fi

# Check pana version
PANA_VERSION=$(pana --version 2>&1 | head -1 || echo "unknown")
echo "📊 Pana version: $PANA_VERSION"
echo ""

# Run analysis
echo "⏳ Running analysis (this may take 30-60 seconds)..."
echo ""

pana --json > pana-report.json 2>&1 || true

# Check if report was generated
if [ ! -f "pana-report.json" ]; then
    echo "❌ Failed to generate Pana report"
    exit 1
fi

# Extract scores
SCORE=$(cat pana-report.json | jq -r '.scores.grantedPoints' 2>/dev/null || echo "0")
MAX=$(cat pana-report.json | jq -r '.scores.maxPoints' 2>/dev/null || echo "160")

echo "╔════════════════════════════════════════════════╗"
echo "║            PANA SCORE RESULTS                  ║"
echo "╠════════════════════════════════════════════════╣"
printf "║  Overall Score: %3d / %3d points               ║\n" "$SCORE" "$MAX"
echo "╠════════════════════════════════════════════════╣"

# Show section breakdown
cat pana-report.json | jq -r '.report.sections[] | "║  " + (if .grantedPoints == .maxPoints then "✅" else "⚠️ " end) + " " + .title + ": " + (.grantedPoints|tostring) + "/" + (.maxPoints|tostring) + " pts"' 2>/dev/null || echo "║  Unable to parse sections"

echo "╚════════════════════════════════════════════════╝"
echo ""

# Show issues if not perfect
if [ "$SCORE" -ne "$MAX" ]; then
    echo "⚠️  Issues found:"
    echo ""
    cat pana-report.json | jq -r '.report.sections[] | select(.grantedPoints < .maxPoints) | .summary' | head -20
    echo ""
    echo "💡 To fix formatting issues, run: dart format lib/"
fi

# Final verdict
if [ "$SCORE" -eq "$MAX" ]; then
    echo "🎉 Perfect score! Ready to merge!"
    exit 0
else
    echo "📝 Score: $SCORE/$MAX - needs improvement"
    exit 1
fi
