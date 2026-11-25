#!/bin/sh
set -eu
: "${HMG_API:?HMG-API checkout required}"
: "${ANDROID_JAR:?Android API 19 android.jar required}"
: "${D8:?Android SDK d8 required}"
cd "$(dirname "$0")"
root=$PWD
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
rm -rf dist
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
expected_uuid=""
case "$version" in
    *-rc.*) ;;
    *) expected_uuid="d515981b-afc8-8230-ae0f-62d32de366bc"
       : "${SIGNING_KEY:?Production signing key required}"
       actual_uuid=$(java -cp "${HMGAPI_CP:-$tmp/runtime}" hmgapi.engine.Signing uuid "$SIGNING_KEY.pub")
       test "$actual_uuid" = "$expected_uuid" || { echo "Wrong production author UUID" >&2; exit 1; };;
esac
if [ -z "${SIGNING_KEY:-}" ]; then
    case "$version" in *-rc.*) ;; *) echo "Production signing key required" >&2; exit 1;; esac
    umask 077
    SIGNING_KEY="$tmp/test.key"
    java -cp "${HMGAPI_CP:-$tmp/runtime}" hmgapi.engine.Signing keygen "$SIGNING_KEY"
fi
java -cp "${HMGAPI_CP:-$tmp/runtime}" hmgapi.engine.Signing sign "$tmp/mod" "$SIGNING_KEY"
if [ -n "$expected_uuid" ]; then
    java -cp "${HMGAPI_CP:-$tmp/runtime}" hmgapi.engine.Signing verify "$tmp/mod" "$expected_uuid"
else
    java -cp "${HMGAPI_CP:-$tmp/runtime}" hmgapi.engine.Signing verify "$tmp/mod"
fi
(cd "$tmp/mod" && find . -type f | LC_ALL=C sort | zip -0 -q -X -D "$tmp/package.zip" -@)
archive="$root/dist/phone-projection-scaling-$version.zip"
mv "$tmp/package.zip" "$archive"
unzip -t "$archive"
# Wireless CP fork convention: signed mod archive, NEMESIS package and USB archive.
# Also provide the HMG-API USB wrapper as Comfort does.
: "${HMGAPI_SDK:?Unpacked official HMG-API SDK required for packaging}"
sh "$HMGAPI_SDK/bin/mknemesismod.sh" "$archive" "$root/dist"
python3 - "$archive" <<'PY'
import sys, zipfile
from pathlib import Path
p = Path(sys.argv[1])
with zipfile.ZipFile(p.with_name(p.stem + "-hmgapi-usb.zip"), "w", zipfile.ZIP_STORED) as z:
    z.write(p, "HMGAPI/updates/" + p.name)
for f in p.parent.glob("*.zip"):
    with zipfile.ZipFile(f) as z:
        if z.testzip() is not None:
            raise RuntimeError("Invalid archive: " + str(f))
PY
(cd dist && sha256sum *.zip > SHA256SUMS)
printf '%s\n' "Bundle input: phone-projection-scaling $version https://github.com/Nyx-Asteria/Phone-Projection-Scaling/releases/download/v$version/$(basename "$archive") $(sha256sum < "$archive" | cut -d' ' -f1)"
