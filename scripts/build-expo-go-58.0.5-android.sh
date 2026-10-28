#!/bin/bash

set -euxo pipefail

if [ -z "${IN_PROJECT_DEV_SHELL:-}" ]; then
    echo "⚠️ Not in a Nix environment. Re-executing inside 'nix develop'..."
    exec nix develop --command bash "$0" "$@"
fi

git clone --branch "hermes-v260318099.0.2" --depth 1 https://github.com/meta/hermes.git

export REACT_NATIVE_OVERRIDE_HERMES_DIR="$(pwd)/hermes"

git clone --revision "e13d88e3774c6cfbd5da1ff3cad73b0efb8afcc8" --depth 1 https://github.com/expo/expo.git

cd expo

git submodule set-url react-native-lab/react-native https://github.com/expo/react-native.git
git submodule update --init --recursive
pnpm install
pnpm setup:native
(cd packages/expo && pnpm build)

(cd react-native-lab/react-native && yarn --cwd install --frozen-lockfile && yarn --cwd packages/react-native-codegen build)

cd apps/expo-go
cd android

export CMAKE_BUILD_PARALLEL_LEVEL=1 # TODO: Limit performance on GitHub Actions only
export GRADLE_OPTS="-Xmx4g -XX:MaxMetaspaceSize=512m -XX:+UseG1GC" # TODO: Limit performance on GitHub Actions only
./gradlew app:assembleRelease -PreactNativeArchitectures=arm64-v8a --no-daemon --max-workers=1 # TODO: Limit performance on GitHub Actions only

echo "Expo Go 58.0.5 built successfully!"
