import 'dart:async';

import 'package:flutter_rust_sip/flutter_rust_sip.dart' as frs;

import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/flutter_rust_sip.dart';
import 'package:flutter_rust_sip/rust/api/simple.dart';
import 'package:flutter_rust_sip/rust/core/dart_types.dart';
import 'package:rxdart/subjects.dart' as rx;

class SIPService {
  final Map<int, CallInfo> callIds = {};
  late rx.BehaviorSubject<CallInfo> callStateBroadcast;
  late Stream<CallInfo> callStream;
  late Stream<AccountInfo> accountStream;

  static bool? initialized;
  static SIPService? _instance;
  static String? initializeErr;
  bool registered = false;
  String? error;

  SIPService() {
    // connect to update streams
    callStream = registerCallStream().asBroadcastStream();
    accountStream = registerAccountStream().asBroadcastStream();

    callStateBroadcast = rx.BehaviorSubject<CallInfo>();

    // analyze call stream changes so we can update the calls list
    callStream.listen((event) {
      switch (event.state) {
        // remove the disconnected call from call list
        case const CallState.disconnected():
          callIds.remove(event.callId);
        default:
          callIds[event.callId] = event;
      }

      if (!callStateBroadcast.isClosed) {
        callStateBroadcast.add(event);
      }
    });

    accountStream.listen((event) {
      registered = event.statusCode == 200;
    });

    Future.microtask(() async {
      while (initialized == true) {
        for (final call in callIds.values.toList()) {
          await markCallAlive(callId: call.callId);
          debugPrint('Pinging outgoing call ${call.callId} to keep alive...');
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    });
  }

  static Future<SIPService> init({
    int localPort = 5060,
    OnIncommingCall incomingCallStrategy = OnIncommingCall.ignore,
    String stunSrv = 'stun.l.google.com:19302',
  }) async {
    try {
      if (initialized == false) {
        // we have tried but we couldn't initialize before
        // so avoid initializing again
        return Future.error('SIPService not initialized (err: $initializeErr)');
      }
      if (initialized == true && _instance != null) {
        // already initialized
        return _instance!;
      }
      final initResult = await frs.init(
        localPort: localPort,
        incomingCallStrategy: incomingCallStrategy,
        stunSrv: stunSrv,
      );
      if (initResult != 0) {
        // throw error
        throw 'Failed to initialize PJSUA with error code: $initResult';
      }

      final service = SIPService();
      initialized = true;
      _instance = service;

      return service;
    } catch (e) {
      // set initialized to false on error so we would not try again, that will crash the app
      initialized = false;
      initializeErr = e.toString();
      return Future.error(initializeErr.toString());
    }
  }
 
  Future<void> dispose() async {
    initialized = false;
    await callStateBroadcast.close();
    await destroyPjsua();
    debugPrint('SIPService disposed');
  }

  Future<int> registerAccount({
    required String uri,
    required String username,
    required String password,
  }) async {
    try {
      if (initialized == false) {
        throw 'SIPService not initialized';
      }
      final accId = await accountSetup(
        uri: uri,
        username: username,
        password: password,
      );
      return accId;
    } catch (e) {
      debugPrint('Error registering account: $e');
      error = e.toString();
      return Future.error(error.toString());
    }
  }

  Future<int> call(String phoneNumber, String domain) async {
    if (initialized == false) {
      error = 'SIPService not initialized';
    }
    try {
      final callId = await makeCall(
        phoneNumber: phoneNumber,
        domain: domain,
      );
      debugPrint('Call initiated to $phoneNumber with call ID: $callId');

      return callId;
    } catch (e) {
      debugPrint('Error making call to $phoneNumber: $e');
      error = e.toString();
      return Future.error(error.toString());
    }
  }

  Future<void> hangup(int callId) async {
    if (initialized == false) {
      error = 'SIPService not initialized';
    }
    try {
      await hangupCall(callId: callId);
      callIds.remove(callId);
      debugPrint('Call with ID $callId hung up successfully');
    } catch (e) {
      debugPrint('Error hanging up call with ID $callId: $e');
      error = e.toString();
      return Future.error(error.toString());
    }
  }
}
