// FFI-safe wrappers for PJSUA functions

use flutter_rust_bridge::{frb};

use crate::core::{helpers::*, init_logger, managers::{CallManager}, types::{DartCallStream, OnIncommingCall, PJSUAError, TransportMode}};

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
        std::thread::spawn(|| crate::core::managers::call_alive_tester_task());

        ensure_pj_thread_registered();
        crate::core::helpers::account_setup(uri)
    })
}

pub fn register_call_stream(call_sink: DartCallStream) -> Result<(), PJSUAError> {
    // Initialize the call state manager singleton
    CallManager::init(call_sink);
    Ok(())
}

pub fn mark_call_alive(call_id: i32) {
    crate::core::managers::mark_call_alive(call_id);
}

pub async fn make_call(phone_number: String, domain: String) -> Result<i32, PJSUAError> {
    ensure_pj_thread_registered();
    crate::core::managers::make_call(phone_number, domain)
}

pub fn hangup_call(call_id: i32) -> Result<(), PJSUAError> {
    ensure_pj_thread_registered();
    crate::core::managers::hangup_call(call_id)
}

pub fn destroy_pjsua() -> Result<i8, PJSUAError> {
    ensure_pj_thread_registered();
    crate::core::helpers::destroy_pjsua()
}
