#!/bin/sh
set -e
echo "Start: post-clone.sh"

echo "Checking required environment variables ..."
# 1. APP_VERSION
if [ -n "$APP_VERSION" ]; then
    echo "APP_VERSION: Found"
else
    echo "Error: APP_VERSION not found, exiting."
    exit 1
fi

# 2. BUILD_ENV
if [ -n "$BUILD_ENV" ]; then
    echo "BUILD_ENV: Found"
else
    echo "Error: BUILD_ENV not found, exiting."
    exit 1
fi

# 3. APP_CONFIG
if [ -n "$APP_CONFIG" ]; then
    echo "APP_CONFIG: Found"
else
    echo "Error: APP_CONFIG not found, exiting."
    exit 1
fi

# 4. SP_CONFIG
if [ -n "$SP_CONFIG" ]; then
    echo "SP_CONFIG: Found"
else
    echo "Error: SP_CONFIG not found, exiting."
    exit 1
fi

# 5. FIREBASE_IOS
if [ -n "$FIREBASE_IOS" ]; then
    echo "FIREBASE_IOS: Found"
else
    echo "Error: FIREBASE_IOS not found, exiting."
    exit 1
fi

# 6. FIREBASE_ANDROID
if [ -n "$FIREBASE_ANDROID" ]; then
    echo "FIREBASE_ANDROID: Found"
else
    echo "Error: FIREBASE_ANDROID not found, exiting."
    exit 1
fi

# 7. BUILD_PLATFORM
if [ -n "$BUILD_PLATFORM" ]; then
    echo "BUILD_PLATFORM: Found"
else
    echo "Error: BUILD_PLATFORM not found, exiting."
    exit 1
fi

echo "Installing Node.js ..."
curl "https://nodejs.org/dist/v18.16.0/node-v18.16.0.pkg" > "$HOME/Downloads/node-stable.pkg" && sudo installer -store -pkg "$HOME/Downloads/node-stable.pkg" -target "/"
node --version

echo "Writing .env from \$APP_CONFIG ..."
echo $APP_CONFIG | base64 --decode > ./.env

echo "Writing sp-config.json from \$SP_CONFIG ..."
echo $SP_CONFIG | base64 --decode > ./scripts/codemagic-ci/sp-config.json

echo "./ios/Runner/GoogleService-Info.plist --> $BUILD_ENV"
echo $FIREBASE_IOS | base64 --decode > ./ios/Runner/GoogleService-Info.plist

echo "./android/app/google-services.json --> $BUILD_ENV"
echo $FIREBASE_ANDROID | base64 --decode > ./android/app/google-services.json

# Write release notes
if [ -n "$FCI_PULL_REQUEST_NUMBER" ]; then
    echo "$BUILD_ENV Environment Build (PR: $FCI_PULL_REQUEST_NUMBER)" > ./release_notes.txt
else
    echo "$BUILD_ENV Environment Build (Branch: $FCI_BRANCH)" > ./release_notes.txt
fi

echo "End: post-clone.sh"
