// FFI-safe wrappers for telephony functions

use flutter_rust_bridge::{frb};

use crate::core::{types::{OnIncommingCall, TransportMode}, helpers::*};

#[frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
    // Start telephony system
    initialize_telephony(4,OnIncommingCall::AutoAnswer,5070,TransportMode::UDP);
}

#[frb(sync)]
pub fn ffi_account_setup(username: String, password: String, uri: String, p2p: bool) -> i8 {
    ensure_pj_thread_registered();
    return accountSetup(username, password, uri, p2p).unwrap_or(1);
}

// make call ffi
pub async fn ffi_make_call(phone_number: String, domain: String) -> i8 {
    ensure_pj_thread_registered();
    return make_call(&phone_number, &domain).unwrap_or(1);
}

#[no_mangle]
pub extern "C" fn ffi_send_dtmf(digit: u32) -> i8 {
    return send_dtmf(digit).unwrap_or(-1);
}

#[no_mangle]
pub extern "C" fn ffi_hangup_calls() {
    hangup_calls();
}
