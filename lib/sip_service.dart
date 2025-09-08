import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rust_sip/flutter_rust_sip.dart';
import 'package:flutter_rust_sip/rust/api/simple.dart';
import 'package:rxdart/subjects.dart' as rx;

class SIPService {
  final int accountId;
  final rx.BehaviorSubject<CallInfo> stateBroadcast;
  final StreamSubscription<CallInfo> originalSub;

  bool _initialized = false;

  SIPService({required this.accountId, required this.originalSub, required this.stateBroadcast,});

  static Future<SIPService> init({
    required String uri,
  }) async {
    try {
      final accountId = await accountSetup(
        uri: '127.0.0.1',
      );
      final stream = registerCallStream(accountId: accountId);
      final bs = rx.BehaviorSubject<CallInfo>();
      final originalSub = stream.listen((event) {
        debugPrint('Call State Changed: ${event.state}');
        bs.add(event);
      });

      final service = SIPService(accountId: accountId, originalSub: originalSub, stateBroadcast: bs);

      service._initialized = true;

      Future.microtask(() async {
        while (service._initialized) {
          // todo: ping rust side to announce we still want the service.
          debugPrint('Pinging SIP service to keep alive...');
          await Future.delayed(const Duration(seconds: 1));
        }
      });

      return service;
    } catch (e) {
      debugPrint('Error initializing SIPService: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    _initialized = false;
    await originalSub.cancel();
    await stateBroadcast.close();
    // todo: destroy telephony on rust side
    debugPrint('SIPService disposed');
  }

  Future<int> call(String phoneNumber, String domain) async {
    if (!_initialized) {
      throw Exception('SIPService not initialized');
    }
    try {
      final callId = await makeCall(phoneNumber: phoneNumber, domain: domain);
      debugPrint('Call initiated to $phoneNumber with call ID: $callId');
      return callId;
    } catch (e) {
      debugPrint('Error making call to $phoneNumber: $e');
      rethrow;
    }
  }

  Future<void> hangup(int callId) async {
    if (!_initialized) {
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
