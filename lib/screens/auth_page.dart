
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  static const route = '/auth';

  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ungatekept'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // TODO: add your signup logic or navigation
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}


