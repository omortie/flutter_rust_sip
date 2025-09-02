
#[derive(Debug, Clone)]
pub enum CallState {
    Early,
    Calling,
    Connecting,
    Confirmed,
    Disconnected,
    Error(String)
}

#[derive(Debug, Clone)]
pub enum SessionState {
    Initialized,
    Running,
    Stopped,
    Error(String)
}