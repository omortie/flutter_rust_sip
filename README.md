# flutter_rust_sip

A cross-platform SIP (Session Initiation Protocol) client built with Flutter and Rust.

## Features

- SIP registration and call handling
- Cross-platform support (Android, iOS, desktop)
- High performance via Rust FFI

## Getting Started

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/flutter_rust_sip.git
    cd flutter_rust_sip
    ```

2. Install dependencies:
    Make sure that [PJSIP](https://github.com/pjsip/pjproject) built and installed 
    [Notice for Linux/MacOS](https://docs.pjsip.org/en/latest/pjsua2/building.html#common-requirements)
    ```sh
    flutter pub get
    ```

3. Build the Rust library (see `rust/README.md` for details).

4. Run the app:
    ```sh
    flutter run
    ```

## Project Structure

- `lib/` - Flutter/Dart code
- `rust/` - Rust SIP core

*This project is under active development.*

### Acknowledgement
used [sip-phone-rs](https://github.com/Charles-Schleich/sip-phone-rs) sources as helper initializers