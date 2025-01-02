import 'package:demo_app/Screens/Components/custom_newbutton.dart';
import 'package:demo_app/services/auth/auth_gate.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/illustration.png'),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 100,
                    width: 280,
                    child: Text(
                      'Connect easily with your family and friends over countries',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text('Terms & Privacy Policy', style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400
            ),),
            const SizedBox(height: 20),
            CustomNewbutton(text: 'Start Messaging', onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AuthGate()));
            },),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ));
  }
}
