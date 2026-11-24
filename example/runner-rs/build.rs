// Copyright 2026 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// flutter-rust-runner-version: 10

use std::{env, path::PathBuf};

fn main() {
    let manifest_dir = PathBuf::from(env::var_os("CARGO_MANIFEST_DIR").unwrap());
    // Cargo reports custom release-derived profiles as "release". rlutter
    // supplies the Dart mode explicitly so profile links the profiling engine.
    println!("cargo:rerun-if-env-changed=FLUTTER_RS_BUILD_MODE");
    let profile = env::var("FLUTTER_RS_BUILD_MODE")
        .unwrap_or_else(|_| env::var("PROFILE").unwrap());
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap();
    let target_arch = env::var("CARGO_CFG_TARGET_ARCH").unwrap();
    let platform = match (target_os.as_str(), target_arch.as_str()) {
        ("linux", "x86_64") => "linux-x64",
        ("windows", "x86_64") => "windows-x64",
        ("android", "aarch64") => "android-arm64",
        ("android", "x86_64") => "android-x64",
        ("android", "arm") => "android-arm",
        ("android", "riscv64") => "android-riscv64",
        other => panic!("The Flutter Rust shell does not support {other:?} yet."),
    };
    let variant = format!("{platform}-{profile}");
    let engine_dir = manifest_dir.join("../.dart_tool/flutter_rs/sdk/lib").join(&variant);
    let engine_name = if target_os == "android" { "flutter" } else { "flutter_rust_engine" };
    let engine_library = engine_dir.join(if target_os == "windows" {
        "flutter_rust_engine.dll.lib".to_owned()
    } else { format!("lib{engine_name}.so") });
    assert!(
        engine_library.is_file(),
        "Flutter Rust engine library is missing: {}. Run `rlutter build` to install it.",
        engine_library.display()
    );
    println!("cargo:rerun-if-changed={}", engine_library.display());
    println!("cargo:rustc-link-search=native={}", engine_dir.display());
    if target_os == "windows" {
        println!("cargo:rustc-link-lib=dylib=flutter_rust_engine.dll");
    } else {
        println!("cargo:rustc-link-lib=dylib={engine_name}");
    }
    if target_os == "android" {
        // System.loadLibrary normally loads locally. Android's global group
        // must include Rust plugins for Dart process() and native providers.
        println!("cargo:rustc-link-arg=-Wl,-z,global");
        // The engine ships inside the APK's jniLibs/<abi>/ next to this
        // cdylib, so resolve it relative to wherever this library is loaded.
        println!("cargo:rustc-link-arg=-Wl,-rpath,$ORIGIN");
    } else if target_os == "windows" {
        let manifest = PathBuf::from(env::var_os("OUT_DIR").unwrap()).join("app.manifest");
        std::fs::write(&manifest, r#"<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3"><security><requestedPrivileges><requestedExecutionLevel level="asInvoker" uiAccess="false"/></requestedPrivileges></security></trustInfo>
  <application xmlns="urn:schemas-microsoft-com:asm.v3"><windowsSettings>
    <dpiAwareness xmlns="http://schemas.microsoft.com/SMI/2016/WindowsSettings">PerMonitorV2</dpiAwareness>
    <activeCodePage xmlns="http://schemas.microsoft.com/SMI/2019/WindowsSettings">UTF-8</activeCodePage>
  </windowsSettings></application>
  <dependency><dependentAssembly><assemblyIdentity type="win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0" processorArchitecture="*" publicKeyToken="6595b64144ccf1df" language="*"/></dependentAssembly></dependency>
</assembly>"#).unwrap();
        println!("cargo:rustc-link-arg-bin=flutter_rust_sip_example=/MANIFEST:EMBED");
        println!("cargo:rustc-link-arg-bin=flutter_rust_sip_example=/MANIFESTINPUT:{}", manifest.display());
    } else {
        // `$ORIGIN/libs` first so a bundle produced by `rlutter build linux`
        // (engine and native plugin libraries copied into `<exe dir>/libs`; not
        // `lib/`, which plugins such as GStreamer wrappers treat as a bundled
        // third-party library directory) is relocatable; the absolute engine
        // path remains as the in-tree fallback.
        // --disable-new-dtags emits DT_RPATH rather than DT_RUNPATH, so the
        // path also applies to libraries the engine/Dart FFI dlopens by bare name.
        println!("cargo:rustc-link-arg=-Wl,--disable-new-dtags");
        println!("cargo:rustc-link-arg=-Wl,-rpath,$ORIGIN/libs");
        println!("cargo:rustc-link-arg=-Wl,-rpath,{}", engine_dir.display());
        println!("cargo:rustc-link-arg=-Wl,--export-dynamic");
    }
    println!("cargo::rustc-env=FLUTTER_RS_PROFILE={profile}");
    println!("cargo::rustc-env=FLUTTER_RS_ENGINE_VARIANT={variant}");
}
