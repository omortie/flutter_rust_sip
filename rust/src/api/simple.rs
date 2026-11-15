// FFI-safe wrappers for PJSUA functions

use flutter_rust_bridge::frb;
use std::sync::atomic::{AtomicU64, Ordering};

// Keep a primitive-only record of successful adjustments. pjsip-sys bundled
// binaries and generated port-info layouts can differ in conference capacity.
static MICROPHONE_GAIN: AtomicU64 = AtomicU64::new(1.0_f64.to_bits());

use crate::core::{
    helpers::*,
    init_logger,
    managers::{AccountManager, CallManager},
    pj_worker::get_pjsip_worker,
    types::{DartAccountStream, DartCallStream, LogLevel, OnIncommingCall, PJSUAError},
};

#[frb(init)]
pub fn init_app() {
    init_logger();
}

pub fn init_pjsua(
    local_port: u32,
    incoming_call_strategy: OnIncommingCall,
    stun_srv: String,
    log_level: LogLevel,
) -> Result<i8, PJSUAError> {
    // initialize pjsua
    initialize_pjsua(incoming_call_strategy, local_port, stun_srv, log_level).map(|result| {
        MICROPHONE_GAIN.store(1.0_f64.to_bits(), Ordering::Relaxed);
        // Start SIP alive tester task to check alive flag periodically as destroy management
        std::thread::spawn(|| crate::core::managers::call_alive_tester_task());

        result
    })
}

pub fn account_setup(uri: String, username: String, password: String) -> Result<i32, PJSUAError> {
    get_pjsip_worker()
        .execute_sync(move || crate::core::managers::account_setup(uri, username, password))
}

pub fn register_call_stream(call_sink: DartCallStream) {
    // Initialize the call state manager singleton
    CallManager::init(call_sink);
}

pub fn register_account_stream(account_sink: DartAccountStream) {
    // Initialize the account registration manager singleton
    AccountManager::init(account_sink);
}

pub fn mark_call_alive(call_id: i32) {
    // Directly mark the call alive via the CallManager; remove use of undefined `sender`.
    crate::core::managers::mark_call_alive(call_id);
}

pub async fn make_call(phone_number: String, domain: String) -> Result<i32, PJSUAError> {
    get_pjsip_worker().execute_sync(move || crate::core::managers::make_call(phone_number, domain))
}

pub fn hangup_call(call_id: i32) -> Result<(), PJSUAError> {
    get_pjsip_worker().execute_sync(move || crate::core::managers::hangup_call(call_id))
}

pub fn destroy_pjsua() -> Result<i8, PJSUAError> {
    get_pjsip_worker().execute_sync(move || crate::core::managers::destroy_pjsua())
}

/// Capture gain shared by every call. 0 mutes, 1 is unity, 4 is maximum.
pub fn set_microphone_gain(gain: f64) -> Result<(), PJSUAError> {
    validate_microphone_gain(gain)?;
    require_audio_running()?;
    get_pjsip_worker().execute_sync(move || {
        require_audio_running()?;
        let status = unsafe { pjsip::pjsua_conf_adjust_rx_level(0, gain as f32) };
        check_audio_status(status)?;
        MICROPHONE_GAIN.store(gain.to_bits(), Ordering::Relaxed);
        Ok(())
    })
}

/// Last gain successfully applied through this API; unity after initialization.
pub fn get_microphone_gain() -> Result<f64, PJSUAError> {
    require_audio_running()?;
    get_pjsip_worker().execute_sync(|| {
        require_audio_running()?;
        Ok(f64::from_bits(MICROPHONE_GAIN.load(Ordering::Relaxed)))
    })
}

/// Latest microphone input level, normalized to 0..1. Poll during active media
/// (e.g. every 100 ms). This is capture input, never remote speaker output.
pub fn get_microphone_level() -> Result<f64, PJSUAError> {
    require_audio_running()?;
    get_pjsip_worker().execute_sync(|| {
        require_audio_running()?;
        let mut level = 0;
        let status =
            unsafe { pjsip::pjsua_conf_get_signal_level(0, std::ptr::null_mut(), &mut level) };
        check_audio_status(status)?;
        Ok(f64::from(level.min(255)) / 255.0)
    })
}

fn require_audio_running() -> Result<(), PJSUAError> {
    if unsafe { pjsip::pjsua_get_state() } != pjsip::pjsua_state_PJSUA_STATE_RUNNING {
        return Err(PJSUAError::InitializationError(
            "PJSUA is not running".into(),
        ));
    }
    Ok(())
}

fn check_audio_status(status: i32) -> Result<(), PJSUAError> {
    if status != 0 {
        return Err(PJSUAError::InputValueError(format!(
            "Audio operation failed: {status}"
        )));
    }
    Ok(())
}

fn validate_microphone_gain(gain: f64) -> Result<(), PJSUAError> {
    if !gain.is_finite() || !(0.0..=4.0).contains(&gain) {
        return Err(PJSUAError::InputValueError(
            "Microphone gain must be finite and between 0 and 4".into(),
        ));
    }
    Ok(())
}

#[cfg(test)]
mod microphone_tests {
    use super::*;

    #[test]
    fn rejects_invalid_gains() {
        for gain in [f64::NAN, f64::INFINITY, f64::NEG_INFINITY, -0.01, 4.01] {
            assert!(set_microphone_gain(gain).is_err());
        }
        for gain in [0.0, 0.5, 1.0, 4.0] {
            assert!(validate_microphone_gain(gain).is_ok());
        }
    }

    #[test]
    fn audio_access_before_initialization_returns_errors() {
        assert!(get_microphone_level().is_err());
        assert!(get_microphone_gain().is_err());
        assert!(set_microphone_gain(1.0).is_err());
    }
}
