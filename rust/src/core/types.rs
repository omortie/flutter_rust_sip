use thiserror::Error;
use crate::{core::dart_types::{CallInfo}, frb_generated::StreamSink};
                                 
#[derive(Error, Debug)]
pub enum PJSUAError {
    #[error("Cannot create a PJSUA instance")]
    CreationError(String),
    #[error("Internal Config invalid")]
    ConfigError(String),
    #[error("Cannot Initialize PJSUA instance")]
    InitializationError(String),
    #[error("Cannot Initialize PJSUA-Transport")]
    TransportError(String),
    #[error("Cannot Send DTMF Tone")]
    DTMFError(String),
    #[error("Could not Create Call")]
    CallCreationError(String),
    #[error("Call Status Update Error")]
    CallStatusUpdateError(String),
    #[error("Account Creation Error")]
    AccountCreationError(String),
    #[error("PJSUA Start Error")]
    PJSUAStartError(String),
    #[error("PJSUA destruction Error")]
    PJSUADestroyError(String),
    #[error("Input Error")]
    InputValueError(String),
}

#[derive(Debug)]
pub enum TransportMode {
    TCP,
    UDP,
    TLS,
    UDP6,
    TCP6,
    TLS6
}

#[derive(Debug)]
pub enum OnIncommingCall {
    AutoAnswer,
    Ignore
}

pub enum StreamExitResult {
    LegalExit,
    EOF,
    Error,
}


pub type DartCallStream = StreamSink<CallInfo>;