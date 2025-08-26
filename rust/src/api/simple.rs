// FFI-safe wrappers for telephony functions
use telephony::*;

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
    // Start telephony system
    initialize_telephony(4,OnIncommingCall::AutoAnswer,5070,TransportMode::UDP);
}

#[flutter_rust_bridge::frb(sync)]
pub fn ffi_account_setup(username: String, uri: String, password: String) -> i8 {
    ensure_pj_thread_registered();
    accountSetup(username, uri, password);
    return 1;
}

// make call ffi
#[flutter_rust_bridge::frb(sync)]
pub fn ffi_make_call(phone_number: String, domain: String) -> i8 {
    println!("making call to {}@{}", phone_number, domain);
    ensure_pj_thread_registered();
    make_call(&phone_number, &domain);
    return 1;
}

// #[no_mangle]
// pub extern "C" fn ffi_make_call(phone_number: *const c_char, domain: *const c_char) -> c_int {
//     let phone_number = unsafe { CStr::from_ptr(phone_number) }.to_string_lossy().to_string();
//     let domain = unsafe { CStr::from_ptr(domain) }.to_string_lossy().to_string();
//     match make_call(&phone_number, &domain) {
//         Ok(v) => v as c_int,
//         Err(_) => -1,
//     }
// }
    
// #[no_mangle]
// pub extern "C" fn ffi_send_dtmf(digit: u32) -> c_int {
//     match send_dtmf(digit) {
//         Ok(v) => v as c_int,
//         Err(_) => -1,
//     }
// }

// #[no_mangle]
// pub extern "C" fn ffi_hangup_calls() {
//     hangup_calls();
// }

// #[no_mangle]
// pub extern "C" fn ffi_destroy_telephony() -> c_int {
//     match destroy_telephony() {
//         Ok(v) => v as c_int,
//         Err(_) => -1,
//     }
// }
