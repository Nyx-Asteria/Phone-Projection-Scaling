# Development notes

CarPlay is deliberately not hooked yet. Isolate the native `/info` scaling code from Ultra-Lite, validate its range and semantics, and verify coexistence before enabling the CarPlay setting. Do not ship an overlapping native recipe. Verify the Android Auto receiver package and hook ordering on the target firmware; avoid combining with other density mods. Build/signing integration and physical testing remain pending.

Run the pure Java tests with:

```sh
mkdir -p build/tests
javac -d build/tests src/hmgapi/mods/scaling/Scale.java tests/ScaleTest.java
java -cp build/tests ScaleTest
```
