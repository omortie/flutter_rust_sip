#![allow(non_snake_case)]
#![warn(dead_code)]

extern crate pjsip as pj;

use std::ffi::CString;
use std::mem::MaybeUninit;
use std::convert::TryInto;

use pjsip::pjsua_stun_use_PJSUA_STUN_RETRY_ON_FAILURE;

use crate::{core::{managers::{push_call_state_update}, types::{OnIncommingCall, TelephonyError, TransportMode}}, utils::{error_exit, make_pj_str_t}};

pub fn ensure_pj_thread_registered() {
    thread_local! {
        static REGISTERED: std::cell::Cell<bool> = std::cell::Cell::new(false);
    }
    REGISTERED.with(|reg| {
        if !reg.get() {
            let mut thread_desc = [0i64; 64];
            let mut thread = std::ptr::null_mut();
            let thread_name = CString::new("rustffi").unwrap();
            unsafe {
                pj::pj_thread_register(thread_name.as_ptr(), thread_desc.as_mut_ptr(), &mut thread);
            }
            reg.set(true);
        }
    });
}

pub fn initialize_telephony(incommingCallBehaviour:OnIncommingCall, port:u32, transportmode :TransportMode, stun_srv: String) -> Result<i8,TelephonyError> {

    // INIT
    let initResult = init(incommingCallBehaviour, stun_srv);
    match initResult{
        Ok(_) => (),
        Err(x) => return Err(x),
    };

    // ADD TRANSPORT
    let transportResult = add_transport(port,transportmode);
    match transportResult{
        Ok(_) => (),
        Err(x) => return Err(x),
    };

    // START
    let startResult = start_telephony();
    match startResult{
        Ok(_) => (),
        Err(x) => return Err(x),
    };
    Ok(0)
}                                                                      

pub fn init(incomming_call_behaviour: OnIncommingCall, stun_srv: String) -> Result<i8,TelephonyError> { 
        
    let status : pj::pj_status_t;

    status = unsafe{pj::pjsua_create()};

    if status != pj::pj_constants__PJ_SUCCESS as i32 { 
        println!("Error in pjsua_create, status:= {}",status);
        error_exit("Error in pjsua_create");
        return Err(TelephonyError::CreationError("Could not Create Telephony Instance".to_string()));
    }

    let status : pj::pj_status_t;    
    let mut cfg =  unsafe {
        let mut cfg: MaybeUninit<pj::pjsua_config> = MaybeUninit::uninit();
        pj::pjsua_config_default(cfg.as_mut_ptr());
        cfg.assume_init()
    };

    // cfg.cb.on_incoming_call = Some(aux_on_incomming_call());
    match incomming_call_behaviour{
        OnIncommingCall::AutoAnswer => cfg.cb.on_incoming_call = Some(on_incoming_call),
        OnIncommingCall::Ignore => cfg.cb.on_incoming_call = Some(on_incoming_call_ignore),
    }

    cfg.cb.on_call_media_state = Some(on_call_media_state);
    cfg.cb.on_call_state = Some(on_call_state);
    
    let mut stun_srv_string = stun_srv.clone();
    // configuring default stun server of Google
    if stun_srv.is_empty() {
        stun_srv_string = "stun.l.google.com".to_string(); // default STUN server
    }
    let stun_srv_pj_str_t = match make_pj_str_t(stun_srv_string) {
        Err(x) => return Err(x),
        Ok(y) => y
    };
    cfg.stun_srv_cnt = 1;
    cfg.stun_srv[0] = stun_srv_pj_str_t;

	let mut log_cfg =  unsafe {
        let mut log_cfg: MaybeUninit<pj::pjsua_logging_config> = MaybeUninit::uninit();
        pj::pjsua_logging_config_default(log_cfg.as_mut_ptr());
        log_cfg.assume_init()
    };
	
    log_cfg.console_level = 0;
    
	status = unsafe{pj::pjsua_init(&cfg, &log_cfg, std::ptr::null())};
    if status != pj::pj_constants__PJ_SUCCESS as i32 { 
        error_exit("Error in pjsua_init");
        println!("Error in pjsua_init, status:= {}",status);
        return Err(TelephonyError::InitializationError("Error in pjsua_init".to_string()));
    }
    return Ok(0);
}

pub fn add_transport(port: u32, mode: TransportMode ) -> Result <i8,TelephonyError>{
     /* Add UDP transport. */
    println!("INIT TRANSPORT CFG");

    let mut transport_cfg =  unsafe {
        let mut transport_cfg: MaybeUninit<pj::pjsua_transport_config> = MaybeUninit::uninit();
        pj::pjsua_transport_config_default(transport_cfg.as_mut_ptr());
        transport_cfg.assume_init()
    };    

    transport_cfg.port = port;
    let transportMode = match mode{
        TransportMode::TCP  => pj::pjsip_transport_type_e_PJSIP_TRANSPORT_TCP,
        TransportMode::TLS  => pj::pjsip_transport_type_e_PJSIP_TRANSPORT_TLS,
        TransportMode::UDP6 => pj::pjsip_transport_type_e_PJSIP_TRANSPORT_UDP6,
        TransportMode::UDP  => pj::pjsip_transport_type_e_PJSIP_TRANSPORT_UDP,
        TransportMode::TCP6 => pj::pjsip_transport_type_e_PJSIP_TRANSPORT_TCP6,
        TransportMode::TLS6 => pj::pjsip_transport_type_e_PJSIP_TRANSPORT_TLS6
    };

    let status =  unsafe {
        let mut transport_id: MaybeUninit<pj::pjsua_transport_id> = MaybeUninit::uninit();
        pj::pjsua_transport_create( transportMode, &transport_cfg, transport_id.as_mut_ptr())
    };

    if status != pj::pj_constants__PJ_SUCCESS as i32 {
        return Err(TelephonyError::TransportError("Error of some kind".to_string()));
    }
    return Ok(0);
}

pub fn start_telephony() -> Result <i8,TelephonyError>{
    let status = unsafe{pj::pjsua_start()};
    if status != pj::pj_constants__PJ_SUCCESS as i32 {
        println!("Error starting pjsua, status = {}",status);
        error_exit("Error starting pjsua");
        return Err(TelephonyError::TelephonyStartError("Could not Start Telephony".to_string()));
        };
    Ok(0)
}

pub fn accountSetup(uri : String) -> Result<i32,TelephonyError> {
    println!("ACCOUNT SETUP");
    let status : pj::pj_status_t;
    let mut acc_cfg =  unsafe {
        let mut acc_cfg: Box<MaybeUninit<pj::pjsua_acc_config>> = Box::new(MaybeUninit::uninit());
        pj::pjsua_acc_config_default(acc_cfg.as_mut_ptr());
        acc_cfg
    };
    let acc_cfg_ref = unsafe { &mut *acc_cfg.as_mut_ptr() }; 

    let acc_id : String      = ["sip:".to_string(),uri.clone()].concat();
    let reg_uri : String    = "".to_string();

    let acc_id_pj_str_t = match make_pj_str_t(acc_id){
        Err(x)=> return Err(x),
        Ok(y)=>y
    };
    let reg_uri_pj_str_t = match make_pj_str_t(reg_uri){
        Err(x)=> return Err(x),
        Ok(y)=>y 
    }; 

    // Setting members of the struct
    acc_cfg_ref.id = acc_id_pj_str_t ;
    acc_cfg_ref.reg_uri = reg_uri_pj_str_t;
    acc_cfg_ref.register_on_acc_add = true as i32;
    acc_cfg_ref.cred_count = 0;
    acc_cfg_ref.media_stun_use = pjsua_stun_use_PJSUA_STUN_RETRY_ON_FAILURE;

    let acc_id : pj::pjsua_acc_id;
    acc_id = 0 ;
    status = unsafe {pj::pjsua_acc_add(acc_cfg_ref, pj::pj_constants__PJ_TRUE.try_into().unwrap(), acc_id as *mut i32 )} ;

    // let acc_id_c_string_fromraw = unsafe {CString::from_raw( acc_id_myptr)}; // Might need this at a later stage
    
    println!("Status of pjsua Acc add : {}" , status);
    if status != pj::pj_constants__PJ_SUCCESS as i32  { 
        println!("Error Adding Account, status = {}", status);
        error_exit("Error Adding Account");
        return Err(TelephonyError::AccountCreationError("Error Adding Account".to_string()));
    }
    return Ok(acc_id);
}

extern "C" fn on_incoming_call(_acc_id: pj::pjsua_acc_id, call_id: pj::pjsua_call_id, _rdata: *mut pj::pjsip_rx_data) {
    unsafe{ pj::pjsua_call_answer(call_id, 200, std::ptr::null(), std::ptr::null()); } 
    println!("The accepted call id is: {}", call_id);
}

extern "C" fn on_incoming_call_ignore(_acc_id: pj::pjsua_acc_id, call_id: pj::pjsua_call_id, _rdata: *mut pj::pjsip_rx_data) {
    println!("The ignored call id is: {}", call_id);
}

extern "C" fn on_call_media_state(call_id: pj::pjsua_call_id) {
    let ci = unsafe {
        let mut ci : MaybeUninit<pj::pjsua_call_info> = MaybeUninit::uninit();
        pj::pjsua_call_get_info(call_id, ci.as_mut_ptr());
        ci.assume_init()
    };
    
    if ci.media_status == pj::pjsua_call_media_status_PJSUA_CALL_MEDIA_ACTIVE {
        unsafe { 
            pj::pjsua_conf_connect(ci.conf_slot, 0);
            pj::pjsua_conf_connect(0,ci.conf_slot);
        }
    }
}

extern "C" fn on_call_state(call_id: pj::pjsua_call_id, _: *mut pj::pjsip_event){
    let ci = unsafe {
        let mut ci : MaybeUninit<pj::pjsua_call_info> = MaybeUninit::uninit();
        pj::pjsua_call_get_info(call_id, ci.as_mut_ptr());
        ci.assume_init()
    };
    // log ci
    println!("Call info: {:?}", ci.last_status);

    // push update to the relevant call manager
    push_call_state_update(call_id, ci).unwrap_or(());
}

pub fn make_call(acc_id: i32, phone_number: &str, domain : &str) -> Result<i32,TelephonyError>{

    // TODO: Check Phone number isnt garbage string
    let call_extension: String = if phone_number.is_empty() {
        format!("sip:{}", domain)
    } else {
        format!("sip:{}@{}", phone_number, domain)
    };
    let len = call_extension.len() as ::std::os::raw::c_long;
    let call_extension_c_string = CString::new(call_extension);
    let call_extension_c_string_ok = match call_extension_c_string {
        Err(_y) => return Err(TelephonyError::CallCreationError("Phone number or Domain supplied could not be represented as a C-String".to_string())),
        Ok(x) => x
    };

    let call_extension_myptr = call_extension_c_string_ok.into_raw();
    let call_extension_pj_str_t = pj::pj_str_t { slen: len , ptr: call_extension_myptr };
    let ptr_call_extension_pj_str_t = &call_extension_pj_str_t as *const _;

    let user_data_null: *mut ::std::os::raw::c_void = &mut 0 as *mut _ as *mut ::std::os::raw::c_void;
    let opt = 0 as *mut pj::pjsua_call_setting;
    let mut call_id: pj::pjsua_call_id = 0;
    let make_call_restult = unsafe {pj::pjsua_call_make_call( acc_id , ptr_call_extension_pj_str_t , opt, user_data_null, 0 as *mut  pj::pjsua_msg_data , &mut call_id)};
    if make_call_restult!=0 {
        return Err(TelephonyError::CallCreationError("Could not place Call".to_string()));
    }
    return Ok(call_id);
}

pub fn send_dtmf(digit:u32) -> Result<i8,TelephonyError> {

    let digits : String       = digit.to_string();
    let digits_pj_str_t = match make_pj_str_t(digits){
        Err(_e) => return Err(TelephonyError::DTMFError("Cannot Send DTMF Tone, digits contain Null Somehow".to_string())),
        Ok(v) => v
    };

    let dtmf_tones = pj::pjsua_call_send_dtmf_param {
        method   : pj::pjsua_dtmf_method_PJSUA_DTMF_METHOD_RFC2833,
        duration : pj::PJSUA_CALL_SEND_DTMF_DURATION_DEFAULT,
        digits   : digits_pj_str_t
    };
    let status = unsafe{ pj::pjsua_call_send_dtmf(0, &dtmf_tones )};
    if status!=0{
        return Err(TelephonyError::DTMFError("Cannot Send DTMF Tone".to_string()));  
    }
    return Ok(0); 
}

pub fn hangup_call(call_id:i32) -> Result<(),TelephonyError>{
    let status = unsafe{ pj::pjsua_call_hangup(call_id, 0, std::ptr::null(), std::ptr::null())};
    if status!=0{
        return Err(TelephonyError::CallStatusUpdateError("Could not Hangup Call".to_string()));
    }
    Ok(())
}

pub fn hangup_calls(){
    unsafe{ pj::pjsua_call_hangup_all()}; 
}

pub fn destroy_telephony()-> Result<i8,TelephonyError>{
    println!("Destroy telephony");
    let status = unsafe{pj::pjsua_destroy()};
    if status!=0{
        return Err(TelephonyError::TelephonyDestroyError("Error Occured during Telephony Destruction".to_string()));
    }
    Ok(0)
}
