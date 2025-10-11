#![allow(non_snake_case)]
#![warn(dead_code)]

extern crate pjsip as pj_sys;

use std::convert::TryInto;
use std::ffi::CString;
use std::mem::MaybeUninit;

use pjsip::{pjsua_stun_use_PJSUA_STUN_RETRY_ON_FAILURE};

use crate::{
    core::{
        managers::push_call_state_update,
        types::{OnIncommingCall, PJSUAError, TransportMode},
    },
    utils::{error_exit, make_pj_str_t},
};

// GLOBAL VARS
static REALM_GLOBAL: &'static str = "*";

pub fn ensure_pj_thread_registered() {
    thread_local! {
        static REGISTERED: std::cell::Cell<bool> = std::cell::Cell::new(false);
    }
    REGISTERED.with(|reg| {
        if !reg.get() {
            let mut thread_desc: [std::os::raw::c_long; 64] = [0 as std::os::raw::c_long; 64];

            let mut thread = std::ptr::null_mut();
            let thread_name = CString::new("rustffi").unwrap();
            unsafe {
                pj_sys::pj_thread_register(
                    thread_name.as_ptr(),
                    thread_desc.as_mut_ptr(),
                    &mut thread,
                );
            }
            reg.set(true);
        }
    });
}

pub fn initialize_pjsua(
    incommingCallBehaviour: OnIncommingCall,
    port: u32,
    stun_srv: String,
) -> Result<i8, PJSUAError> {
    // INIT
    let initResult = init(incommingCallBehaviour, stun_srv);
    match initResult {
        Ok(_) => (),
        Err(x) => return Err(x),
    };

    // ADD UDP TRANSPORT
    let transportResult = add_transport(port, TransportMode::UDP);
    match transportResult {
        Ok(_) => (),
        Err(x) => return Err(x),
    };
    // ADD TDCP TRANSPORT
    let transportResult = add_transport(port, TransportMode::TCP);
    match transportResult {
        Ok(_) => (),
        Err(x) => return Err(x),
    };

    // START
    let startResult = start_pjsua();
    match startResult {
        Ok(_) => (),
        Err(x) => return Err(x),
    };
    Ok(0)
}

pub fn init(incomming_call_behaviour: OnIncommingCall, stun_srv: String) -> Result<i8, PJSUAError> {
    let status: pj_sys::pj_status_t;

    status = unsafe { pj_sys::pjsua_create() };

    if status != pj_sys::pj_constants__PJ_SUCCESS as i32 {
        println!("Error in pjsua_create, status:= {}", status);
        error_exit("Error in pjsua_create");
        return Err(PJSUAError::CreationError(
            "Could not Create PJSUA Instance".to_string(),
        ));
    }

    let status: pj_sys::pj_status_t;
    let mut cfg = unsafe {
        let mut cfg: MaybeUninit<pj_sys::pjsua_config> = MaybeUninit::uninit();
        pj_sys::pjsua_config_default(cfg.as_mut_ptr());
        cfg.assume_init()
    };

    // cfg.cb.on_incoming_call = Some(aux_on_incomming_call());
    match incomming_call_behaviour {
        OnIncommingCall::AutoAnswer => cfg.cb.on_incoming_call = Some(on_incoming_call),
        OnIncommingCall::Ignore => cfg.cb.on_incoming_call = Some(on_incoming_call_ignore),
    }

    cfg.cb.on_call_media_state = Some(on_call_media_state);
    cfg.cb.on_call_state = Some(on_call_state);

    let stun_srv_pj_str_t = match make_pj_str_t(stun_srv) {
        Err(x) => return Err(x),
        Ok(y) => y,
    };
    cfg.stun_srv_cnt = 1;
    cfg.stun_srv[0] = stun_srv_pj_str_t;

    let mut log_cfg = unsafe {
        let mut log_cfg: MaybeUninit<pj_sys::pjsua_logging_config> = MaybeUninit::uninit();
        pj_sys::pjsua_logging_config_default(log_cfg.as_mut_ptr());
        log_cfg.assume_init()
    };

    log_cfg.console_level = 0;

    status = unsafe { pj_sys::pjsua_init(&cfg, &log_cfg, std::ptr::null()) };
    if status != pj_sys::pj_constants__PJ_SUCCESS as i32 {
        error_exit("Error in pjsua_init");
        println!("Error in pjsua_init, status:= {}", status);
        return Err(PJSUAError::InitializationError(
            "Error in pjsua_init".to_string(),
        ));
    }
    return Ok(0);
}

pub fn add_transport(port: u32, mode: TransportMode) -> Result<i8, PJSUAError> {
    /* Add UDP transport. */
    println!("INIT TRANSPORT CFG");

    let mut transport_cfg = unsafe {
        let mut transport_cfg: MaybeUninit<pj_sys::pjsua_transport_config> = MaybeUninit::uninit();
        pj_sys::pjsua_transport_config_default(transport_cfg.as_mut_ptr());
        transport_cfg.assume_init()
    };

    transport_cfg.port = port;
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
        pj_sys::pjsua_transport_create(transportMode, &transport_cfg, transport_id.as_mut_ptr())
    };

    if status != pj_sys::pj_constants__PJ_SUCCESS as i32 {
        return Err(PJSUAError::TransportError("Error of some kind".to_string()));
    }
    return Ok(0);
}

pub fn start_pjsua() -> Result<i8, PJSUAError> {
    let status = unsafe { pj_sys::pjsua_start() };
    if status != pj_sys::pj_constants__PJ_SUCCESS as i32 {
        println!("Error starting pjsua, status = {}", status);
        error_exit("Error starting pjsua");
        return Err(PJSUAError::PJSUAStartError(
            "Could not Start PJSUA".to_string(),
        ));
    };
    Ok(0)
}

pub fn account_setup(uri : String, username: String, password: String) -> Result<i32,PJSUAError> {
    println!("ACCOUNT SETUP");
    let status: pj_sys::pj_status_t;
    let mut acc_cfg = unsafe {
        let mut acc_cfg: Box<MaybeUninit<pj_sys::pjsua_acc_config>> =
            Box::new(MaybeUninit::uninit());
        pj_sys::pjsua_acc_config_default(acc_cfg.as_mut_ptr());
        acc_cfg
    };
    let acc_cfg_ref = unsafe { &mut *acc_cfg.as_mut_ptr() };

    let reg_uri : String    = ["sip:".to_string(), uri.clone()].concat();

    let reg_uri_pj_str_t = match make_pj_str_t(reg_uri) {
        Err(x) => return Err(x),
        Ok(y) => y,
    };

    // Setting members of the struct
    
    acc_cfg_ref.reg_uri = reg_uri_pj_str_t;
    
    // check if username and password provided
    if !username.is_empty() && !password.is_empty(){
        let acc_id : String      = ["sip:".to_string(), username.clone(), "@".to_string(),uri.clone()].concat();


        let acc_id_pj_str_t = match make_pj_str_t(acc_id) {
            Err(x) => return Err(x),
            Ok(y) => y,
        };
        acc_cfg_ref.id = acc_id_pj_str_t;

        println!("Setting Credentials for Account: {} with username: {} and password: {}", uri, username, password);
        let realm : String      = REALM_GLOBAL.to_owned();
        let scheme : String     = uri;
        let username : String   = username;
        let data : String       = password;

        let realm_pj_str_t = match(make_pj_str_t(realm)){
            Err(x)=> return Err(x),
            Ok(y)=>y 
        }; 
        let scheme_pj_str_t = match(make_pj_str_t(scheme)){
            Err(x)=> return Err(x),
            Ok(y)=>y 
        }; 
        let username_pj_str_t = match(make_pj_str_t(username)){
            Err(x)=> return Err(x),
            Ok(y)=>y 
        };
        let data_pj_str_t = match(make_pj_str_t(data)){
            Err(x)=> return Err(x),
            Ok(y)=>y 
        };

        // configuring credentials to work with SIP servers 
        acc_cfg_ref.cred_count = 1;
        acc_cfg_ref.cred_info[0].realm = realm_pj_str_t;
        acc_cfg_ref.cred_info[0].scheme = scheme_pj_str_t;
        acc_cfg_ref.cred_info[0].username = username_pj_str_t;
        acc_cfg_ref.cred_info[0].data_type = pj_sys::pjsip_cred_data_type_PJSIP_CRED_DATA_PLAIN_PASSWD.try_into().unwrap();
        acc_cfg_ref.cred_info[0].data = data_pj_str_t;
    } else {
        // empty account id using only uri without username part
        let acc_id: String = ["sip:".to_string(), uri.clone()].concat();
        let acc_id_pj_str_t = match make_pj_str_t(acc_id) {
            Err(x) => return Err(x),
            Ok(y) => y,
        };
        acc_cfg_ref.id = acc_id_pj_str_t;
        
        acc_cfg_ref.cred_count = 0;
    }
    
    // better NAT traversal settings
    acc_cfg_ref.media_stun_use = pjsua_stun_use_PJSUA_STUN_RETRY_ON_FAILURE;
    acc_cfg_ref.allow_sdp_nat_rewrite = true as i32;

    let acc_id: pj_sys::pjsua_acc_id;
    acc_id = 0;
    status = unsafe {
        pj_sys::pjsua_acc_add(
            acc_cfg_ref,
            pj_sys::pj_constants__PJ_TRUE.try_into().unwrap(),
            acc_id as *mut i32,
        )
    };

    // let acc_id_c_string_fromraw = unsafe {CString::from_raw( acc_id_myptr)}; // Might need this at a later stage

    println!("Status of pjsua Acc add : {}", status);
    if status != pj_sys::pj_constants__PJ_SUCCESS as i32 {
        println!("Error Adding Account, status = {}", status);
        error_exit("Error Adding Account");
        return Err(PJSUAError::AccountCreationError(
            "Error Adding Account".to_string(),
        ));
    }
    return Ok(acc_id);
}

extern "C" fn on_incoming_call(
    _acc_id: pj_sys::pjsua_acc_id,
    call_id: pj_sys::pjsua_call_id,
    _rdata: *mut pj_sys::pjsip_rx_data,
) {
    unsafe {
        pj_sys::pjsua_call_answer(call_id, 200, std::ptr::null(), std::ptr::null());
    }
    println!("The accepted call id is: {}", call_id);
}

extern "C" fn on_incoming_call_ignore(
    _acc_id: pj_sys::pjsua_acc_id,
    call_id: pj_sys::pjsua_call_id,
    _rdata: *mut pj_sys::pjsip_rx_data,
) {
    println!("The ignored call id is: {}", call_id);
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

extern "C" fn on_call_state(call_id: pj_sys::pjsua_call_id, _: *mut pj_sys::pjsip_event) {
    let ci = unsafe {
        let mut ci: MaybeUninit<pj_sys::pjsua_call_info> = MaybeUninit::uninit();
        pj_sys::pjsua_call_get_info(call_id, ci.as_mut_ptr());
        ci.assume_init()
    };
    // log ci
    println!("Call info: {:?}", ci.last_status);

    // push update to the relevant call manager
    push_call_state_update(call_id, ci);
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
    println!("Hanging up call id: {}", call_id);
    let status =
        unsafe { pj_sys::pjsua_call_hangup(call_id, 0, std::ptr::null(), std::ptr::null()) };
    if status != 0 {
        return Err(PJSUAError::CallStatusUpdateError(
            "Could not Hangup Call".to_string(),
        ));
    }
    println!("Hanged up call id: {}", call_id);
    Ok(())
}

pub fn hangup_calls() {
    unsafe { pj_sys::pjsua_call_hangup_all() };
}

pub fn destroy_pjsua() -> Result<i8, PJSUAError> {
    println!("Destroy PJSUA");
    let status = unsafe { pj_sys::pjsua_destroy() };
    if status != 0 {
        return Err(PJSUAError::PJSUADestroyError(
            "Error Occured during PJSUA Destruction".to_string(),
        ));
    }
    Ok(0)
}
