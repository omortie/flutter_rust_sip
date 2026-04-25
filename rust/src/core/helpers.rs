#![allow(non_snake_case)]
#![warn(dead_code)]

extern crate pjsip as pj_sys;

use std::convert::TryInto;
use std::ffi::CString;
use std::mem::MaybeUninit;

use log::debug;

use crate::{
    core::types::{OnIncommingCall, PJSUAError, TransportMode},
    utils::{error_exit, make_pj_str_t},
};

// GLOBAL VARS
static REALM_GLOBAL: &'static str = "*";

pub fn ensure_pj_thread_registered() {
    thread_local! {
        static THREAD_DESC: std::cell::RefCell<Option<Box<[std::os::raw::c_long; 64]>>> =
            std::cell::RefCell::new(None);
    }
    THREAD_DESC.with(|desc| {
        let mut desc = desc.borrow_mut();
        if desc.is_none() {
            let mut thread_desc: Box<[std::os::raw::c_long; 64]> =
                Box::new([0 as std::os::raw::c_long; 64]);
            let mut thread = std::ptr::null_mut();
            let thread_name = CString::new("rustffi").unwrap();
            let status = unsafe {
                pj_sys::pj_thread_register(
                    thread_name.as_ptr(),
                    thread_desc.as_mut_ptr(),
                    &mut thread,
                )
            };

            if status == pj_sys::pj_constants__PJ_SUCCESS as i32 {
                *desc = Some(thread_desc);
            }
        }
    });
}

pub fn initialize_pjsua(
    incommingCallBehaviour: OnIncommingCall,
    port: u32,
    stun_srv: String,
) -> Result<i8, PJSUAError> {
    debug!("initializing PJSIP");
    // INIT
    init(incommingCallBehaviour, stun_srv)?;

    // ADD UDP TRANSPORT
    add_transport(port, TransportMode::UDP)?;
    // ADD TCP TRANSPORT
    add_transport(port, TransportMode::TCP)?;

    // START
    start_pjsua()?;
    Ok(0)
}

pub fn init(incomming_call_behaviour: OnIncommingCall, stun_srv: String) -> Result<i8, PJSUAError> {
    // Create PJSUA instance
    let status = unsafe { pj_sys::pjsua_create() };
    if status != pj_sys::pj_constants__PJ_SUCCESS as i32 {
        debug!("Error in pjsua_create, status:= {}", status);
        error_exit("Error in pjsua_create");
        return Err(PJSUAError::CreationError("Could not Create PJSUA Instance".to_string()));
    }

    // pjsua_config
    let mut cfg = MaybeUninit::<pj_sys::pjsua_config>::zeroed();
    unsafe { pj_sys::pjsua_config_default(cfg.as_mut_ptr()); }
    let cfg_ref = unsafe { &mut *cfg.as_mut_ptr() };

    match incomming_call_behaviour {
        OnIncommingCall::AutoAnswer => cfg_ref.cb.on_incoming_call = Some(on_incoming_call),
        OnIncommingCall::Ignore => cfg_ref.cb.on_incoming_call = Some(on_incoming_call_ignore),
    }
    cfg_ref.cb.on_call_media_state = Some(on_call_media_state);
    cfg_ref.cb.on_call_state = Some(on_call_state);
    cfg_ref.cb.on_reg_state2 = Some(on_reg_state2);

    let stun_srv_str = make_pj_str_t(stun_srv)?;
    cfg_ref.stun_srv_cnt = 1;
    cfg_ref.stun_srv[0] = stun_srv_str;

    // pjsua_logging_config
    let mut log_cfg = MaybeUninit::<pj_sys::pjsua_logging_config>::zeroed();
    unsafe { pj_sys::pjsua_logging_config_default(log_cfg.as_mut_ptr()); }
    let log_cfg_ref = unsafe { &mut *log_cfg.as_mut_ptr() };
    log_cfg_ref.console_level = 7;

    // pjsua_media_config
    let mut media_cfg = MaybeUninit::<pj_sys::pjsua_media_config>::zeroed();
    unsafe { pj_sys::pjsua_media_config_default(media_cfg.as_mut_ptr()); }

    // Call pjsua_init with references
    let status = unsafe {
        pj_sys::pjsua_init(
            cfg.as_mut_ptr(),
            log_cfg.as_ptr(),
            media_cfg.as_ptr(),
        )
    };
    if status != pj_sys::pj_constants__PJ_SUCCESS as i32 {
        error_exit("Error in pjsua_init");
        debug!("Error in pjsua_init, status:= {}", status);
        return Err(PJSUAError::InitializationError("Error in pjsua_init".to_string()));
    }

    Ok(0)
}

pub fn add_transport(port: u32, mode: TransportMode) -> Result<i8, PJSUAError> {
    /* Add UDP transport. */
    debug!("INIT TRANSPORT CFG");

    let mut transport_cfg = unsafe {
        let mut transport_cfg: Box<MaybeUninit<pj_sys::pjsua_transport_config>> = Box::new(MaybeUninit::zeroed());
        pj_sys::pjsua_transport_config_default(transport_cfg.as_mut_ptr());
        transport_cfg
    };
    let transport_cfg_ref = unsafe { &mut *transport_cfg.as_mut_ptr() };
    transport_cfg_ref.port = port;
    let transportMode = match mode {
        TransportMode::TCP => pj_sys::pjsip_transport_type_e_PJSIP_TRANSPORT_TCP,
        TransportMode::TLS => pj_sys::pjsip_transport_type_e_PJSIP_TRANSPORT_TLS,
        TransportMode::UDP6 => pj_sys::pjsip_transport_type_e_PJSIP_TRANSPORT_UDP6,
        TransportMode::UDP => pj_sys::pjsip_transport_type_e_PJSIP_TRANSPORT_UDP,
        TransportMode::TCP6 => pj_sys::pjsip_transport_type_e_PJSIP_TRANSPORT_TCP6,
        TransportMode::TLS6 => pj_sys::pjsip_transport_type_e_PJSIP_TRANSPORT_TLS6,
    };

    let status = unsafe {
        let mut transport_id: MaybeUninit<pj_sys::pjsua_transport_id> = MaybeUninit::uninit();
        pj_sys::pjsua_transport_create(transportMode, transport_cfg.as_ptr(), transport_id.as_mut_ptr())
    };

    if status != pj_sys::pj_constants__PJ_SUCCESS as i32 {
        return Err(PJSUAError::TransportError("Error of some kind".to_string()));
    }
    return Ok(0);
}

pub fn start_pjsua() -> Result<i8, PJSUAError> {
    let status = unsafe { pj_sys::pjsua_start() };
    if status != pj_sys::pj_constants__PJ_SUCCESS as i32 {
        debug!("Error starting pjsua, status = {}", status);
        error_exit("Error starting pjsua");
        return Err(PJSUAError::PJSUAStartError(
            "Could not Start PJSUA".to_string(),
        ));
    };
    Ok(0)
}

pub fn account_setup(uri: String, username: String, password: String) -> Result<i32, PJSUAError> {
    debug!("ACCOUNT SETUP");

    let mut acc_cfg = unsafe {
        let mut acc_cfg: Box<MaybeUninit<pj_sys::pjsua_acc_config>> =
            Box::new(MaybeUninit::zeroed());
        pj_sys::pjsua_acc_config_default(acc_cfg.as_mut_ptr());
        acc_cfg
    };
    let acc_cfg_ref = unsafe { &mut *acc_cfg.as_mut_ptr() };

    let reg_uri: String = format!("sip:{}", uri);

    let reg_uri_pj_str_t = match make_pj_str_t(reg_uri) {
        Err(x) => return Err(x),
        Ok(y) => y,
    };

    // Setting members of the struct

    acc_cfg_ref.reg_uri = reg_uri_pj_str_t;

    // check if username and password provided
    if !username.is_empty() && !password.is_empty() {
        let acc_id: String = format!("sip:{}@{}", username, uri);

        let acc_id_pj_str_t = match make_pj_str_t(acc_id) {
            Err(x) => return Err(x),
            Ok(y) => y,
        };
        acc_cfg_ref.id = acc_id_pj_str_t;

        debug!(
            "Setting Credentials for Account: {} with username: {}",
            uri, username
        );
        let realm: String = REALM_GLOBAL.to_owned();
        let scheme: String = "Digest".to_string();
        let username: String = username;
        let data: String = password;

        let realm_pj_str_t = match make_pj_str_t(realm) {
            Err(x) => return Err(x),
            Ok(y) => y,
        };
        let scheme_pj_str_t = match make_pj_str_t(scheme) {
            Err(x) => return Err(x),
            Ok(y) => y,
        };
        let username_pj_str_t = match make_pj_str_t(username) {
            Err(x) => return Err(x),
            Ok(y) => y,
        };
        let data_pj_str_t = match make_pj_str_t(data) {
            Err(x) => return Err(x),
            Ok(y) => y,
        };

        // configuring credentials to work with SIP servers
        acc_cfg_ref.cred_count = 1;
        acc_cfg_ref.cred_info[0].realm = realm_pj_str_t;
        acc_cfg_ref.cred_info[0].scheme = scheme_pj_str_t;
        acc_cfg_ref.cred_info[0].username = username_pj_str_t;
        acc_cfg_ref.cred_info[0].data_type =
            pj_sys::pjsip_cred_data_type_PJSIP_CRED_DATA_PLAIN_PASSWD
                .try_into()
                .unwrap();
        acc_cfg_ref.cred_info[0].data = data_pj_str_t;
    } else {
        // empty account id using only uri without username part
        let acc_id: String = format!("sip:{}", uri);
        let acc_id_pj_str_t = match make_pj_str_t(acc_id) {
            Err(x) => return Err(x),
            Ok(y) => y,
        };
        acc_cfg_ref.id = acc_id_pj_str_t;

        acc_cfg_ref.cred_count = 0;
    }

    let mut acc_id_out = MaybeUninit::<pj_sys::pjsua_acc_id>::uninit();
    let acc_add_status = unsafe {
        pj_sys::pjsua_acc_add(
            acc_cfg.as_ptr(),
            pj_sys::pj_constants__PJ_TRUE.try_into().unwrap(),
            acc_id_out.as_mut_ptr(),
        )
    };
    let acc_id = unsafe { acc_id_out.assume_init() };

    debug!("Status of pjsua Acc add : {}, account ID: {}", acc_add_status, acc_id);
    if acc_add_status != pj_sys::pj_constants__PJ_SUCCESS as i32 {
        return Err(PJSUAError::AccountCreationError("Error Adding Account".to_string()));
    }
    Ok(acc_id)
}

extern "C" fn on_incoming_call(
    _acc_id: pj_sys::pjsua_acc_id,
    call_id: pj_sys::pjsua_call_id,
    _rdata: *mut pj_sys::pjsip_rx_data,
) {
    unsafe {
        pj_sys::pjsua_call_answer(call_id, 200, std::ptr::null(), std::ptr::null());
    }
    debug!("The accepted call id is: {}", call_id);
}

extern "C" fn on_incoming_call_ignore(
    _acc_id: pj_sys::pjsua_acc_id,
    call_id: pj_sys::pjsua_call_id,
    _rdata: *mut pj_sys::pjsip_rx_data,
) {
    debug!("The ignored call id is: {}", call_id);
}

extern "C" fn on_call_media_state(call_id: pj_sys::pjsua_call_id) {
    let ci = unsafe {
        let mut ci: MaybeUninit<pj_sys::pjsua_call_info> = MaybeUninit::uninit();
        pj_sys::pjsua_call_get_info(call_id, ci.as_mut_ptr());
        ci.assume_init()
    };

    if ci.media_status == pj_sys::pjsua_call_media_status_PJSUA_CALL_MEDIA_ACTIVE {
        unsafe {
            pj_sys::pjsua_conf_connect(ci.conf_slot, 0);
            pj_sys::pjsua_conf_connect(0, ci.conf_slot);
        }
    }
}

extern "C" fn on_reg_state2(acc_id: pj_sys::pjsua_acc_id, _info: *mut pj_sys::pjsua_reg_info) {
    // Query current account info to see registration status/code
    let ai = unsafe {
        let mut ai: MaybeUninit<pj_sys::pjsua_acc_info> = MaybeUninit::uninit();
        pj_sys::pjsua_acc_get_info(acc_id, ai.as_mut_ptr());
        ai.assume_init()
    };
    debug!("Registration update: acc_id={}, status={}", acc_id, ai.status);
    // Push registration status update to AccountManager stream
    super::managers::push_account_status_update(acc_id, ai.status);
}

extern "C" fn on_call_state(call_id: pj_sys::pjsua_call_id, _: *mut pj_sys::pjsip_event) {
    let ci = unsafe {
        let mut ci: MaybeUninit<pj_sys::pjsua_call_info> = MaybeUninit::uninit();
        pj_sys::pjsua_call_get_info(call_id, ci.as_mut_ptr());
        ci.assume_init()
    };
    // log ci
    debug!("Call info: {:?}", ci.last_status);

    // push update to the relevant call manager
    super::managers::push_call_state_update(call_id, ci);
}

pub fn make_call(phone_number: &str, domain: &str) -> Result<i32, PJSUAError> {
    // TODO: Check Phone number isnt garbage string
    let call_extension: String = if phone_number.is_empty() {
        format!("sip:{}", domain)
    } else {
        format!("sip:{}@{}", phone_number, domain)
    };
    let len = call_extension.len();
    let call_extension_c_string = CString::new(call_extension);
    let call_extension_c_string_ok = match call_extension_c_string {
        Err(_y) => {
            return Err(PJSUAError::CallCreationError(
                "Phone number or Domain supplied could not be represented as a C-String"
                    .to_string(),
            ))
        }
        Ok(x) => x,
    };

    let call_extension_myptr = call_extension_c_string_ok.into_raw();
    let call_extension_pj_str_t = pj_sys::pj_str_t {
        slen: len as _,
        ptr: call_extension_myptr,
    };
    let ptr_call_extension_pj_str_t = &call_extension_pj_str_t as *const _;

    let user_data_null: *mut ::std::os::raw::c_void =
        &mut 0 as *mut _ as *mut ::std::os::raw::c_void;
    let opt = 0 as *mut pj_sys::pjsua_call_setting;
    let mut call_id: pj_sys::pjsua_call_id = 0;
    let make_call_restult = unsafe {
        pj_sys::pjsua_call_make_call(
            0,
            ptr_call_extension_pj_str_t,
            opt,
            user_data_null,
            0 as *mut pj_sys::pjsua_msg_data,
            &mut call_id,
        )
    };
    if make_call_restult != 0 {
        return Err(PJSUAError::CallCreationError(
            "Could not place Call".to_string(),
        ));
    }
    return Ok(call_id);
}

pub fn hangup_call(call_id: i32) -> Result<(), PJSUAError> {
    debug!("Hanging up call id: {}", call_id);
    let status =
        unsafe { pj_sys::pjsua_call_hangup(call_id, 0, std::ptr::null(), std::ptr::null()) };
    if status != 0 {
        return Err(PJSUAError::CallStatusUpdateError(
            "Could not Hangup Call".to_string(),
        ));
    }
    debug!("Hanged up call id: {}", call_id);
    Ok(())
}

pub fn hangup_calls() {
    unsafe { pj_sys::pjsua_call_hangup_all() };
}

pub fn destroy_pjsua() -> Result<i8, PJSUAError> {
    debug!("Destroy PJSUA");
    let status = unsafe { pj_sys::pjsua_destroy() };
    if status != 0 {
        return Err(PJSUAError::PJSUADestroyError(
            "Error Occured during PJSUA Destruction".to_string(),
        ));
    }
    Ok(0)
}
