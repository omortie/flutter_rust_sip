use thiserror::Error;
                                 
#[derive(Error, Debug)]
pub enum TelephonyError {
    #[error("Cannot create a Telephony instance")]
    CreationError(String),
    #[error("Internal Config invalid")]
    ConfigError(String),
    #[error("Cannot Initialize Telephony instance")]
    InitializationError(String),
    #[error("Cannot Initialize Telephony-Transport")]
    TransportError(String),
    #[error("Cannot Send DTMF Tone")]
    DTMFError(String),
    #[error("Could not Create Call")]
    CallCreationError(String),
    #[error("Account Creation Error")]
    AccountCreationError(String),
    #[error("Telephony Start Error")]
    TelephonyStartError(String),
    #[error("Telephony destruction Error")]
    TelephonyDestroyError(String),
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