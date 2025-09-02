
#[derive(Debug, Clone)]
pub enum CallState {
    Initialized,
    Calling,
    Connecting,
    Confirmed,
    Disconnected,
    Error(String)
}

#[derive(Debug, Clone)]
pub enum ServiceState {
    Initialized,
    Running,
    Stopped,
    Error(String)
}