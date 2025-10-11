# flutter_rust_sip

A cross-platform SIP (Session Initiation Protocol) client built with Flutter and Rust.

## Features

- SIP registration and call handling
- High performance via Rust FFI
- SIP Credentials to work with SIP servers

## Getting Started

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/flutter_rust_sip.git
    cd flutter_rust_sip
    ```

2. Go to the `example` and Run the app:
    ```sh
    cd example
    flutter run
    ```

## Project Structure

- `lib/` - Flutter/Dart code
- `rust/` - Rust SIP core
- `example/` - A simple example of using SIP lib in Flutter

### Acknowledgement
used [sip-phone-rs](https://github.com/Charles-Schleich/sip-phone-rs) sources as helper inspiration
used [pjsip-sys](https://github.com/omortie/pjsip-sys) as the base Rust binding
