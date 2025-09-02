extern crate pjsip as pj;

use std::{collections::HashMap, sync::{Arc, Mutex}};

use crate::core::{dart_types::CallState, types::{DartCallStream, DartSessionStream, TelephonyError}};

// Global registry of call managers by call id
lazy_static::lazy_static! {
    static ref CALL_REGISTRY: Mutex<HashMap<pj::pjsua_call_id, Arc<CallManager>>> = Mutex::new(HashMap::new());
}

pub struct CallManager {
    pub call_id: pj::pjsua_call_id,
    pub update_stream: DartCallStream,
}

impl CallManager {
    pub fn new(call_id: pj::pjsua_call_id, update_stream: DartCallStream) -> Arc<Self> {
        let manager = Arc::new(CallManager {
            call_id,
            update_stream,
        });

        // Forwarder thread will be started when Dart registers the StreamSink.
        // Optionally you can start a dummy forwarder here that drops events until sink is registered.

        // Ensure registry is initialized
        CALL_REGISTRY.lock().unwrap()
            .insert(call_id, manager.clone());

        manager
    }

    pub fn push_event(&self, state: CallState) -> Result<(), TelephonyError> {
        // log
        println!("Call state updated: {:?}", state);
        self.update_stream.add(state).map_err(|_| TelephonyError::CallCreationError("Failed to push call state update".to_string()))
    }
}

pub fn push_call_state_update(call_id: pj::pjsua_call_id, ci: pj::pjsua_call_info) -> Result<(), TelephonyError> {
    // log
    println!("Call state updated: {:?}", ci.state);
            // convert to your CallState enum
        let state = match ci.state {
            s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_EARLY => CallState::Early,
            s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_CALLING => CallState::Calling,
            s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_CONNECTING => CallState::Connecting,
            s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_CONFIRMED => CallState::Confirmed,
            s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_DISCONNECTED => CallState::Disconnected,
            _ => CallState::Disconnected,
        };
    let map = CALL_REGISTRY.lock().unwrap();
    if let Some(mgr) = map.get(&call_id) {
        mgr.push_event(state)
    } else {
        Err(TelephonyError::InputValueError(format!("Call ID {} not found", call_id)))
    }
}

// Global registry of session managers by session id
lazy_static::lazy_static! {
    static ref SESSION_REGISTRY: Mutex<HashMap<i64, Arc<SessionManager>>> = Mutex::new(HashMap::new());
}

pub struct SessionManager {
    pub session_id: i64,
    pub update_stream: DartSessionStream,
}

impl SessionManager {
    pub fn new(session_id: i64, update_stream: DartSessionStream) -> Arc<Self> {
        let manager = Arc::new(SessionManager {
            session_id,
            update_stream,
        });

        // Forwarder thread will be started when Dart registers the StreamSink.
        // Optionally you can start a dummy forwarder here that drops events until sink is registered.

        // Ensure registry is initialized
        SESSION_REGISTRY.lock().unwrap()
            .insert(session_id, manager.clone());

        manager
    }

    pub fn push_event(&self, state: crate::core::dart_types::SessionState) -> Result<(), TelephonyError> {
        // ignore send errors; receiver lives while sink registered
        self.update_stream.add(state).map_err(|_| TelephonyError::InitializationError(format!("Failed to push session state update")))
    }
}

pub fn push_session_state_update(session_id: i64, state: crate::core::dart_types::SessionState) -> Result<(), TelephonyError> {
    let map = SESSION_REGISTRY.lock().unwrap();
    if let Some(mgr) = map.get(&session_id) {
        mgr.push_event(state)
    } else {
        Err(TelephonyError::InputValueError(format!("Session ID {} not found", session_id)))
    }
}
