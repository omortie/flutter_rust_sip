
#[derive(Debug, Clone)]
pub enum CallState {
    Null,
    Early,
    Incoming,
    Calling,
    Connecting,
    Confirmed,
    Disconnected,
    Error(String)
}

#[derive(Debug, Clone)]
pub struct CallInfo {
    pub call_id: i32,
    pub call_url: String,
    pub state: CallState,
}

#[derive(Debug, Clone)]
pub enum SessionState {
    Initialized,
    Running,
    Stopped,
    Error(String)
}

#[derive(Debug, Clone)]
pub struct AccountInfo {
    pub acc_id: i32,
    pub status_code: i32,
}
