# Build and signing

Requires JDK 17, Android API 19, d8, clang, ld.lld, Python 3 with pyelftools, zip, unzip, and an HMG-API source checkout. CI pins HMG-API to 45c16fd438b620c71a17b7c33f799f7025baa564.

Set HMG_API, ANDROID_JAR and D8 to absolute paths, then run sh build.sh. The build compiles Java, runs ScaleTest, generates and structurally checks the native recipe, produces the dex hook archive, signs and verifies the package and checks the ZIP CRCs. Output is in dist/.

An RC build without SIGNING_KEY generates a disposable private key in a temporary directory. It is never published. Each such build has a different author UUID and cannot update a previously installed differently signed build. Uninstall before switching. For a production build supply SIGNING_KEY pointing to a securely backed-up HMG-API author key (and adjacent .pub). Never commit private keys. Production versions refuse to build without a key.

The RC workflow publishes only after build and checks succeed. Vehicle testing is separate.
