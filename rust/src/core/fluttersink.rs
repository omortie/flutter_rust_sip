

#[derive(Serialize, Clone, Debug)]
struct CallStateEvent {
    call_id: i32,
    state: i32,
    last_status: i32,
    remote: String,
    ts_ms: i64,
}