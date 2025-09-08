// FFI-safe wrappers for telephony functions

use flutter_rust_bridge::{frb};

use crate::core::{helpers::*, init_logger, managers::{CallStateManager}, types::{DartCallStream, OnIncommingCall, TelephonyError, TransportMode}};

#[frb(init)]
pub fn init_app() {
    init_logger();
}

pub fn init_telephony(
    local_port: u32,
    transport_mode: TransportMode,
    incoming_call_strategy: OnIncommingCall,
    stun_srv: String,
) -> Result<i8, TelephonyError> {
    // initialize telephony
    initialize_telephony(incoming_call_strategy, local_port, transport_mode, stun_srv)
}

pub fn account_setup(uri: String, call_sink: DartCallStream) -> Result<i32, TelephonyError> {
    ensure_pj_thread_registered();
    accountSetup(uri).and_then(|id| {
        // Initialize the call state manager singleton
        CallStateManager::new(call_sink);
        std::thread::spawn(|| crate::core::managers::sip_alive_tester_task());
        Ok(id)
    })
}

pub fn mark_sip_alive() {
    crate::core::managers::mark_sip_alive();
}

pub async fn make_call(phone_number: String, domain: String) -> Result<i32, TelephonyError> {
    ensure_pj_thread_registered();
    makeCall(&phone_number, &domain)
}

pub fn hangup_call(call_id: i32) -> Result<(), TelephonyError> {
    ensure_pj_thread_registered();
    hangupCall(call_id)
}
    
pub fn hangup_calls() {
    hangupCalls();
}

pub fn destroy_telephony() -> Result<i8, TelephonyError> {
    crate::core::helpers::destroy_telephony()
}
