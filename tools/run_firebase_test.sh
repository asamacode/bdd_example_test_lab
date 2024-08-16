#!/bin/bash

set -e

gcloud config set project $PROJECT_ID

# Build the APKs
flutter build apk --release
flutter build apk --debug --target=integration_test/app_test.dart

# Run the tests on Firebase Test Lab
TEST_RESULTS=$(gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/flutter-apk/app-release.apk \
  --test build/app/outputs/flutter-apk/app-release-androidTest.apk \
  --device model=Nexus6,version=27,locale=en,orientation=portrait)

# Extract the results URL
RESULTS_URL=$(echo "$TEST_RESULTS" | grep -oP 'Test results will be streamed to \K(https?://[^\s]+)')
echo "Test results available at: $RESULTS_URL"