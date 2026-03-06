package com.example.flutter_rust_sip_example

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // Initialize Android NDK context for PJSIP
    // https://github.com/dart-lang/sdk/issues/46027
    init {
        System.loadLibrary("flutter_rust_sip")
    }
}
