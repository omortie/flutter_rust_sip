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
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            switch (serviceRegistrationStatus.value) {
              200 => const Text(
                'SIP Account Registered Successfully',
              ),
              -1 => Text(
                'Not Registered yet (Error code: $serviceRegistrationStatus)',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
              _ => Text(
                'Registration failed... (Status code: $serviceRegistrationStatus)'
              ),
            },
            const Text(
              'Register SIP Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sipServerUrlController,
              decoration: const InputDecoration(
                labelText: 'SIP Server URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final service = await ref.read(sipServiceProvider.future);
                await service.registerAccount(uri: _sipServerUrlController.text, username: _usernameController.text, password: _passwordController.text);
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
