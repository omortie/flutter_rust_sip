// FFI-safe wrappers for PJSUA functions

use flutter_rust_bridge::{frb};

use crate::core::{helpers::*, init_logger, managers::CallManager, pj_worker::get_pjsip_worker, types::{DartCallStream, OnIncommingCall, PJSUAError}};

#[frb(init)]
pub fn init_app() {
    init_logger();
}

pub fn init_pjsua(
    local_port: u32,
    incoming_call_strategy: OnIncommingCall,
    stun_srv: String,
    uri: String,
    username: String,
    password: String,
) -> Result<i32, PJSUAError> {
    // initialize pjsua
    initialize_pjsua(incoming_call_strategy, local_port, stun_srv).and_then(|_| {
        // Start SIP alive tester task to check alive flag periodically as destroy management
        std::thread::spawn(|| crate::core::managers::call_alive_tester_task());

        // Setup account
        get_pjsip_worker().execute_sync(move || {
            crate::core::helpers::account_setup(uri, username, password)
        })
    })
}

pub fn register_call_stream(call_sink: DartCallStream) -> Result<(), PJSUAError> {
    // Initialize the call state manager singleton
    CallManager::init(call_sink);
    Ok(())
}

pub fn mark_call_alive(call_id: i32) {
    // Directly mark the call alive via the CallManager; remove use of undefined `sender`.
    crate::core::managers::mark_call_alive(call_id);
}

pub async fn make_call(phone_number: String, domain: String) -> Result<i32, PJSUAError> {
    get_pjsip_worker().execute_sync(move || {
        crate::core::managers::make_call(phone_number, domain)
    })
}

pub fn hangup_call(call_id: i32) -> Result<(), PJSUAError> {
    get_pjsip_worker().execute_sync(move || {
        crate::core::managers::hangup_call(call_id)
    })
}

pub fn destroy_pjsua() -> Result<i8, PJSUAError> {
    get_pjsip_worker().execute_sync(move || {
        crate::core::managers::destroy_pjsua()
    })
}
