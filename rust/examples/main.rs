use flutter_rust_sip as sip;
use log::debug;
use sip::api::simple::{account_setup, destroy_pjsua, hangup_call, make_call};

#[tokio::main]
async fn main() {
    //Setup
    let init_result = sip::api::simple::init_pjsua(
        5061,
        sip::core::types::OnIncommingCall::AutoAnswer,
        String::from("stun.l.google.com:3478"),
    );
    match init_result {
        Ok(status) => debug!("PJSUA initialized with status: {}", status),
        Err(e) => {
            debug!("Failed to initialize PJSUA: {:?}", e);
            return;
        }
    }

    //Account Setup
    let username = String::from("USERNAME");
    let reg_uri = String::from("localhost");
    let password = String::from("PASSWORD");

    match account_setup(reg_uri, username, password) {
        Ok(acc_id) => debug!("Account setup successful, account ID: {}", acc_id),
        Err(e) => {
            debug!("Failed to setup account: {:?}", e);
            let _ = destroy_pjsua();
            return;
        }
    }

    loop {
        use std::io;
        let mut input = String::new();
        debug!("-------------------------------------");
        debug!("Type: 'c' to call\n    : 'h' to hangup call (ID required)\n    : 'q' to quit");
        match io::stdin().read_line(&mut input) {
            Ok(_) => {
                if input == "q\n" {
                    break;
                }
                if input == "c\n" {
                    let mut telNum = String::new();
                    debug!("Type in telephone number:");

                    match io::stdin().read_line(&mut telNum) {
                        Ok(_) => {
                            let len = telNum.len();
                            telNum.truncate(len - 1);
                            match make_call(telNum, "DOMAIN".to_string()).await {
                                Ok(call_id) => debug!("Call made with ID: {}", call_id),
                                Err(e) => debug!("Failed to make call: {:?}", e),
                            }
                        }
                        Err(error) => debug!("error: {}", error),
                    }
                }
                if input == "h\n" {
                    let mut call_id_str = String::new();
                    debug!("Type in call ID to hangup:");
                    match io::stdin().read_line(&mut call_id_str) {
                        Ok(_) => {
                            if let Ok(call_id) = call_id_str.trim().parse::<i32>() {
                                match hangup_call(call_id) {
                                    Ok(()) => debug!("Call {} hung up", call_id),
                                    Err(e) => debug!("Failed to hangup call: {:?}", e),
                                }
                            } else {
                                debug!("Invalid call ID");
                            }
                        }
                        Err(error) => debug!("error: {}", error),
                    }
                }
            }
            Err(error) => debug!("error: {}", error),
        }
    }

    // Destroy and cleanup telephony
    match destroy_pjsua() {
        Ok(status) => debug!("PJSUA destroyed with status: {}", status),
        Err(e) => debug!("Error destroying PJSUA: {:?}", e),
    }
}
