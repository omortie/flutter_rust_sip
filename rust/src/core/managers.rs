extern crate pjsip as pj_sys;

use std::{
    collections::HashMap,
    sync::{Arc, Mutex},
    time::Duration,
};

use log::info;

use crate::{
    core::{
        dart_types::{AccountInfo, CallInfo, CallState}, pj_worker::get_pjsip_worker, types::{DartAccountStream, DartCallStream}
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
    static ref ACCOUNT_MANAGER: Mutex<Option<Arc<AccountManager>>> = Mutex::new(None);
    static ref ACCOUNT_REGISTRY: Mutex<HashMap<i32, AccountInfo>> = Mutex::new(HashMap::new());
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
        // if new state is disconnected then remove from registry
        if let CallState::Disconnected = ci.state {
            remove_call_from_registry(ci.call_id);
        }

        info!(
            "Pushing call event: id={}, state={:?}",
            ci.call_id,
            ci.state
        );
        self.update_stream.add(ci).unwrap_or(());
    }
}

pub struct AccountManager {
    pub update_stream: DartAccountStream,
}

impl AccountManager {
    pub fn init(update_stream: DartAccountStream) -> Arc<Self> {
        let mut registry = ACCOUNT_MANAGER.lock().expect("ACCOUNT_MANAGER lock poisoned");

        if let Some(existing) = registry.as_ref() {
            return existing.clone();
        }

        let manager = Arc::new(AccountManager { update_stream });
        *registry = Some(manager.clone());
        manager
    }

    pub fn push_event(&self, account_info: AccountInfo) {
        info!("Pushing account registration status: {}", account_info.status_code);
        self.update_stream.add(account_info).unwrap_or(());
    }
}

fn remove_call_from_registry(call_id: i32) -> () {
    let mut call_registry = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");
    call_registry.remove(&call_id);
    info!("Removed call {} from registry", call_id);
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

pub fn push_account_status_update(_acc_id: i32, status_code: pj_sys::pjsip_status_code) {
    println!("Preparing to push account status update: acc_id={}, status_code={}", _acc_id, status_code);

    let guard = ACCOUNT_MANAGER.lock().expect("ACCOUNT_MANAGER lock poisoned");
    let maybe_manager = guard.as_ref().cloned();
    drop(guard);

    if let Some(account_manager) = maybe_manager {
        // Push the update if manager exists
        account_manager.push_event(AccountInfo { acc_id: _acc_id, status_code: status_code });
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
    get_pjsip_worker().execute_sync(move || {
        crate::core::helpers::hangup_call(call_id)
    })
}

// add a helper function here so any successful account setup would be added to account registry
pub fn account_setup(
    uri: String,
    username: String,
    password: String,
) -> Result<i32, crate::core::types::PJSUAError> {
    crate::core::helpers::account_setup(uri, username, password)
}

pub fn destroy_pjsua() -> Result<i8, crate::core::types::PJSUAError> {
    crate::core::helpers::hangup_calls();
    crate::core::helpers::destroy_pjsua().inspect(|_| {
        let mut call_registry = CALL_REGISTRY.lock().expect("CALL_REGISTRY lock poisoned");
        call_registry.clear();
        info!("Cleared call registry on PJSUA destroy");
    })
}

