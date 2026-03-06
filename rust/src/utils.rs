extern crate pjsip as pj;

use log::debug;

use crate::core::types::PJSUAError;
use std::ffi::CString;

/// Owns a CString and exposes its pj_str_t. The CString is freed when this drops.
/// Keep this alive until after the PJSIP call that uses the pj_str_t completes.
pub struct PjStr {
    _owner: CString,
    pub raw: pj::pj_str_t,
}

impl PjStr {
    pub fn new(input: String) -> Result<Self, PJSUAError> {
        let len = input.len();
        CString::new(input.clone())
            .map(|cstring| {
                let ptr = cstring.as_ptr() as *mut _;
                PjStr {
                    _owner: cstring,
                    raw: pj::pj_str_t { ptr, slen: len as _ },
                }
            })
            .map_err(|_| PJSUAError::InputValueError(
                format!("Could not use input value: '{}' Contained Null Byte", input)
            ))
    }
}

pub fn make_pj_str_t(input: String) -> Result<PjStr, PJSUAError> {
    PjStr::new(input)
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
    debug!("Exiting PJSUA {}", err_msg);
    let err_cstring = CString::new("Error Here")
        .expect("CString::new failed");
    let err = err_cstring.as_ptr();
    
    let thisfile_cstring = CString::new("main.rs")
        .expect("CString::new failed");
    let thisfile = thisfile_cstring.as_ptr();
    
    unsafe { pj::pjsua_perror(thisfile, err, 2) };
    unsafe { pj::pjsua_destroy() };
    unsafe { pj::exit(1) };
}
