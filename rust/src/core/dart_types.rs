
#[derive(Debug, Clone)]
pub enum CallState {
    Calling,
    Connecting,
    Confirmed,
    Disconnected,
    Error(String)
}
