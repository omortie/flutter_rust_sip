// FFI-safe wrappers for PJSUA functions

use flutter_rust_bridge::{frb};

use crate::core::{helpers::*, init_logger, managers::{CallStateManager}, types::{DartCallStream, OnIncommingCall, PJSUAError, TransportMode}};

#[frb(init)]
pub fn init_app() {
    init_logger();
}

pub fn init_pjsua(
    local_port: u32,
    transport_mode: TransportMode,
    incoming_call_strategy: OnIncommingCall,
    stun_srv: String,
    uri: String,
) -> Result<i32, PJSUAError> {
    // initialize pjsua
    initialize_pjsua(incoming_call_strategy, local_port, transport_mode, stun_srv).and_then(|_| {
        // Start SIP alive tester task to check alive flag periodically as destroy management
        std::thread::spawn(|| crate::core::managers::sip_alive_tester_task());

        ensure_pj_thread_registered();
        crate::core::helpers::account_setup(uri)
    })
}

pub fn account_setup(uri: String) -> Result<i32, PJSUAError> {
    ensure_pj_thread_registered();
    crate::core::helpers::account_setup(uri)
}

pub fn register_call_stream(call_sink: DartCallStream) -> Result<(), PJSUAError> {
    // Initialize the call state manager singleton
    CallStateManager::new(call_sink);
    Ok(())
}

pub fn mark_sip_alive() {
    crate::core::managers::mark_sip_alive();
}

pub async fn make_call(acc_id: i32, phone_number: String, domain: String) -> Result<i32, PJSUAError> {
    ensure_pj_thread_registered();
    crate::core::helpers::make_call(acc_id, &phone_number, &domain)
}

pub fn hangup_call(call_id: i32) -> Result<(), PJSUAError> {
    ensure_pj_thread_registered();
    crate::core::helpers::hangup_call(call_id)
}
    
pub fn hangup_calls() {
    ensure_pj_thread_registered();
    crate::core::helpers::hangup_calls();
}

pub fn destroy_pjsua() -> Result<i8, PJSUAError> {
    ensure_pj_thread_registered();
    crate::core::managers::destroy_pjsua_manager()
}
