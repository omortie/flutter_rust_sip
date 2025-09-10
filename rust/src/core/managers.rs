extern crate pjsip as pj_sys;

use std::{
    collections::HashMap,
    sync::{Arc, Mutex},
    time::Duration,
};

use log::info;

use crate::{
    core::{
        dart_types::{CallInfo, CallState},
        types::DartCallStream,
    },
    utils::pj_str_to_string,
};

pub struct CallHeartbeat {
    pub last_live_mark: std::time::SystemTime,
}

// Global registry of call manager
lazy_static::lazy_static! {
    static ref CALL_MANAGER: Mutex<Option<Arc<CallManager>>> = Mutex::new(None);
    static ref CALL_REGISTRY: Mutex<HashMap<i32, CallHeartbeat>> = Mutex::new(HashMap::new());
}

pub struct CallManager {
    pub update_stream: DartCallStream,
}

impl CallManager {
    pub fn init(update_stream: DartCallStream) -> Arc<Self> {
        // Acquire the registry lock once and do check+insert while holding it
        let mut registry = CALL_MANAGER.lock().expect("CALL_REGISTRY lock poisoned");

        if let Some(existing) = registry.as_ref() {
            return existing.clone();
        }

        // Create the manager while holding the lock to avoid races, store it and return it.
        let manager = Arc::new(CallManager { update_stream });

        *registry = Some(manager.clone());

        manager
    }

    pub fn push_event(&self, ci: CallInfo) {
        self.update_stream.add(ci).unwrap_or(());
    }
}

pub fn push_call_state_update(call_id: pj_sys::pjsua_call_id, ci: pj_sys::pjsua_call_info) {
    // convert to your CallState enum
    let state = match ci.state {
        s if s == pj_sys::pjsip_inv_state_PJSIP_INV_STATE_NULL => CallState::Null,
        s if s == pj_sys::pjsip_inv_state_PJSIP_INV_STATE_CALLING => CallState::Calling,
        s if s == pj_sys::pjsip_inv_state_PJSIP_INV_STATE_INCOMING => CallState::Incoming,
        s if s == pj_sys::pjsip_inv_state_PJSIP_INV_STATE_EARLY => CallState::Early,
        s if s == pj_sys::pjsip_inv_state_PJSIP_INV_STATE_CONNECTING => CallState::Connecting,
        s if s == pj_sys::pjsip_inv_state_PJSIP_INV_STATE_CONFIRMED => CallState::Confirmed,
        s if s == pj_sys::pjsip_inv_state_PJSIP_INV_STATE_DISCONNECTED => CallState::Disconnected,
        _ => CallState::Disconnected,
    };

    // lock once, clone Arc out, then drop the guard to avoid holding the mutex across .push_event
    let guard = CALL_MANAGER.lock().expect("CALL_REGISTRY lock poisoned");
    let maybe_manager = guard.as_ref().cloned();
    drop(guard);

    if let Some(call_manager) = maybe_manager {
        call_manager.push_event(CallInfo {
            call_id: call_id,
            call_url: pj_str_to_string(ci.remote_contact),
            state,
        });
    }
}

pub fn mark_call_alive(call_id: i32) {
    let mut call_registry = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");
    let maybe_heartbeat = call_registry.get_mut(&call_id);

    if let Some(heartbeat) = maybe_heartbeat {
        heartbeat.last_live_mark = std::time::SystemTime::now();
    }
}

pub fn call_alive_tester_task() {
    loop {
        {
            let call_registry = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");
            for (&call_id, heartbeat) in call_registry.iter() {
                println!("Checking call {} for heartbeat", call_id);
                if let Ok(elapsed) = heartbeat.last_live_mark.elapsed() {
                    if elapsed > Duration::from_secs(5) {
                        // Call is considered dead, hang up
                        hangup_call(call_id).unwrap_or(());
                    }
                }
            }
        }

        std::thread::sleep(Duration::from_secs(1));
    }
}

pub fn make_call(
    phone_number: String,
    domain: String,
) -> Result<i32, crate::core::types::PJSUAError> {
    super::helpers::ensure_pj_thread_registered();
    crate::core::helpers::make_call(&phone_number, &domain).map(|call_id| {
        let mut call_registry = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");
        call_registry.insert(
            call_id,
            CallHeartbeat {
                last_live_mark: std::time::SystemTime::now(),
            },
        );
        call_id
    })
}

pub fn hangup_call(call_id: i32) -> Result<(), crate::core::types::PJSUAError> {
    super::helpers::ensure_pj_thread_registered();
    crate::core::helpers::hangup_call(call_id).map(|_| {
        let mut call_registry = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");
        if call_registry.remove(&call_id).is_some() {
            info!("Removed call {} from registry", call_id);
        } else {
            info!("Call {} not found in registry", call_id);
        }
    })
}

pub fn destroy_pjsua() -> Result<i8, crate::core::types::PJSUAError> {
    super::helpers::ensure_pj_thread_registered();
    crate::core::helpers::hangup_calls();
    crate::core::helpers::destroy_pjsua().inspect(|_| {
        let mut call_registry = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");
        call_registry.clear();
        info!("Cleared call registry on PJSUA destroy");
    })
}