import 'package:demo_app/Screens/ui/bottom_nav/bottom_nav.dart';
import 'package:demo_app/services/auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const BottomNav();
        } else if (snapshot.hasError) {
          return const Center(child: Text('An error occurred'));
        } else {
          return const LoginOrRegister();
        }
      }),
    );
  }
}