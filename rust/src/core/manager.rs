extern crate pjsip as pj;

use std::{collections::HashMap, sync::{Arc, Mutex}};

use crate::core::{dart_types::CallState, types::DartCallStream};

// Global registry of managers by session id
lazy_static::lazy_static! {
    static ref REGISTRY: Mutex<HashMap<pj::pjsua_call_id, Arc<CallManager>>> = Mutex::new(HashMap::new());
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
        REGISTRY.lock().unwrap()
            .insert(call_id, manager.clone());

        manager
    }

    pub fn push_event(&self, ci: pj::pjsua_call_info) {
        // convert to your CallState enum
    let state = match ci.state {
        s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_CALLING => CallState::Calling,
        s if s == pj::pjsip_inv_state_PJSIP_INV_STATE_CONFIRMED => CallState::Confirmed,
        _ => CallState::Disconnected,
    };
    // log
    println!("Call state updated: {:?}", state);
        // ignore send errors; receiver lives while sink registered
        self.update_stream.add(state).unwrap_or(());
    }
}

pub fn push_call_state_update(call_id: pj::pjsua_call_id, ci: pj::pjsua_call_info) {
    let map = REGISTRY.lock().unwrap();
    if let Some(mgr) = map.get(&call_id) {
        mgr.push_event(ci);
    }
}