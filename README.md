# flutter_rust_sip

A cross-platform SIP (Session Initiation Protocol) client built for Flutter using C/Rust FFI.

Web is supported as a compatibility target only. Since PJSIP cannot be
compiled for web, the public SIP APIs are no-ops when running in a browser.

## Features

- SIP registration and call handling
- High performance via Rust FFI
- SIP Credentials to work with SIP servers

## Getting Started

### Dependencies

- <https://github.com/omortie/pjsip-sys>

Linux: Make sure that these packages are installed on your system

- crypto
- z
- asound (on arch it is called `alsa-lib`)
- ssl
- uuid
- cmake
- ninja
- clang
- pkgconfig
- gtk

#### Ubuntu

```
sudo apt install cmake build-essential ninja-build clang pkg-config libgtk-3-dev openssl libssl-dev libasound2-dev
```

### Build the example

1. Clone the repository:

    ```sh
    git clone https://github.com/omortie/flutter_rust_sip.git
    cd flutter_rust_sip
    ```

2. Go to the `example` and Run the app:

    ```sh
    cd example
    flutter run
    ```

#### Android

For building cross-compile for Android you need:

- Linux host
- A `.env` file in your home directory at `$HOME/cross_compile.env` containing `ANDROID_NDK_HOME` environment variable eg.:

```env
ANDROID_NDK_HOME=/home/mortie/Android/Sdk/ndk/29.0.14206865
```

then just target your Android device and build the example like any other Flutter application

## Regenerating the Rust/Dart bridge

The Rust runtime, Dart runtime, and generator must all use FRB revision
`d1c1957a045825434c86ef6bc936c3299431c5fb` (`2.14.0-beta.2`) from
[FRB PR #3527](https://github.com/fzyzcjy/flutter_rust_bridge/pull/3527).
The Git dependency is intentional until this native-symbol-prefix support is
released; this checkout is not currently publishable to pub.dev.

With Flutter/Dart on `PATH`, run from the repository root:

```sh
cargo install flutter_rust_bridge_codegen --locked \
  --git https://github.com/shri-acha/flutter_rust_bridge \
  --rev d1c1957a045825434c86ef6bc936c3299431c5fb \
  --root target/frb-codegen
flutter pub get
target/frb-codegen/bin/flutter_rust_bridge_codegen generate \
  --skip-fvm-install --no-auto-upgrade-dependency
```

The generator's dependency-version heuristic can warn about these Git pins;
verify the resolved revision in `Cargo.lock` and both `pubspec.lock` files rather
than replacing them with registry versions. Dependency checks remain enabled.
Commit the regenerated Rust and Dart files together. Keep the runtime's default
codegen-version and content-hash checks enabled; do not bypass mismatches.
`native_symbol_prefix: flutter_rust_sip_` isolates this library's FRB dispatch and
content-hash exports from other FRB libraries loaded into the same process. The native asset hook and
library loader configuration are unchanged; the prefix is not a library filename.

Validate with the toolchain pinned in `rust/rust-toolchain.toml`:

```sh
cargo +1.93.1 check --locked
cargo +1.93.1 test --locked
flutter analyze
flutter test test/native_bridge_test.dart
```

The native smoke test exercises the asset hook, strict bridge initialization,
and error serialization without opening a SIP account or an audio device.
It requires the platform's PJSIP build dependencies listed above. It does not
verify live calls or microphone delivery.

## Project Structure

- `lib/` - Flutter/Dart code
- `rust/` - Rust SIP core
- `example/` - A simple example of using SIP lib in Flutter

### Acknowledgement

used [sip-phone-rs](https://github.com/Charles-Schleich/sip-phone-rs) sources as helper inspiration
used [pjsip-sys](https://github.com/omortie/pjsip-sys) as the base Rust binding

## Microphone controls (native platforms)

After `init()` succeeds, `getMicrophoneGain()` reads the last successfully applied capture gain and
`setMicrophoneGain(gain: 1.5)` adjusts it for **all** calls. The supported range
is 0 (mute) through 4; 1 is unchanged input. Invalid/non-finite values and calls
outside the running PJSUA lifecycle return errors. Gain is session-local.

Poll `getMicrophoneLevel()` during active call media, for example every 100 ms,
for a 0..1 input meter. Stop polling on disconnect/disposal and surface errors
as unavailable input. This measures the sound-device capture port, not remote
speaker audio, and does not prove delivery at the remote device. The meter is
an input measurement; applications should show muted state when gain is zero.
Web throws `UnsupportedError` for these APIs because it has no PJSIP audio.

The gain getter uses a primitive-only record of successful setter calls rather
than `pjsua_conf_get_port_info`: bundled `pjsip-sys` binaries can have a different
`PJSUA_MAX_CONF_PORTS` than generated bindings, making that variable-size struct
unsafe to pass across FFI. The value resets to unity on successful initialization;
external native code changing gain directly is not reflected in this getter.
