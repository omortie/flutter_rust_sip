extern crate pjsip as pj;

use crate::core::types::PJSUAError;
use std::{ffi::CString, os::raw::c_char};

pub fn make_pj_str_t(input: String) -> Result<pj::pj_str_t, PJSUAError> {
    let len = input.len();
    let input_c_string = CString::new(input.clone());
    match input_c_string {
        Err(_x) => {
            let err_message: String = [
                "Could not use input value: '".to_string(),
                input,
                "' Contained Null Byte".to_string(),
            ]
            .concat();
            return Err(PJSUAError::InputValueError(err_message));
        }
        Ok(c_string) => {
            let input_ptr = c_string.into_raw();
            // If memory leak, This line below may be the fix
            // let _ = unsafe{CString::from_raw(input_ptr)};
            return Ok(pj::pj_str_t {
                slen: len as _,
                ptr: input_ptr,
            });
        }
    }
}

pub fn pj_str_to_string(p: pj::pj_str_t) -> String {
    if p.ptr.is_null() || p.slen == 0 {
        return String::new();
    }
    let len = p.slen as usize;
    let bytes = unsafe { std::slice::from_raw_parts(p.ptr as *const u8, len) };
    String::from_utf8_lossy(bytes).into_owned()
}

pub fn error_exit(err_msg: &str) {
    println!("Exiting PJSUA {}", err_msg);
    let err: *const c_char = CString::new("Error Here")
        .expect("CString::new failed")
        .as_ptr();
    let thisfile = CString::new("main.rs")
        .expect("CString::new failed")
        .as_ptr();
    unsafe { pj::pjsua_perror(thisfile, err, 2) };
    unsafe { pj::pjsua_destroy() };
    unsafe { pj::exit(1) };
}
