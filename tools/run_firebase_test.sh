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

# Run for iOS
output="../build/ios_integ"
product="build/ios_integ/Build/Products"
dev_target="17.2"
PRODUCT_NAME="Release-iphoneos"
TEST_RUNNER="iphoneos$dev_target-arm64.xctestrun"

flutter clean

flutter build ios integration_test/app_test.dart --simulator

pushd ios
xcodebuild -workspace Runner.xcworkspace -config Release -derivedDataPath $output -sdk iphoneos build-for-testing
popd

pushd $product
zip -r "ios_tests.zip" $PRODUCT_NAME $TEST_RUNNER
popd

gcloud firebase test ios run \
  --test "build/ios_integ/Build/Products/ios_tests.zip" \

# Check exit code from Firebase Test Lab
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
  echo "Test on Firebase Test Lab passed."
else
  echo "Test on Firebase Test Lab failed with exit code ${EXIT_CODE}."
fi

exit $EXIT_CODE