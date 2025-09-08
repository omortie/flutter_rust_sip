extern crate pjsip as pj;

use std::sync::{Arc, Mutex};

use crate::core::{
    dart_types::{CallInfo, CallState}, helpers::ensure_pj_thread_registered, types::{DartCallStream, TelephonyError}
};

// Global registry of call manager
lazy_static::lazy_static! {
    static ref CALL_REGISTRY: Mutex<Option<Arc<CallStateManager>>> = Mutex::new(None);
}

pub struct CallStateManager {
    pub update_stream: DartCallStream,
    pub last_alive_mark: std::sync::Mutex<std::time::SystemTime>,
}

impl CallStateManager {
    pub fn new(update_stream: DartCallStream) -> Arc<Self> {
        // Acquire the registry lock once and do check+insert while holding it
        let mut registry = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");

        if let Some(existing) = registry.as_ref() {
            return existing.clone();
        }

        // Create the manager while holding the lock to avoid races, store it and return it.
        let manager = Arc::new(CallStateManager {
            update_stream,
            last_alive_mark: std::sync::Mutex::new(std::time::SystemTime::now()),
        });

        *registry = Some(manager.clone());

        manager
    }

    pub fn push_event(
        &self,
        call_id: pj::pjsua_call_id,
        state: CallState,
    ) -> Result<(), TelephonyError> {
        self.update_stream
            .add(CallInfo { call_id, state })
            .map_err(|_| {
                TelephonyError::CallStatusUpdateError(
                    "Failed to push call state update".to_string(),
                )
            })
    }

    pub fn mark_alive(&self) {
        let mut last_alive_mark = self
            .last_alive_mark
            .lock()
            .expect("last_alive_mark lock poisoned");
        *last_alive_mark = std::time::SystemTime::now();
        println!("Marked SIP alive at {:?}", *last_alive_mark);
    }
}

pub fn push_call_state_update(
    call_id: pj::pjsua_call_id,
    ci: pj::pjsua_call_info,
) -> Result<(), TelephonyError> {
    // convert to your CallState enum
    let state = match ci.state {
        s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_NULL => CallState::Null,
        s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_CALLING => CallState::Calling,
        s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_INCOMING => CallState::Incoming,
        s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_EARLY => CallState::Early,
        s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_CONNECTING => CallState::Connecting,
        s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_CONFIRMED => CallState::Confirmed,
        s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_DISCONNECTED => CallState::Disconnected,
        _ => CallState::Disconnected,
    };

    // lock once, clone Arc out, then drop the guard to avoid holding the mutex across .push_event
    let guard = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");
    let maybe_manager = guard.as_ref().cloned();
    drop(guard);

    if let Some(call_manager) = maybe_manager {
        call_manager.push_event(call_id, state)
    } else {
        Err(TelephonyError::CallStatusUpdateError(
            "Call manager not initialized".to_string(),
        ))
    }
}

pub fn mark_sip_alive() {
    let guard = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");
    let maybe_manager = guard.as_ref().cloned();
    drop(guard);

    if let Some(call_manager) = maybe_manager {
        call_manager.mark_alive();
    }
}

pub fn sip_alive_tester_task() {
    loop {
        let guard = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");
        let maybe_manager = guard.as_ref().cloned();
        drop(guard);

        if let Some(maybe_manager) = maybe_manager {
            let last_alive_mark = maybe_manager
                .last_alive_mark
                .lock()
                .expect("last_alive_mark lock poisoned");
            if last_alive_mark.elapsed().unwrap_or_default() > std::time::Duration::from_secs(5) {
                println!("SIP not marked alive for over 5 seconds, attempting to close it...");
                unsafe {
                    ensure_pj_thread_registered();
                    pj::pjsua_destroy();
                }
            }
            std::thread::sleep(std::time::Duration::from_secs(1));
        }
    }
}
