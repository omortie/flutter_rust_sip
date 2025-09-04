# flutter_rust_sip

A cross-platform SIP (Session Initiation Protocol) client built with Flutter and Rust.

## Features

- SIP registration and call handling
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

3. Install Flutter dependencies
    ```sh
    flutter pub get
    ```

4. Run Dart Build Runner
    ```sh
    dart run build_runner build -d
    ```

5. Go to the `example` and Run the app:
    ```sh
    flutter run
    ```

## Project Structure

- `lib/` - Flutter/Dart code
- `rust/` - Rust SIP core
- `example/` - A simple example of using SIP lib in Flutter

*This project is under active development.*

### Acknowledgement
used [sip-phone-rs](https://github.com/Charles-Schleich/sip-phone-rs) sources as helper inspiration