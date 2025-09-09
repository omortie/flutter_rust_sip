import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/flutter_rust_sip.dart';
import 'package:flutter_rust_sip/rust/api/simple.dart';
import 'package:rxdart/subjects.dart' as rx;

class SIPService {
  final int accountId;
  final rx.BehaviorSubject<CallInfo> stateBroadcast;
  final StreamSubscription<CallInfo> originalSub;

  bool initialized = false;

  String? error;

  SIPService({
    required this.accountId,
    required this.originalSub,
    required this.stateBroadcast,
  });

  static Future<(SIPService?, String?)> init({
    required String uri,
  }) async {
    try {
      final accountId = await accountSetup(
        uri: '127.0.0.1',
      );
      final stream = registerCallStream();
      final bs = rx.BehaviorSubject<CallInfo>();
      final originalSub = stream.listen((event) {
        debugPrint('Call State Changed: ${event.state}');
        bs.add(event);
      });

      final service = SIPService(
        accountId: accountId,
        originalSub: originalSub,
        stateBroadcast: bs,
      );

      service.initialized = true;

      Future.microtask(() async {
        while (service.initialized) {
          await markSipAlive();
          debugPrint('Pinging SIP service to keep alive...');
          await Future.delayed(const Duration(seconds: 1));
        }
      });

      return (service, null);
    } catch (e) {
      debugPrint('Error initializing SIPService: $e');
      return (null, e.toString());
    }
  }

  Future<void> dispose() async {
    initialized = false;
    await originalSub.cancel();
    await stateBroadcast.close();
    await destroyTelephony();
    debugPrint('SIPService disposed');
  }

  Future<int> call(String phoneNumber, String domain) async {
    if (!initialized) {
      throw Exception('SIPService not initialized');
    }
    try {
      final callId = await makeCall(
        accId: accountId,
        phoneNumber: phoneNumber,
        domain: domain,
      );
      debugPrint('Call initiated to $phoneNumber with call ID: $callId');
      return callId;
    } catch (e) {
      debugPrint('Error making call to $phoneNumber: $e');
      rethrow;
    }
  }

  Future<void> hangup(int callId) async {
    if (!initialized) {
      throw Exception('SIPService not initialized');
    }
    try {
      await hangupCall(callId: callId);
      debugPrint('Call with ID $callId hung up successfully');
    } catch (e) {
      debugPrint('Error hanging up call with ID $callId: $e');
      rethrow;
    }
  }
}
