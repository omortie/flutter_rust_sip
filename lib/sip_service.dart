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
  late rx.BehaviorSubject<AccountInfo> accountStateBroadcast;
  final Stream<CallInfo> callStream;
  final Stream<AccountInfo> accountStream;

  bool initialized = false;

  String? error;

  SIPService({
    required this.callStream, required this.accountStream}) {
    callStateBroadcast = rx.BehaviorSubject<CallInfo>();
    callStream.listen((event) {
      switch (event.state) {
        case const CallState.disconnected():
          callIds.remove(event.callId);
        default:
          callIds[event.callId] = event;
      }

      if (!callStateBroadcast.isClosed) {
        callStateBroadcast.add(event);
      }
    });
    accountStateBroadcast = rx.BehaviorSubject<AccountInfo>();
    accountStream.listen((event) {
      if (!accountStateBroadcast.isClosed) {
        accountStateBroadcast.add(event);
      }
    });

    initialized = true;

    Future.microtask(() async {
      while (initialized) {
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
    String uri = '127.0.0.1',
    String username = '',
    String password = '',
  }) async {
    try {
      final result = await frs.init(
        localPort: localPort,
        incomingCallStrategy: incomingCallStrategy,
        stunSrv: stunSrv,
      );
      if (result != 0) {
        // throw error
        throw 'Failed to initialize PJSUA with error code: $result';
      }

      final callStream = registerCallStream();
      final accountStream = registerAccountStream();

      final service = SIPService(
        callStream: callStream,
        accountStream: accountStream,
      );

      return service;
    } catch (e) {
      debugPrint('Error initializing SIPService: $e');
      return Future.error(e.toString());
    }
  }
 
  Future<void> dispose() async {
    initialized = false;
    await callStateBroadcast.close();
    await destroyPjsua();
    debugPrint('SIPService disposed');
  }

  Future<int> call(String phoneNumber, String domain) async {
    if (!initialized) {
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
      return -1;
    }
  }

  Future<void> hangup(int callId) async {
    if (!initialized) {
      error = 'SIPService not initialized';
    }
    try {
      await hangupCall(callId: callId);
      callIds.remove(callId);
      debugPrint('Call with ID $callId hung up successfully');
    } catch (e) {
      debugPrint('Error hanging up call with ID $callId: $e');
      error = e.toString();
    }
  }
}
