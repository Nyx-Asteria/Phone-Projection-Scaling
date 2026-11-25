#!/bin/sh
set -eu
: "${HMG_API:?HMG-API checkout required}"
: "${ANDROID_JAR:?Android API 19 android.jar required}"
: "${D8:?Android SDK d8 required}"
cd "$(dirname "$0")"
root=$PWD
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/stubs" "$tmp/runtime" "$tmp/classes" "$tmp/tests" "$tmp/dex" "$tmp/mod/recipes" dist
find "$HMG_API/core/runtime/stubs" -name '*.java' > "$tmp/stubs.args"
find "$HMG_API/core/runtime/java" -name '*.java' > "$tmp/runtime.args"
find src -name '*.java' > "$tmp/sources.args"
javac --release 8 -cp "$ANDROID_JAR" -d "$tmp/stubs" @"$tmp/stubs.args"
javac --release 8 -cp "$ANDROID_JAR:$tmp/stubs" -d "$tmp/runtime" @"$tmp/runtime.args"
javac --release 8 -cp "$ANDROID_JAR:$tmp/runtime" -d "$tmp/classes" @"$tmp/sources.args"
javac --release 8 -cp "$tmp/classes" -d "$tmp/tests" tests/ScaleTest.java
java -cp "$tmp/classes:$tmp/tests" ScaleTest
echo "Scale regression tests passed"
"${PYTHON:-python3}" tools/build_native.py "$tmp/native"
cp "$tmp/native/carplay-scaling.recipe" "$tmp/mod/recipes/"
"${PYTHON:-python3}" tests/check_recipe.py "$tmp/mod/recipes/carplay-scaling.recipe"
jar cf "$tmp/classes.jar" -C "$tmp/classes" hmgapi
"$D8" --min-api 19 --lib "$ANDROID_JAR" --classpath "$tmp/runtime" --output "$tmp/dex" "$tmp/classes.jar"
jar cMf "$tmp/mod/hooks.jar" -C "$tmp/dex" classes.dex
cp mod.json settings.json "$tmp/mod/"
version=$(python3 -c 'import json; print(json.load(open("mod.json"))["version"])')
if [ -z "${SIGNING_KEY:-}" ]; then
    case "$version" in *-rc.*) ;; *) echo "Production signing key required" >&2; exit 1;; esac
    umask 077
    SIGNING_KEY="$tmp/test.key"
    java -cp "${HMGAPI_CP:-$tmp/runtime}" hmgapi.engine.Signing keygen "$SIGNING_KEY"
fi
java -cp "${HMGAPI_CP:-$tmp/runtime}" hmgapi.engine.Signing sign "$tmp/mod" "$SIGNING_KEY"
java -cp "${HMGAPI_CP:-$tmp/runtime}" hmgapi.engine.Signing verify "$tmp/mod"
(cd "$tmp/mod" && find . -type f | LC_ALL=C sort | zip -0 -q -X -D "$tmp/package.zip" -@)
archive="$root/dist/phone-projection-scaling-$version.zip"
mv "$tmp/package.zip" "$archive"
unzip -t "$archive"
(cd dist && sha256sum "phone-projection-scaling-$version.zip" > "phone-projection-scaling-$version.zip.sha256")
