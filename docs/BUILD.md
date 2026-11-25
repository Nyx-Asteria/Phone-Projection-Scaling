# Build and signing

Requires JDK 17, Android API 19, d8, clang, ld.lld, Python 3 with pyelftools, zip, unzip, and an HMG-API source checkout. CI pins HMG-API to 45c16fd438b620c71a17b7c33f799f7025baa564.

Set HMG_API, ANDROID_JAR and D8 to absolute paths, then run sh build.sh. The build compiles Java, runs ScaleTest, generates and structurally checks the native recipe, produces the dex hook archive, signs and verifies the package and checks the ZIP CRCs. Output is in dist/.

An RC build without SIGNING_KEY generates a disposable private key in a temporary directory. It is never published. Each such build has a different author UUID and cannot update a previously installed differently signed build. Uninstall before switching. For a production build supply SIGNING_KEY pointing to a securely backed-up HMG-API author key (and adjacent .pub). Never commit private keys. Production versions refuse to build without a key.

The release workflow publishes only after build and checks succeed. Vehicle testing is separate.

The unpacked official SDK must also be supplied as HMGAPI_SDK. Release assets follow the wireless CP fork naming convention: `<id>-<version>.zip`, `-nemesis.zip`, `-nemesis-package.zip`, plus a Comfort-style `-hmgapi-usb.zip` and SHA256SUMS. Bundle consumers should pin the bare signed mod ZIP and its checksum.

## Permanent release signing

Author UUID: `d515981b-afc8-8230-ae0f-62d32de366bc`.

Repository Actions secrets MOD_KEY and MOD_KEY_PUB contain base64 of the respective key files. A matching stable version tag activates permanent signing, checks the public key UUID before signing and verifies the signed package against that UUID. Incorrect or absent keys fail the build. Temporary key files are deleted even on failure. Stable releases are published automatically after a successful matching version-tag build, tests and signature verification. RC builds continue to use disposable keys; uninstall them before installing the permanently signed build. No production key material is stored in Git.

## Release policy

Every release requires a version-specific, human-written full changelog at `.github/release-notes/v<version>.md`, with a `## Changelog` section covering all changes since the previous release, compatibility, known limitations, installation and downloads. No generated commit-list fallback or draft releases. The workflow appends actual SHA-256 checksums. Prereleases are never marked Latest. Existing published versions are not overwritten. Stable versions require a matching Git tag; RC versions can publish from main or a matching tag. Do not tag a stable version until vehicle validation and release notes are complete.
