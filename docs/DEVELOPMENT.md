# Development notes

## CarPlay

Pinned source: [Ultra-Lite 4a4ffa85](https://github.com/Nyx-Asteria/carplay-ultra-lite-gen5w/tree/4a4ffa85fb28141f3d8ffbf61e8e3e0241885b29/source).

The standalone native segment uses only the verified /info branch at 0x9c20, the original AirPlayCopyServerInfo call, and CFLite routines from the pinned recipe. It copies the primary display, changes only its two physical dimensions, and preserves all other entries. The configuration is private to this mod (pps-scale). Stock mode does not request a patch. The native recipe is generated and checked by the release build; standalone vehicle validation is not separately documented.

The native hook overlaps Ultra-Lite's /info branch. PPS defers its native patch when Ultra-Lite K5 is enabled; a compatible host reads PPS settings. Disable the host and restart if it cannot apply its native recipe. The owner confirmed PPS works with a development Ultra-Lite K5 build on DL322 USA 260507; unrelated host features are outside PPS validation. An installed memory hook cannot be unloaded until process restart. Uninstallation leaves no on-disk system binary modification; any stale private scale file is ignored without the hook.

## Android Auto

The mapped receiver is com.google.android.projection.sink. A relative change of density and real density is applied to each advertised configuration. If HMG-API declares an absolute density override, this mod leaves it alone. Other third-party direct hooks cannot be detected automatically.

## Build and test

Generate the native recipe with python3 tools/build_native.py, then copy the output into the package's recipes/carplay-scaling.recipe. Build the Java hooks against HMG-API and Android API 19. The automated build generates, signs and verifies all release packages; see [build and signing](BUILD.md).

Run pure Java tests:
```sh
mkdir -p build/tests
javac -d build/tests src/hmgapi/mods/scaling/Scale.java tests/ScaleTest.java
java -cp build/tests ScaleTest
```

Validate that the generated recipe contains exactly one branch and one verify region, then check stock hashes, hook logs, touch alignment, reconnects and wired/wireless behavior on the car while parked.
