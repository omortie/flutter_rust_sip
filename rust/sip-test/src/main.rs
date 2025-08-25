extern crate telephony as tel;

pub fn main() {
    //Setup
    let init_success = tel::initialize_telephony(0,tel::OnIncommingCall::AutoAnswer,5070,tel::TransportMode::UDP);

    //Account Setup
    let username = String::from ("USERNAME");
    let reg_uri = String::from ("ADDRESS");
    let password = String::from ("PASSWORD");
    tel::accountSetup(username, reg_uri, password);

    loop {
        use std::io;
        let mut input = String::new();
        println!("-------------------------------------");
        println!("Type: 'h' to hangup all calls,\n    : 'd' to send 123456 DTMF tone\n    : 'f' to send 2 DTMF tone\n    : 'c' to call\n    : 'q' to quit");
        match io::stdin().read_line(&mut input) {
            Ok(n) => {
                if input == "q\n" { break; }
                if input == "h\n" { unsafe{ tel::hangup_calls()}; }
                if input == "d\n" { tel::send_dtmf(123456); }
                if input == "f\n" { tel::send_dtmf(2); }
                if input == "c\n" {
                    let mut telNum = String::new();
                    println!("Type In telephone number");

                    match io::stdin().read_line(&mut telNum) {
                        Ok(n) => {
                            let len = telNum.len();
                            telNum.truncate(len - 1);
                            tel::make_call(&telNum,"DOMAIN"); }
                        Err(error) => println!("error: {}", error),
                    }
                }
            }
            Err(error) => println!("error: {}", error),
        }
    }

    // Destroy and cleanup telephony
    tel::destroy_telephony();
}
