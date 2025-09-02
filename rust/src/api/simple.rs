// FFI-safe wrappers for telephony functions

use flutter_rust_bridge::{frb};

use crate::core::{dart_types::{CallState, SessionState}, helpers::*, init_logger, managers::{push_session_state_update, CallManager}, types::{DartCallStream, DartSessionStream, OnIncommingCall, TelephonyError, TransportMode}};


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
    sink: DartSessionStream
) -> Result<(), TelephonyError> {
    // initialize telephony
    return initialize_telephony(0, incoming_call_strategy, local_port, transport_mode).and_then(|_| {
        // register session manager
        let session = crate::core::managers::SessionManager::new(session_id, sink);
        session.push_event(SessionState::Initialized)
    });
}

pub fn account_setup(session_id: i64, username: String, password: String, uri: String, p2p: bool) -> Result<(), TelephonyError> {
    ensure_pj_thread_registered();
    return accountSetup(username, password, uri, p2p).and_then(|_| {
        push_session_state_update(session_id, SessionState::Running)
    });
}

pub async fn make_call(phone_number: String, domain: String, sink: DartCallStream) -> Result<(), TelephonyError> {
    ensure_pj_thread_registered();
    return makeCall(&phone_number, &domain).and_then(|call_id| {
        // add a new call manager to the registry
        let call = CallManager::new(call_id, sink);
        call.push_event(CallState::Calling)
    });
}
    
pub fn ffi_hangup_calls() {
    hangup_calls();
}
