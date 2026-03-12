import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rust_sip_example/di.dart';

class LoginWidget extends ConsumerStatefulWidget {
  const LoginWidget({super.key});

  @override
  ConsumerState<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends ConsumerState<LoginWidget> {
  final TextEditingController _usernameController = TextEditingController()..text = 'client';
  final TextEditingController _passwordController = TextEditingController()..text = 'clientpwd';
  final TextEditingController _sipServerUrlController = TextEditingController()..text = 'localhost';
  final TextEditingController _portController = TextEditingController()..text = '5060';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _sipServerUrlController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceRegistrationStatus = ref.watch(sipServiceRegistrationProvider);

    final status = serviceRegistrationStatus.value;
    final registrationStatusText = switch (status) {
      200 => 'SIP Account Registered Successfully',
      -1 => 'Not Registered yet (Error code: $status)',
      _ => 'Registration failed... (Status code: $status)',
    };
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8.0,
              children: [
                Text(
                  registrationStatusText,
                  style: TextStyle(
                      fontSize: 18,
                      color: status == 200 ? Colors.red : Colors.red),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Register SIP Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                TextField(
                  controller: _sipServerUrlController,
                  decoration: const InputDecoration(
                    labelText: 'SIP Server URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final service = await ref.read(sipServiceProvider.future);
                    await service.registerAccount(
                        uri: _sipServerUrlController.text,
                        username: _usernameController.text,
                        password: _passwordController.text);
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
