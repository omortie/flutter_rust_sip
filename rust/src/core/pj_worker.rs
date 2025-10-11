use std::sync::mpsc::{self};

// Type alias: a Job is a boxed closure that can be sent between threads.
type Job = Box<dyn FnOnce() + Send + 'static>;

// Global singleton PjWorker - initialized once, used throughout app lifetime
lazy_static::lazy_static! {
    static ref PJSIP_WORKER: PjWorker = PjWorker::new();
}

// Auxiliary function to get a reference to the global PjWorker
pub fn get_pjsip_worker() -> &'static PjWorker {
    &PJSIP_WORKER
}

// The PjWorker struct encapsulates a worker thread that processes jobs sent to it.
// It uses a channel to receive jobs and execute them sequentially.
// The worker thread is registered with PJSIP to ensure thread safety and to avoid registering thread everytime.
pub struct PjWorker {
    sender: mpsc::Sender<Job>,
}

// Implementation of PjWorker
impl PjWorker {
    pub fn new() -> Self {
        let (sender, receiver) = mpsc::channel::<Job>();

        std::thread::spawn(move || {
            // Ensure this thread is registered with PJSIP
            super::helpers::ensure_pj_thread_registered();

            // Continuously receive and execute jobs
            while let Ok(job) = receiver.recv() {
                job();
            }
        });

        PjWorker { sender }
    }

    pub fn execute<F>(&self, f: F)
    where
        F: FnOnce() + Send + 'static,
    {
        self.sender.send(Box::new(f)).unwrap();
    }

    // New sync execute that returns results
    pub fn execute_sync<F, R>(&self, f: F) -> R
    where
        F: FnOnce() -> R + Send + 'static,
        R: Send + 'static,
    {
        let (tx, rx) = mpsc::channel::<R>();
        
        let job = Box::new(move || {
            let result = f();
            tx.send(result).expect("Receiver dropped");
        });

        self.sender.send(job).expect("Failed to send job to worker");
        
        // Block until we get the result
        rx.recv().expect("Sender dropped")
    }
}