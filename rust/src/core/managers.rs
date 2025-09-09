extern crate pjsip as pj;

use std::{sync::{atomic::{AtomicBool, AtomicU64, Ordering}, Arc, Mutex}, time::Duration};

use crate::{core::{
    dart_types::{CallInfo, CallState}, types::{DartCallStream, TelephonyError}
}, utils::pj_str_to_string};

// Global registry of call manager
lazy_static::lazy_static! {
    static ref CALL_REGISTRY: Mutex<Option<Arc<CallStateManager>>> = Mutex::new(None);
}

pub struct CallStateManager {
    pub update_stream: DartCallStream,
    pub last_alive_mark: AtomicU64,
    pub kill_sig: AtomicBool,
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
            last_alive_mark: AtomicU64::new(now_ms()),
            kill_sig: AtomicBool::new(false),
        });

        *registry = Some(manager.clone());

        manager
    }

    pub fn push_event(
        &self,
        ci: CallInfo,
    ) -> Result<(), TelephonyError> {
        self.update_stream
            .add(ci)
            .map_err(|_| {
                TelephonyError::CallStatusUpdateError(
                    "Failed to push call state update".to_string(),
                )
            })
    }

    pub fn destroy_telephony(&self) -> Result<i8, TelephonyError> {
        self.kill_sig.store(true, Ordering::Relaxed);
        crate::core::helpers::hangup_calls();
        crate::core::helpers::destroy_telephony()
    }
}

fn now_ms() -> u64 {
    match std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH) {
        Ok(dur) => dur.as_millis() as u64,
        Err(_) => 0u64,
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
        call_manager.push_event(
            CallInfo {
                call_id: call_id as i32,
                call_url: pj_str_to_string(ci.remote_info),
                state,
            }
        )
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
        call_manager.last_alive_mark.store(now_ms(), Ordering::Relaxed);
    }
}

pub fn sip_alive_tester_task() {
    loop {
        let guard = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");
        let maybe_manager = guard.as_ref().cloned();
        drop(guard);

        if let Some(manager) = maybe_manager {
            if manager.kill_sig.load(Ordering::Relaxed) {
                println!("SIP alive tester task received kill signal, exiting...");
                break;
            }
            let last_ms = manager.last_alive_mark.load(Ordering::Relaxed);
            let elapsed_ms = now_ms().saturating_sub(last_ms);
            if elapsed_ms > Duration::from_secs(5).as_millis() as u64 {
                println!("SIP not marked alive for over 5 seconds, attempting to close it...");
                manager.destroy_telephony().ok();
            }
            std::thread::sleep(std::time::Duration::from_secs(1));
        }
    }
}

pub fn destroy_telephony_manager() -> Result<i8, TelephonyError> {
    let guard = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");
    let maybe_manager = guard.as_ref().cloned();
    drop(guard);

    if let Some(manager) = maybe_manager {
        manager.destroy_telephony()
    } else {
        Err(TelephonyError::TelephonyDestroyError(
            "Call manager not initialized".to_string(),
        ))
    }
}
