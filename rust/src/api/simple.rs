// FFI-safe wrappers for telephony functions

use flutter_rust_bridge::{frb};

use crate::core::{helpers::*, init_logger, managers::{CallStateManager}, types::{DartCallStream, OnIncommingCall, TelephonyError, TransportMode}};

#[frb(init)]
pub fn init_app() {
    init_logger();
}

lazy_static::lazy_static! {
    static ref SESSION_COUNTER: std::sync::Mutex<i64> = std::sync::Mutex::new(0);
}

pub fn init_telephony(
    uri: String,
    local_port: u32,
    transport_mode: TransportMode,
    incoming_call_strategy: OnIncommingCall,
    call_sink: DartCallStream,
) -> Result<(), TelephonyError> {
    // initialize telephony
    initializeTelephony(0, incoming_call_strategy, local_port, transport_mode).and_then(|_| {
        ensure_pj_thread_registered();
        accountSetup(uri).and_then(|_| {
            // create a call manager
            CallStateManager::new(call_sink);
            Ok(())
        })
    })
}

pub async fn make_call(phone_number: String, domain: String) -> Result<i32, TelephonyError> {
    ensure_pj_thread_registered();
    makeCall(&phone_number, &domain)
}

pub fn answer_call(call_id: i32) -> Result<(), TelephonyError> {
    ensure_pj_thread_registered();
    answerCall(call_id)
}

pub fn hangup_call(call_id: i32) -> Result<(), TelephonyError> {
    ensure_pj_thread_registered();
    hangupCall(call_id)
}
    
pub fn hangup_calls() {
    ensure_pj_thread_registered();
    hangupCalls();
}
