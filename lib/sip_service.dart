import 'dart:async';

import 'package:flutter_rust_sip/flutter_rust_sip.dart' as frs;

import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/flutter_rust_sip.dart';
import 'package:flutter_rust_sip/rust/api/simple.dart';
import 'package:rxdart/subjects.dart' as rx;

class SIPService {
  final List<int> callIds = [];
  late rx.BehaviorSubject<CallInfo> stateBroadcast;
  final Stream<CallInfo> updateStream;

  bool initialized = false;
  static SIPService? _instance;

  String? error;

  SIPService({
    required this.updateStream}) {
    stateBroadcast = rx.BehaviorSubject<CallInfo>();
    updateStream.listen((event) {
      debugPrint('Call State Changed: ${event.state}');

      if (event.state == CallState.disconnected()) {
        callIds.remove(event.callId);
      }

      if (!stateBroadcast.isClosed) {
        stateBroadcast.add(event);
      }
    });

    initialized = true;
  }

  static Future<SIPService> init() async {
    if (_instance != null) return _instance!;

    try {
      await frs.init();
      final stream = registerCallStream();

      final service = SIPService(updateStream: stream);
      _instance = service;

      return service;
    } catch (e) {
      debugPrint('Error initializing SIPService: $e');
      return Future.error(e.toString());
    }
  }
 
  Future<void> dispose() async {
    initialized = false;
    await stateBroadcast.close();
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
      callIds.add(callId);

      Future.microtask(() async {
        while (callIds.contains(callId) && initialized) {
          await markCallAlive(callId: callId);
          debugPrint('Pinging outgoing call $callId to keep alive...');
          await Future.delayed(const Duration(seconds: 1));
        }
      });

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
