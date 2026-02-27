pub mod helpers;
pub mod types;
pub mod dart_types;
pub mod managers;
pub mod pj_worker;

use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt, EnvFilter};
use log::debug;

lazy_static::lazy_static! {
    pub static ref IS_INITIALIZED: std::sync::Mutex<bool> = std::sync::Mutex::new(false);
    static ref WORKER_GUARD: std::sync::Mutex<Option<tracing_appender::non_blocking::WorkerGuard>> = std::sync::Mutex::new(None);
}

pub(crate) fn init_bridge() {
    let is_initialized = IS_INITIALIZED.lock().unwrap();
    if *is_initialized {
        return;
    }

    // Default utilities - feel free to custom
    flutter_rust_bridge::setup_default_user_utils();
    debug!("Done initializing");
}