use flutter_rust_sip as sip;
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
        Ok(status) => println!("PJSUA initialized with status: {}", status),
        Err(e) => {
            println!("Failed to initialize PJSUA: {:?}", e);
            return;
        }
    }

    //Account Setup
    let username = String::from("USERNAME");
    let reg_uri = String::from("localhost");
    let password = String::from("PASSWORD");

    match account_setup(reg_uri, username, password) {
        Ok(acc_id) => println!("Account setup successful, account ID: {}", acc_id),
        Err(e) => {
            println!("Failed to setup account: {:?}", e);
            let _ = destroy_pjsua();
            return;
        }
    }

    loop {
        use std::io;
        let mut input = String::new();
        println!("-------------------------------------");
        println!("Type: 'c' to call\n    : 'h' to hangup call (ID required)\n    : 'q' to quit");
        match io::stdin().read_line(&mut input) {
            Ok(_) => {
                if input == "q\n" {
                    break;
                }
                if input == "c\n" {
                    let mut telNum = String::new();
                    println!("Type in telephone number:");

                    match io::stdin().read_line(&mut telNum) {
                        Ok(_) => {
                            let len = telNum.len();
                            telNum.truncate(len - 1);
                            match make_call(telNum, "DOMAIN".to_string()).await {
                                Ok(call_id) => println!("Call made with ID: {}", call_id),
                                Err(e) => println!("Failed to make call: {:?}", e),
                            }
                        }
                        Err(error) => println!("error: {}", error),
                    }
                }
                if input == "h\n" {
                    let mut call_id_str = String::new();
                    println!("Type in call ID to hangup:");
                    match io::stdin().read_line(&mut call_id_str) {
                        Ok(_) => {
                            if let Ok(call_id) = call_id_str.trim().parse::<i32>() {
                                match hangup_call(call_id) {
                                    Ok(()) => println!("Call {} hung up", call_id),
                                    Err(e) => println!("Failed to hangup call: {:?}", e),
                                }
                            } else {
                                println!("Invalid call ID");
                            }
                        }
                        Err(error) => println!("error: {}", error),
                    }
                }
            }
            Err(error) => println!("error: {}", error),
        }
    }

    // Destroy and cleanup telephony
    match destroy_pjsua() {
        Ok(status) => println!("PJSUA destroyed with status: {}", status),
        Err(e) => println!("Error destroying PJSUA: {:?}", e),
    }
}
