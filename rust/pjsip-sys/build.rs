extern crate bindgen;

use std::env;
use std::path::PathBuf;
use std::collections::HashSet;


#[derive(Debug)]
struct IgnoreMacros(HashSet<String>);

impl bindgen::callbacks::ParseCallbacks for IgnoreMacros {
    fn will_parse_macro(&self, name: &str) -> bindgen::callbacks::MacroParsingBehavior {
        if self.0.contains(name) {
            bindgen::callbacks::MacroParsingBehavior::Ignore
        } else {
            bindgen::callbacks::MacroParsingBehavior::Default
        }
    }
}

fn main() {
    pkg_config::Config::new().probe("libpjproject").unwrap();
    println!("cargo:rerun-if-changed=wrapper.h");

    let ignored_macros = IgnoreMacros(
        vec![
            "FP_NORMAL".into(),
            "FP_SUBNORMAL".into(),
            "FP_ZERO".into(),
            "FP_INFINITE".into(),
            "FP_NAN".into(),
            "IPPORT_RESERVED".into(),
        ]
        .into_iter()
        .collect(),
    );

    //Libraries inside PJPROEJCT
    println!("cargo:rustc-link-lib=pjsua-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=pjsip-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=pj-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=pjsip-simple-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=pjsua2-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=pjsip-ua-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=pjmedia-codec-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=pjmedia-videodev-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=pjmedia-audiodev-x86_64-pc-linux-gnu");

    println!("cargo:rustc-link-lib=pjmedia-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=pjnath-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=pjlib-util-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=yuv-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=ilbccodec-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=g7221codec-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=gsmcodec-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=resample-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=srtp-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=webrtc-x86_64-pc-linux-gnu");
    println!("cargo:rustc-link-lib=speex-x86_64-pc-linux-gnu");

    // Dependencies
    println!("cargo:rustc-link-lib=ssl");
    println!("cargo:rustc-link-lib=crypto");
    println!("cargo:rustc-link-lib=z");
    println!("cargo:rustc-link-lib=asound");
    println!("cargo:rustc-link-lib=uuid");

    let bindings = bindgen::Builder::default()
        .clang_arg("-L/usr/local/lib")
        .clang_arg("-I/usr/local/include")
        .header("wrapper.h")
        .parse_callbacks(Box::new(ignored_macros))
        .generate()
        .expect("Unable to generate bindings");

    let out_path = PathBuf::from(env::var("OUT_DIR").unwrap());
    bindings
        .write_to_file(out_path.join("bindings.rs"))
        .expect("Couldn't write bindings!");
}
