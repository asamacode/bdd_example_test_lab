#!/bin/bash

set -e

gcloud config set project $PROJECT_ID

# Navigate to android directory and build the APKs
pushd android
flutter build apk
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=integration_test/app_test.dart
popd

# Run the tests on Firebase Test Lab
gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \

# Check exit code from Firebase Test Lab
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
  echo "Test on Firebase Test Lab passed."
else
  echo "Test on Firebase Test Lab failed with exit code ${EXIT_CODE}."
fi

exit $EXIT_CODE