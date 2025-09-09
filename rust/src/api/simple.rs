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
    initialize_telephony(incoming_call_strategy, local_port, transport_mode, stun_srv).inspect(|_| {
        std::thread::spawn(|| crate::core::managers::sip_alive_tester_task());
    })
}

pub fn account_setup(uri: String) -> Result<i32, TelephonyError> {
    ensure_pj_thread_registered();
    accountSetup(uri)
}

pub fn register_call_stream(call_sink: DartCallStream) -> Result<(), TelephonyError> {
    // Initialize the call state manager singleton
    CallStateManager::new(call_sink);
    Ok(())
}

pub fn mark_sip_alive() {
    crate::core::managers::mark_sip_alive();
}

pub async fn make_call(acc_id: i32, phone_number: String, domain: String) -> Result<i32, TelephonyError> {
    ensure_pj_thread_registered();
    crate::core::helpers::make_call(acc_id, &phone_number, &domain)
}

pub fn hangup_call(call_id: i32) -> Result<(), TelephonyError> {
    ensure_pj_thread_registered();
    crate::core::helpers::hangup_call(call_id)
}
    
pub fn hangup_calls() {
    ensure_pj_thread_registered();
    crate::core::helpers::hangup_calls();
}

pub fn destroy_telephony() -> Result<i8, TelephonyError> {
    ensure_pj_thread_registered();
    crate::core::managers::destroy_telephony_manager()
}
