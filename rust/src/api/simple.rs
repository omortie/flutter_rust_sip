// FFI-safe wrappers for telephony functions

use flutter_rust_bridge::{frb};

use crate::{core::{dart_types::CallState, helpers::*, init_logger, types::{OnIncommingCall, TelephonyError, TransportMode}}, frb_generated::StreamSink};


#[frb(init)]
pub fn init_app() {
    init_logger();
}

lazy_static::lazy_static! {
    static ref SESSION_COUNTER: std::sync::Mutex<i64> = std::sync::Mutex::new(0);
}

#[frb(sync)]
pub fn create_new_session() -> i64 {
    let mut session_counter = SESSION_COUNTER.lock().unwrap();
    *session_counter += 1;
    *session_counter
}

pub fn init_telephony(
    session_id: i64,
    local_port: u32,
    transport_mode: TransportMode,
    incoming_call_strategy: OnIncommingCall,
    sink: StreamSink<CallState>
) -> Result<(), TelephonyError> {
    // initialize telephony
    return initialize_telephony(0, incoming_call_strategy, local_port, transport_mode).map(|_| ());
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
pub fn ffi_hangup_calls() {
    hangup_calls();
}
